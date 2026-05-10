// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConnectionTypeAdapter extends TypeAdapter<ConnectionType> {
  @override
  final int typeId = 3;

  @override
  ConnectionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ConnectionType.wifi;
      case 1:
        return ConnectionType.usb;
      default:
        return ConnectionType.wifi;
    }
  }

  @override
  void write(BinaryWriter writer, ConnectionType obj) {
    switch (obj) {
      case ConnectionType.wifi:
        writer.writeByte(0);
        break;
      case ConnectionType.usb:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
