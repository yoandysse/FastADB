import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/device.dart';
import '../core/services/adb_service.dart';
import 'tools_config_provider.dart';

final usbDevicesProvider = StreamProvider<List<UsbDevice>>((ref) async* {
  final toolsConfig = ref.watch(toolsConfigProvider);

  AdbService? adbService;

  await toolsConfig.whenData((config) async {
    if (config.adbPath.isNotEmpty) {
      adbService = AdbService(adbPath: config.adbPath);
      await adbService!.startServer();
    }
  });

  if (adbService == null) {
    yield const [];
    return;
  }

  while (true) {
    try {
      final devices = await adbService!.listUsbDevices();

      // Fetch additional info for each device
      for (int i = 0; i < devices.length; i++) {
        final model = await adbService!.getModel(devices[i].serial);
        final androidVersion = await adbService!.getAndroidVersion(devices[i].serial);

        devices[i] = devices[i].copyWith(model: model, androidVersion: androidVersion);
      }

      yield devices;
    } catch (e) {
      yield const [];
    }

    // Poll every 5 seconds
    await Future.delayed(const Duration(seconds: 5));
  }
});
