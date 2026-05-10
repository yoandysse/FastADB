import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/shortcut.dart';

class ShortcutRepository {
  static const String _boxName = 'shortcuts';

  late Box<Shortcut> _box;

  Future<void> init() async {
    _box = Hive.box<Shortcut>(_boxName);
  }

  List<Shortcut> getAll() => _box.values.toList();

  Future<Shortcut> create(Shortcut shortcut) async {
    final id = shortcut.id.isEmpty ? const Uuid().v4() : shortcut.id;
    final s = shortcut.copyWith(id: id);
    await _box.put(s.id, s);
    return s;
  }

  Future<void> update(Shortcut shortcut) async {
    await _box.put(shortcut.id, shortcut);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  bool get isEmpty => _box.isEmpty;
}
