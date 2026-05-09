import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PermissionService {
  final FlutterLocalNotificationsPlugin notificationsPlugin;

  PermissionService(this.notificationsPlugin);

  Future<void> requestAll() async {
    await [
      Permission.location,
      Permission.phone,
    ].request();

    final android = notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await android?.requestNotificationsPermission();
  }
}
