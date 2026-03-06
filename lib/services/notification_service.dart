import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin notificationPlugin =
    FlutterLocalNotificationsPlugin();

/// Handles local notifications for timer completion
class NotificationService {
  static const int _timerNotificationId = 0;

  /// Request notification permissions (iOS)
  static Future<void> requestPermissions() async {
    await notificationPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, sound: true, badge: false);
  }

  /// Schedule notification for when timer completes
  static Future<void> scheduleTimerNotification(int secondsFromNow) async {
    await cancelTimerNotification();
    await notificationPlugin.zonedSchedule(
      _timerNotificationId,
      "⏰ Time's Up!",
      "Your Little Blue Truck timer has finished!",
      tz.TZDateTime.now(tz.local).add(Duration(seconds: secondsFromNow)),
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: false,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel any pending timer notification
  static Future<void> cancelTimerNotification() async {
    await notificationPlugin.cancel(_timerNotificationId);
  }
}
