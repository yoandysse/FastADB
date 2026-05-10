import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/models/shortcut.dart';
import '../core/repositories/shortcut_repository.dart';

final shortcutsProvider =
    AsyncNotifierProvider<ShortcutsNotifier, List<Shortcut>>(ShortcutsNotifier.new);

class ShortcutsNotifier extends AsyncNotifier<List<Shortcut>> {
  late ShortcutRepository _repo;

  static const _predefined = [
    (name: 'Shell', icon: 'terminal', cmd: 'adb -s %DEVICE% shell', global: true),
    (name: 'Logcat', icon: 'list_alt', cmd: 'adb -s %DEVICE% logcat', global: true),
    (name: 'File Manager', icon: 'folder', cmd: 'adb -s %DEVICE% shell ls /sdcard', global: false),
    (name: 'Screenshot', icon: 'photo_camera', cmd: 'adb -s %DEVICE% exec-out screencap -p > screen.png', global: false),
    (name: 'Reboot', icon: 'restart_alt', cmd: 'adb -s %DEVICE% reboot', global: false),
    (name: 'Install APK', icon: 'install_mobile', cmd: 'adb -s %DEVICE% install %APK%', global: false),
  ];

  @override
  Future<List<Shortcut>> build() async {
    _repo = ShortcutRepository();
    await _repo.init();
    if (_repo.isEmpty) {
      await _seedDefaults();
    }
    return _repo.getAll();
  }

  Future<void> _seedDefaults() async {
    for (final s in _predefined) {
      await _repo.create(Shortcut(
        id: const Uuid().v4(),
        name: s.name,
        icon: s.icon,
        commandTemplate: s.cmd,
        isGlobal: s.global,
      ));
    }
  }

  Future<void> addShortcut(Shortcut shortcut) async {
    final saved = await _repo.create(shortcut.copyWith(id: ''));
    state = AsyncData([...(state.value ?? []), saved]);
  }

  Future<void> updateShortcut(Shortcut shortcut) async {
    await _repo.update(shortcut);
    state = AsyncData(
      (state.value ?? []).map((s) => s.id == shortcut.id ? shortcut : s).toList(),
    );
  }

  Future<void> deleteShortcut(String id) async {
    await _repo.delete(id);
    state = AsyncData((state.value ?? []).where((s) => s.id != id).toList());
  }

  String resolveCommand(String template, {String? deviceSerial}) {
    return template.replaceAll('%DEVICE%', deviceSerial ?? '');
  }
}
