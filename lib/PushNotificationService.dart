import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PushNotificationService {
  static const _platform =
      const MethodChannel('pl.merskip.qwallet/push_notification_service');

  Future<List<PushNotification>> getActivePushNotifications() async {
    try {
      final result =
          await _platform.invokeMapMethod("getActivePushNotifications");
      final notifications = result["notifications"] as List;
      return notifications.map((item) {
        return PushNotification(
          item["id"],
          item["title"],
          item["text"],
          item["smallIcon"],
          item["largeIcon"],
        );
      }).toList();
    } on PlatformException catch (_) {
      return null;
    }
  }
}

class PushNotification {
  final String id;
  final String title;
  final String text;
  final Uint8List smallIcon;
  final Uint8List largeIcon;

  PushNotification(
      this.id, this.title, this.text, this.smallIcon, this.largeIcon);
}
