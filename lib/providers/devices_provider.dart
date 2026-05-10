import 'dart:async';
import 'dart:io';
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

/// Provides the list of saved devices and manages their connection state.
///
/// Uses [ref.read] for both dependencies so that neither [deviceRepositoryProvider]
/// nor [toolsConfigProvider] state changes trigger a full notifier disposal +
/// recreation (which would wipe the device list from the UI on every config load).
/// [DevicesNotifier] reads config on demand through [Ref] instead.
final devicesProvider =
    StateNotifierProvider<DevicesNotifier, AsyncValue<List<DeviceState>>>((ref) {
  // ref.read (not ref.watch) — DeviceRepository is a stable singleton.
  // Watching it would cause this notifier to be recreated on hot reload,
  // resetting the device list before Hive finishes loading.
  final repository = ref.read(deviceRepositoryProvider);
  return DevicesNotifier(repository, ref);
});

class DevicesNotifier extends StateNotifier<AsyncValue<List<DeviceState>>> {
  final DeviceRepository _repository;
  final Ref _ref;

  Timer? _pollingTimer;
  AdbService? _cachedAdbService;
  String? _currentAdbPath;

  DevicesNotifier(this._repository, this._ref)
      : super(const AsyncValue.loading()) {
    _init();
  }

  List<DeviceState> get _currentList =>
      state.maybeWhen(data: (l) => l, orElse: () => []);

  void _setState(List<DeviceState> list) => state = AsyncValue.data(list);

  /// Returns the current ADB path from config, or null if not configured.
  /// Reads on demand so changes to [toolsConfigProvider] do NOT trigger
  /// a rebuild of [devicesProvider].
  AdbService? get _adb {
    final config = _ref
        .read(toolsConfigProvider)
        .maybeWhen(data: (c) => c, orElse: () => null);
    if (config == null || config.adbPath.isEmpty) return null;
    if (_currentAdbPath != config.adbPath) {
      _currentAdbPath = config.adbPath;
      _cachedAdbService = AdbService(adbPath: config.adbPath);
    }
    return _cachedAdbService;
  }

  /// ADB serial for a device — for WiFi devices it's always host:port.
  String _effectiveSerial(Device device) {
    if (device.serial != null && device.serial!.isNotEmpty) return device.serial!;
    if (device.host != null) return '${device.host}:${device.port ?? 5555}';
    return '';
  }

  Future<void> _init() async {
    try {
      await _repository.init();
      await _loadDevices();
      startPolling();
      // Try to start the server and auto-reconnect after initial load
      // so the UI isn't blocked on ADB availability.
      _adb?.startServer().then((_) => _handleAutoReconnect());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> _loadDevices() async {
    final devices = _repository.getAll();
    _setState(
        devices.map((d) => DeviceState(device: d, status: ConnectionStatus.offline)).toList());

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
    final adb = _adb;
    if (adb == null) return ConnectionStatus.offline;
    final serial = _effectiveSerial(device);
    if (serial.isEmpty) return ConnectionStatus.offline;
    try {
      final s = await adb.getDeviceState(serial);
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
    final adb = _adb;
    if (adb == null) return;
    try {
      final result = await adb.connect(device.host ?? '', device.port ?? 5555);
      if (result.success) {
        final serial = '${device.host}:${device.port ?? 5555}';
        await updateDevice(device.copyWith(
          lastConnected: DateTime.now(),
          serial: serial,
        ));
        _setDeviceStatus(device.id, ConnectionStatus.connected);
      } else {
        _setDeviceStatus(device.id, ConnectionStatus.error);
      }
    } catch (_) {}
  }

  Future<void> disconnect(Device device) async {
    final adb = _adb;
    if (adb == null) return;
    try {
      await adb.disconnect(_effectiveSerial(device));
      _setDeviceStatus(device.id, ConnectionStatus.offline);
    } catch (_) {}
  }

  Future<AdbResult?> runShortcut(Device device, String commandTemplate) async {
    final adb = _adb;
    if (adb == null) return AdbResult(success: false, error: 'ADB not configured');
    final serial = _effectiveSerial(device);
    if (serial.isEmpty) return AdbResult(success: false, error: 'No serial for device');
    return adb.runShortcutCommand(commandTemplate, serial);
  }

  Future<void> launchScrcpy(Device device) async {
    final config = _ref
        .read(toolsConfigProvider)
        .maybeWhen(data: (c) => c, orElse: () => null);
    if (config == null || config.scrcpyPath.isEmpty) return;
    final serial = _effectiveSerial(device);
    if (serial.isEmpty) return;
    try {
      await Process.start(
        config.scrcpyPath,
        ['-s', serial, '--window-title', device.alias],
        mode: ProcessStartMode.detached,
      );
    } catch (_) {}
  }

  void _setDeviceStatus(String id, ConnectionStatus status) {
    _setState(_currentList.map((s) {
      return s.device.id == id ? s.copyWith(status: status) : s;
    }).toList());
  }

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer =
        Timer.periodic(const Duration(seconds: 8), (_) => _refreshAllDevices());
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
