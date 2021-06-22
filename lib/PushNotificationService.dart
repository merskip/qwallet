import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class PushNotificationService {
  static const _platform =
      const MethodChannel('pl.merskip.qwallet/push_notification_service');

  Future<bool> isPermissionGranted() async {
    if (!Platform.isAndroid)
      return false;
    try {
      final result = await _platform.invokeMapMethod("isPermissionGranted");
      return result?["isPermissionGranted"] as bool;
    } on PlatformException catch (error) {
      throw (error);
    }
  }

  Future<bool> requestPermission() async {
    try {
      final result = await _platform.invokeMapMethod("requestPermission");
      return result?["isPermissionGranted"] as bool;
    } on PlatformException catch (error) {
      throw (error);
    }
  }

  Future<List<PushNotification>> getActivePushNotifications() async {
    try {
      final result =
          await _platform.invokeMapMethod("getActivePushNotifications");
      final notifications = result?["notifications"] as List;
      return notifications.map((item) {
        return PushNotification(
          item["id"],
          item["title"],
          item["text"],
          item["smallIcon"],
          item["largeIcon"],
        );
      }).toList();
    } on PlatformException catch (error) {
      throw (error);
    }
  }
}

class PushNotification {
  final String id;
  final String title;
  final String text;
  final Uint8List? smallIcon;
  final Uint8List? largeIcon;

  PushNotification(
    this.id,
    this.title,
    this.text,
    this.smallIcon,
    this.largeIcon,
  );
}
