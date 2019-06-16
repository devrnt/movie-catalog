import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<void> requestPermission(PermissionGroup permission) async {
    await PermissionHandler().requestPermissions([permission]);
  }

  static Future<bool> checkPermission(PermissionGroup permission) async {
    PermissionStatus permissionStatus =
        await PermissionHandler().checkPermissionStatus(permission);
    return permissionStatus == PermissionStatus.granted;
  }
}
