import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/status_pill.dart';
import '../../providers/usb_devices_provider.dart';
import '../../providers/devices_provider.dart';
import '../../core/models/device.dart';

class UsbScreen extends ConsumerWidget {
  const UsbScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usbDevicesAsync = ref.watch(usbDevicesProvider);
    final devicesNotifier = ref.read(devicesProvider.notifier);

    return AppShell(
      currentRoute: 'usb',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('USB Devices'),
          elevation: 0,
        ),
        body: usbDevicesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text('Error: $error'),
          ),
          data: (devices) {
            if (devices.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.usb, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No USB devices detected'),
                    SizedBox(height: 8),
                    Text('Connect an Android device via USB', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    device.model ?? 'Unknown Device',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    device.serial,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  if (device.androidVersion != null)
                                    Text(
                                      'Android ${device.androidVersion}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            StatusPill(status: device.status, small: true),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () async {
                            // TODO: Show enable WiFi ADB modal
                          },
                          child: const Text('Enable WiFi ADB'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
