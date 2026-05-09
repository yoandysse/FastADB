import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/tools_config.dart';
import '../core/services/tools_config_service.dart';

final toolsConfigServiceProvider = Provider((ref) => ToolsConfigService());

final toolsConfigProvider =
    StateNotifierProvider<ToolsConfigNotifier, AsyncValue<ToolsConfig>>((ref) {
  final service = ref.watch(toolsConfigServiceProvider);
  return ToolsConfigNotifier(service);
});

class ToolsConfigNotifier extends StateNotifier<AsyncValue<ToolsConfig>> {
  final ToolsConfigService _service;

  ToolsConfigNotifier(this._service) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final config = await _service.load();
      state = AsyncValue.data(config);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> saveConfig(ToolsConfig config) async {
    state = const AsyncValue.loading();
    try {
      await _service.save(config);
      state = AsyncValue.data(config);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<String?> autoDetectAdb() async {
    return await _service.autoDetectAdb();
  }

  Future<String?> autoDetectScrcpy() async {
    return await _service.autoDetectScrcpy();
  }

  Future<ToolsConfigService> getService() async {
    return _service;
  }
}
