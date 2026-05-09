import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/app_shell.dart';
import '../../providers/devices_provider.dart';
import 'widgets/device_card.dart';

class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsync = ref.watch(devicesProvider);
    final notifier = ref.read(devicesProvider.notifier);

    return AppShell(
      currentRoute: 'devices',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Devices'),
          elevation: 0,
        ),
        body: devicesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text('Error: $error'),
          ),
          data: (deviceStates) {
            if (deviceStates.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.devices, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No devices added yet'),
                    SizedBox(height: 8),
                    Text('Add a WiFi device to get started', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: deviceStates.length,
              itemBuilder: (context, index) {
                final state = deviceStates[index];

                return DeviceCard(
                  device: state.device,
                  status: state.status,
                  onConnect: () => notifier.connect(state.device),
                  onDisconnect: () => notifier.disconnect(state.device),
                  onEdit: () {
                    // TODO: Open edit modal
                  },
                  onDelete: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Device?'),
                        content: Text('Are you sure you want to delete "${state.device.alias}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              notifier.deleteDevice(state.device.id);
                              Navigator.pop(context);
                            },
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Open add device modal
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
