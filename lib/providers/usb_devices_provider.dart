import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/device.dart';
import '../core/services/adb_service.dart';
import 'tools_config_provider.dart';

final usbDevicesProvider = StreamProvider<List<UsbDevice>>((ref) async* {
  // Use ref.read (not ref.watch) so toolsConfig changes don't restart the stream.
  // The stream re-evaluates the config on every poll cycle instead.
  while (true) {
    try {
      final config = ref
          .read(toolsConfigProvider)
          .maybeWhen(data: (c) => c, orElse: () => null);

      if (config == null || config.adbPath.isEmpty) {
        yield const [];
      } else {
        final adbService = AdbService(adbPath: config.adbPath);
        final devices = await adbService.listUsbDevices();

        // Fetch model + android version for each detected device
        for (int i = 0; i < devices.length; i++) {
          final model = await adbService.getModel(devices[i].serial);
          final androidVersion =
              await adbService.getAndroidVersion(devices[i].serial);
          devices[i] =
              devices[i].copyWith(model: model, androidVersion: androidVersion);
        }

        yield devices;
      }
    } catch (_) {
      yield const [];
    }

    await Future.delayed(const Duration(seconds: 5));
  }
});
