import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/device.dart';
import '../core/models/connection_status.dart';
import '../core/repositories/device_repository.dart';
import '../core/services/adb_service.dart';
import 'tools_config_provider.dart';

class DeviceState {
  final Device device;
  final ConnectionStatus status;

  const DeviceState({required this.device, required this.status});

  DeviceState copyWith({Device? device, ConnectionStatus? status}) {
    return DeviceState(
      device: device ?? this.device,
      status: status ?? this.status,
    );
  }
}

final deviceRepositoryProvider = Provider((ref) => DeviceRepository());

final devicesProvider =
    StateNotifierProvider<DevicesNotifier, AsyncValue<List<DeviceState>>>((ref) {
  final repository = ref.watch(deviceRepositoryProvider);
  final toolsConfig = ref.watch(toolsConfigProvider);
  return DevicesNotifier(repository, toolsConfig);
});

class DevicesNotifier extends StateNotifier<AsyncValue<List<DeviceState>>> {
  final DeviceRepository _repository;
  final AsyncValue<dynamic> _toolsConfig;

  Timer? _pollingTimer;
  AdbService? _adbService;

  DevicesNotifier(this._repository, this._toolsConfig)
      : super(const AsyncValue.loading()) {
    _init();
  }

  List<DeviceState> get _currentList =>
      state.maybeWhen(data: (l) => l, orElse: () => []);

  void _setState(List<DeviceState> list) => state = AsyncValue.data(list);

  Future<void> _init() async {
    try {
      await _repository.init();
      await _initAdbService();
      await _loadDevices();
      startPolling();
      await _handleAutoReconnect();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> _initAdbService() async {
    final config = _toolsConfig.maybeWhen(data: (c) => c, orElse: () => null);
    if (config != null && config.adbPath.isNotEmpty) {
      _adbService = AdbService(adbPath: config.adbPath);
      await _adbService!.startServer();
    }
  }

  Future<void> _loadDevices() async {
    final devices = _repository.getAll();
    _setState(devices.map((d) => DeviceState(device: d, status: ConnectionStatus.offline)).toList());

    for (int i = 0; i < devices.length; i++) {
      final status = await _getDeviceStatus(devices[i]);
      final list = [..._currentList];
      if (i < list.length) {
        list[i] = list[i].copyWith(status: status);
        _setState(list);
      }
    }
  }

  Future<ConnectionStatus> _getDeviceStatus(Device device) async {
    if (_adbService == null) return ConnectionStatus.offline;
    try {
      final s = await _adbService!.getDeviceState(device.serial ?? '');
      if (s == 'device') return ConnectionStatus.connected;
      if (s == 'unauthorized') return ConnectionStatus.error;
      return ConnectionStatus.offline;
    } catch (_) {
      return ConnectionStatus.error;
    }
  }

  Future<void> addDevice(Device device) async {
    try {
      final newDevice = await _repository.create(device);
      _setState([..._currentList, DeviceState(device: newDevice, status: ConnectionStatus.offline)]);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateDevice(Device device) async {
    try {
      await _repository.update(device);
      _setState(_currentList.map((s) {
        return s.device.id == device.id ? s.copyWith(device: device) : s;
      }).toList());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteDevice(String id) async {
    try {
      await _repository.delete(id);
      _setState(_currentList.where((s) => s.device.id != id).toList());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> connect(Device device) async {
    if (_adbService == null) return;
    try {
      final result = await _adbService!.connect(device.host ?? '', device.port ?? 5555);
      if (result.success) {
        await updateDevice(device.copyWith(lastConnected: DateTime.now()));
        _setDeviceStatus(device.id, ConnectionStatus.connected);
      } else {
        _setDeviceStatus(device.id, ConnectionStatus.error);
      }
    } catch (_) {}
  }

  Future<void> disconnect(Device device) async {
    if (_adbService == null) return;
    try {
      await _adbService!.disconnect(device.serial ?? '');
      _setDeviceStatus(device.id, ConnectionStatus.offline);
    } catch (_) {}
  }

  void _setDeviceStatus(String id, ConnectionStatus status) {
    _setState(_currentList.map((s) {
      return s.device.id == id ? s.copyWith(status: status) : s;
    }).toList());
  }

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 8), (_) => _refreshAllDevices());
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _refreshAllDevices() async {
    final list = [..._currentList];
    for (int i = 0; i < list.length; i++) {
      final status = await _getDeviceStatus(list[i].device);
      if (list[i].status != status) {
        list[i] = list[i].copyWith(status: status);
        _setState(list);
      }
    }
  }

  Future<void> _handleAutoReconnect() async {
    for (final device in _repository.getAutoReconnectDevices()) {
      if (device.host != null && device.port != null) {
        await connect(device);
      }
    }
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
