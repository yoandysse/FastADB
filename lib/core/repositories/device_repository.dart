import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/device.dart';

class DeviceRepository {
  static const String _boxName = 'devices';

  late Box<Device> _box;

  Future<void> init() async {
    _box = Hive.box<Device>(_boxName);
  }

  Future<Device> create(Device device) async {
    final id = device.id.isEmpty ? const Uuid().v4() : device.id;
    final newDevice = device.copyWith(id: id);

    await _box.put(newDevice.id, newDevice);
    return newDevice;
  }

  Device? getById(String id) {
    return _box.get(id);
  }

  List<Device> getAll() {
    return _box.values.toList();
  }

  Future<void> update(Device device) async {
    await _box.put(device.id, device);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> clear() async {
    await _box.clear();
  }

  int count() {
    return _box.length;
  }

  List<Device> getByType(String type) {
    return _box.values.where((d) => d.type.toString().contains(type)).toList();
  }

  List<Device> getAutoReconnectDevices() {
    return _box.values.where((d) => d.autoReconnect).toList();
  }
}
