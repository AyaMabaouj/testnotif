import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationManager {
  static final FlutterLocalNotificationsPlugin _notif =
      FlutterLocalNotificationsPlugin();

  static Future<void> init({bool scheduled = false}) async {
    var initAndroidSettings = AndroidInitializationSettings('mipmap/ic_launcher');
    var settings = InitializationSettings(android: initAndroidSettings);
    await _notif.initialize(settings);
  }

  static Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    await _notif.show(
      id,
      title,
      body,
      await notificationDetails(),
      payload: payload,
    );
  }

  static Future<NotificationDetails> notificationDetails() async {
    var androidDetails = AndroidNotificationDetails(
      'channel id',
      'channel name',
      importance: Importance.max,
      playSound: false,
      sound: RawResourceAndroidNotificationSound('alert'),
    );
   
    return NotificationDetails(android: androidDetails,);
  }
}
