import 'dart:io';

import 'package:fastadb/core/models/shortcut.dart';
import 'package:fastadb/core/repositories/shortcut_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late ShortcutRepository repository;

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp(
      'fastadb_hive_shortcuts_',
    );
    Hive.init(dir.path);
    Hive.registerAdapter(ShortcutAdapter());
  });

  setUp(() async {
    if (!Hive.isBoxOpen('shortcuts')) {
      await Hive.openBox<Shortcut>('shortcuts');
    }
    await Hive.box<Shortcut>('shortcuts').clear();
    repository = ShortcutRepository();
    await repository.init();
  });

  tearDownAll(() async {
    await Hive.close();
  });

  group('ShortcutRepository', () {
    test('create generates id and persists shortcut', () async {
      final saved = await repository.create(
        Shortcut(
          id: '',
          name: 'Shell',
          icon: 'terminal',
          commandTemplate: 'adb -s %DEVICE% shell',
          isGlobal: true,
        ),
      );

      expect(saved.id, isNotEmpty);
      expect(repository.getAll().single.name, 'Shell');
      expect(repository.isEmpty, isFalse);
    });

    test('update replaces existing shortcut', () async {
      await repository.create(
        Shortcut(
          id: 's1',
          name: 'Shell',
          icon: 'terminal',
          commandTemplate: 'adb shell',
        ),
      );

      await repository.update(
        Shortcut(
          id: 's1',
          name: 'Logcat',
          icon: 'list_alt',
          commandTemplate: 'adb logcat',
          isGlobal: true,
        ),
      );

      final saved = repository.getAll().single;
      expect(saved.name, 'Logcat');
      expect(saved.isGlobal, isTrue);
    });

    test('delete removes shortcut', () async {
      await repository.create(
        Shortcut(
          id: 's1',
          name: 'Shell',
          icon: 'terminal',
          commandTemplate: 'adb shell',
        ),
      );

      await repository.delete('s1');

      expect(repository.getAll(), isEmpty);
      expect(repository.isEmpty, isTrue);
    });
  });
}
