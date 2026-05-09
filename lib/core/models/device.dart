import 'package:hive/hive.dart';
import 'connection_status.dart';

part 'device.g.dart';

@HiveType(typeId: 0)
class Device {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String alias;

  @HiveField(2)
  final String? host;

  @HiveField(3)
  final int? port;

  @HiveField(4)
  final String? serial;

  @HiveField(5)
  final ConnectionType type;

  @HiveField(6)
  final bool autoReconnect;

  @HiveField(7)
  final List<String> shortcutIds;

  @HiveField(8)
  final DateTime? lastConnected;

  Device({
    required this.id,
    required this.alias,
    this.host,
    this.port,
    this.serial,
    required this.type,
    this.autoReconnect = false,
    this.shortcutIds = const [],
    this.lastConnected,
  });

  Device copyWith({
    String? id,
    String? alias,
    String? host,
    int? port,
    String? serial,
    ConnectionType? type,
    bool? autoReconnect,
    List<String>? shortcutIds,
    DateTime? lastConnected,
  }) {
    return Device(
      id: id ?? this.id,
      alias: alias ?? this.alias,
      host: host ?? this.host,
      port: port ?? this.port,
      serial: serial ?? this.serial,
      type: type ?? this.type,
      autoReconnect: autoReconnect ?? this.autoReconnect,
      shortcutIds: shortcutIds ?? this.shortcutIds,
      lastConnected: lastConnected ?? this.lastConnected,
    );
  }
}

class UsbDevice {
  final String serial;
  final String? model;
  final String? androidVersion;
  final ConnectionStatus status;

  UsbDevice({
    required this.serial,
    this.model,
    this.androidVersion,
    this.status = ConnectionStatus.offline,
  });

  UsbDevice copyWith({
    String? serial,
    String? model,
    String? androidVersion,
    ConnectionStatus? status,
  }) {
    return UsbDevice(
      serial: serial ?? this.serial,
      model: model ?? this.model,
      androidVersion: androidVersion ?? this.androidVersion,
      status: status ?? this.status,
    );
  }
}
