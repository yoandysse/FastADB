// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeviceAdapter extends TypeAdapter<Device> {
  @override
  final int typeId = 0;

  @override
  Device read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Device(
      id: fields[0] as String,
      alias: fields[1] as String,
      host: fields[2] as String?,
      port: fields[3] as int?,
      serial: fields[4] as String?,
      type: fields[5] as ConnectionType,
      autoReconnect: fields[6] as bool,
      shortcutIds: (fields[7] as List).cast<String>(),
      lastConnected: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Device obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.alias)
      ..writeByte(2)
      ..write(obj.host)
      ..writeByte(3)
      ..write(obj.port)
      ..writeByte(4)
      ..write(obj.serial)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.autoReconnect)
      ..writeByte(7)
      ..write(obj.shortcutIds)
      ..writeByte(8)
      ..write(obj.lastConnected);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
