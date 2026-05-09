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

  const DeviceState({
    required this.device,
    required this.status,
  });

  DeviceState copyWith({
    Device? device,
    ConnectionStatus? status,
  }) {
    return DeviceState(
      device: device ?? this.device,
      status: status ?? this.status,
    );
  }
}

final deviceRepositoryProvider = Provider((ref) => DeviceRepository());

final devicesProvider = StateNotifierProvider<DevicesNotifier, AsyncValue<List<DeviceState>>>((ref) {
  final repository = ref.watch(deviceRepositoryProvider);
  final toolsConfig = ref.watch(toolsConfigProvider);

  return DevicesNotifier(repository, toolsConfig, ref);
});

class DevicesNotifier extends StateNotifier<AsyncValue<List<DeviceState>>> {
  final DeviceRepository _repository;
  final AsyncValue<dynamic> _toolsConfig;
  final Ref _ref;

  Timer? _pollingTimer;
  AdbService? _adbService;

  DevicesNotifier(
    this._repository,
    this._toolsConfig,
    this._ref,
  ) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      await _repository.init();
      await _initAdbService();

      // Load initial devices
      await _loadDevices();

      // Start polling
      startPolling();

      // Handle auto-reconnect
      await _handleAutoReconnect();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> _initAdbService() async {
    final toolsConfig = _toolsConfig.maybeWhen(
      data: (config) => config,
      orElse: () => null,
    );

    if (toolsConfig != null && toolsConfig.adbPath.isNotEmpty) {
      _adbService = AdbService(adbPath: toolsConfig.adbPath);
      await _adbService!.startServer();
    }
  }

  Future<void> _loadDevices() async {
    final devices = _repository.getAll();
    final states = devices.map((d) => DeviceState(device: d, status: ConnectionStatus.offline)).toList();

    state = AsyncValue.data(states);

    // Fetch initial status for each device
    for (int i = 0; i < states.length; i++) {
      final status = await _getDeviceStatus(states[i].device);
      final currentList = (state as AsyncValue<List<DeviceState>>).maybeWhen(
        data: (list) => list,
        orElse: () => <DeviceState>[],
      );

      if (currentList.isNotEmpty && i < currentList.length) {
        final updated = currentList.toList();
        updated[i] = updated[i].copyWith(status: status);
        state = AsyncValue.data(updated);
      }
    }
  }

  Future<ConnectionStatus> _getDeviceStatus(Device device) async {
    if (_adbService == null) return ConnectionStatus.offline;

    try {
      final state = await _adbService!.getDeviceState(device.serial ?? '');

      if (state == 'device') {
        return ConnectionStatus.connected;
      } else if (state == 'unauthorized') {
        return ConnectionStatus.error;
      } else if (state == 'offline') {
        return ConnectionStatus.offline;
      }

      return ConnectionStatus.offline;
    } catch (e) {
      return ConnectionStatus.error;
    }
  }

  Future<void> addDevice(Device device) async {
    try {
      final newDevice = await _repository.create(device);
      final currentList = (state as AsyncValue<List<DeviceState>>).maybeWhen(
        data: (list) => list,
        orElse: () => <DeviceState>[],
      );

      final updatedList = [...currentList, DeviceState(device: newDevice, status: ConnectionStatus.offline)];
      state = AsyncValue.data(updatedList);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateDevice(Device device) async {
    try {
      await _repository.update(device);
      final currentList = (state as AsyncValue<List<DeviceState>>).maybeWhen(
        data: (list) => list,
        orElse: () => <DeviceState>[],
      );

      final updatedList = currentList.map((state) {
        if (state.device.id == device.id) {
          return state.copyWith(device: device);
        }
        return state;
      }).toList();

      state = AsyncValue.data(updatedList);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteDevice(String id) async {
    try {
      await _repository.delete(id);
      final currentList = (state as AsyncValue<List<DeviceState>>).maybeWhen(
        data: (list) => list,
        orElse: () => <DeviceState>[],
      );

      final updatedList = currentList.where((state) => state.device.id != id).toList();
      state = AsyncValue.data(updatedList);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> connect(Device device) async {
    if (_adbService == null) return;

    try {
      final host = device.host ?? '';
      final port = device.port ?? 5555;

      final result = await _adbService!.connect(host, port);

      if (result.success) {
        final updated = device.copyWith(lastConnected: DateTime.now());
        await updateDevice(updated);

        final currentList = (state as AsyncValue<List<DeviceState>>).maybeWhen(
          data: (list) => list,
          orElse: () => <DeviceState>[],
        );

        final newList = currentList.map((state) {
          if (state.device.id == device.id) {
            return state.copyWith(status: ConnectionStatus.connected);
          }
          return state;
        }).toList();

        state = AsyncValue.data(newList);
      } else {
        final currentList = (state as AsyncValue<List<DeviceState>>).maybeWhen(
          data: (list) => list,
          orElse: () => <DeviceState>[],
        );

        final newList = currentList.map((state) {
          if (state.device.id == device.id) {
            return state.copyWith(status: ConnectionStatus.error);
          }
          return state;
        }).toList();

        state = AsyncValue.data(newList);
      }
    } catch (e) {
      // silently fail
    }
  }

  Future<void> disconnect(Device device) async {
    if (_adbService == null) return;

    try {
      final serial = device.serial ?? '';
      await _adbService!.disconnect(serial);

      final currentList = (state as AsyncValue<List<DeviceState>>).maybeWhen(
        data: (list) => list,
        orElse: () => <DeviceState>[],
      );

      final newList = currentList.map((state) {
        if (state.device.id == device.id) {
          return state.copyWith(status: ConnectionStatus.offline);
        }
        return state;
      }).toList();

      state = AsyncValue.data(newList);
    } catch (e) {
      // silently fail
    }
  }

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      _refreshAllDevices();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _refreshAllDevices() async {
    final currentList = (state as AsyncValue<List<DeviceState>>).maybeWhen(
      data: (list) => list,
      orElse: () => <DeviceState>[],
    );

    for (int i = 0; i < currentList.length; i++) {
      final status = await _getDeviceStatus(currentList[i].device);

      if (currentList[i].status != status) {
        final newList = currentList.toList();
        newList[i] = newList[i].copyWith(status: status);
        state = AsyncValue.data(newList);
      }
    }
  }

  Future<void> _handleAutoReconnect() async {
    final autoReconnectDevices = _repository.getAutoReconnectDevices();

    for (final device in autoReconnectDevices) {
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
