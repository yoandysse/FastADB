// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shortcut.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShortcutAdapter extends TypeAdapter<Shortcut> {
  @override
  final int typeId = 1;

  @override
  Shortcut read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Shortcut(
      id: fields[0] as String,
      name: fields[1] as String,
      icon: fields[2] as String,
      commandTemplate: fields[3] as String,
      isGlobal: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Shortcut obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.commandTemplate)
      ..writeByte(4)
      ..write(obj.isGlobal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShortcutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
