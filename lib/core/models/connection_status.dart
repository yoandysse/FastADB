import 'package:hive/hive.dart';

part 'connection_status.g.dart';

enum ConnectionStatus { connected, reconnecting, offline, error }

@HiveType(typeId: 3)
enum ConnectionType {
  @HiveField(0)
  wifi,
  @HiveField(1)
  usb,
}
