import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestNotificationsJIT() async {
    final status = await Permission.notification.status;
    if (status.isGranted) return true;
    final res = await Permission.notification.request();
    return res.isGranted;
  }
}

