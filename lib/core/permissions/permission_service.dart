import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestNotificationsJIT() async {
    final status = await Permission.notification.status;
    if (status.isGranted) return true;
    final res = await Permission.notification.request();
    return res.isGranted;
  }

  static Future<PermissionStatus> notificationStatus() async {
    return Permission.notification.status;
  }

  /// Solicita una lista de permisos en secuencia y devuelve el mapa con su resultado.
  static Future<Map<Permission, PermissionStatus>> requestMany(List<Permission> permissions) async {
    final results = <Permission, PermissionStatus>{};
    for (final p in permissions) {
      final status = await p.request();
      results[p] = status;
    }
    return results;
  }
}
