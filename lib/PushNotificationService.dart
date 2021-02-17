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

  PushNotification(this.id, this.title, this.text);
}
