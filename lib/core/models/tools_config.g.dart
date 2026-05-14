// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tools_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ToolsConfigAdapter extends TypeAdapter<ToolsConfig> {
  @override
  final int typeId = 2;

  @override
  ToolsConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ToolsConfig(
      adbPath: fields[0] as String,
      scrcpyPath: fields[1] as String,
      autoReconnectOnStart: fields[2] as bool,
      startMinimized: fields[3] as bool,
      theme: fields[4] as String,
      verifiedAdbPath: fields[5] as String?,
      verifiedAdbVersion: fields[6] as String?,
      verifiedScrcpyPath: fields[7] as String?,
      verifiedScrcpyVersion: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ToolsConfig obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.adbPath)
      ..writeByte(1)
      ..write(obj.scrcpyPath)
      ..writeByte(2)
      ..write(obj.autoReconnectOnStart)
      ..writeByte(3)
      ..write(obj.startMinimized)
      ..writeByte(4)
      ..write(obj.theme)
      ..writeByte(5)
      ..write(obj.verifiedAdbPath)
      ..writeByte(6)
      ..write(obj.verifiedAdbVersion)
      ..writeByte(7)
      ..write(obj.verifiedScrcpyPath)
      ..writeByte(8)
      ..write(obj.verifiedScrcpyVersion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolsConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
