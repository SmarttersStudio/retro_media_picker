import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

///
/// Created by Sunil Kumar on 21-08-2020 02:01 PM.
///
class RetroPermissionHandler {
  static Future<bool> checkStoragePermission() async {
    ///
    /// in IOS storage permission is replace with photos check before proceeding
    ///
    final status = await Permission.storage.status;
    if (status.isGranted) {
      return true;
    } else if (status.isDenied || status.isUndetermined) {
      final result = await Permission.storage.request();
      if (result.isGranted) {
        return true;
      } else {
        throw PlatformException(
            message: 'Permission denied',
            details: 'User denied storage permission.',
            code: '504');
      }
    } else {
      throw PlatformException(
          message: 'Permission denied',
          details: 'User has denied storage permission.',
          code: '504');
    }
  }
}
