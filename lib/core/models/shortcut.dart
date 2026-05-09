import 'package:hive/hive.dart';

part 'shortcut.g.dart';

@HiveType(typeId: 1)
class Shortcut {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String icon;

  @HiveField(3)
  final String commandTemplate;

  @HiveField(4)
  final bool isGlobal;

  Shortcut({
    required this.id,
    required this.name,
    required this.icon,
    required this.commandTemplate,
    this.isGlobal = false,
  });

  Shortcut copyWith({
    String? id,
    String? name,
    String? icon,
    String? commandTemplate,
    bool? isGlobal,
  }) {
    return Shortcut(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      commandTemplate: commandTemplate ?? this.commandTemplate,
      isGlobal: isGlobal ?? this.isGlobal,
    );
  }
}
