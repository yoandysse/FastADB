import 'dart:io';

import 'package:fastadb/core/models/connection_status.dart';
import 'package:fastadb/core/models/device.dart';
import 'package:fastadb/core/repositories/device_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late DeviceRepository repository;

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('fastadb_hive_devices_');
    Hive.init(dir.path);
    Hive.registerAdapter(DeviceAdapter());
    Hive.registerAdapter(ConnectionTypeAdapter());
  });

  setUp(() async {
    if (!Hive.isBoxOpen('devices')) {
      await Hive.openBox<Device>('devices');
    }
    await Hive.box<Device>('devices').clear();
    repository = DeviceRepository();
    await repository.init();
  });

  tearDownAll(() async {
    await Hive.close();
  });

  group('DeviceRepository', () {
    test('create generates id and persists device', () async {
      final saved = await repository.create(
        Device(
          id: '',
          alias: 'Pixel',
          host: '192.168.1.10',
          port: 5555,
          type: ConnectionType.wifi,
        ),
      );

      expect(saved.id, isNotEmpty);
      expect(repository.getById(saved.id)?.alias, 'Pixel');
      expect(repository.count(), 1);
    });

    test('update and delete change persisted state', () async {
      final saved = await repository.create(
        Device(id: 'd1', alias: 'Phone', type: ConnectionType.usb),
      );

      await repository.update(saved.copyWith(alias: 'Phone renamed'));
      expect(repository.getById('d1')?.alias, 'Phone renamed');

      await repository.delete('d1');
      expect(repository.getById('d1'), isNull);
      expect(repository.count(), 0);
    });

    test('filters by type and auto reconnect', () async {
      await repository.create(
        Device(
          id: 'wifi',
          alias: 'WiFi',
          type: ConnectionType.wifi,
          autoReconnect: true,
        ),
      );
      await repository.create(
        Device(id: 'usb', alias: 'USB', type: ConnectionType.usb),
      );

      expect(repository.getByType('wifi').single.id, 'wifi');
      expect(repository.getAutoReconnectDevices().single.id, 'wifi');
    });

    test('clear removes all devices', () async {
      await repository.create(
        Device(id: 'd1', alias: 'Phone', type: ConnectionType.usb),
      );

      await repository.clear();

      expect(repository.getAll(), isEmpty);
    });
  });
}
