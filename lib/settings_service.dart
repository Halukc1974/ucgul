import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SettingsService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showSystemMessage(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'system_channel',
      'Sistem Mesajları',
      channelDescription: 'Yaklaşan doğum günleri için sistem mesajları',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformChannelSpecifics,
    );
  }

  // Şifresiz giriş tercihini almak
  Future<bool> getPasswordlessPreference() async {
    String? passwordless = await _storage.read(key: 'passwordless');
    return passwordless != null && passwordless == 'true';
  }

  // Şifresiz giriş tercihini saklamak
  Future<void> setPasswordlessPreference(bool value) async {
    await _storage.write(key: 'passwordless', value: value ? 'true' : 'false');
  }
}
