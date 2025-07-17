import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BirthdayService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<List<Map<String, dynamic>>> getUpcomingBirthdays() async {
    final now = DateTime.now();
    final oneWeekLater = now.add(Duration(days: 7));
    
    QuerySnapshot snapshot = await _firestore.collection('users').get();
    List<Map<String, dynamic>> upcomingBirthdays = [];

    for (var doc in snapshot.docs) {
      final userData = doc.data() as Map<String, dynamic>;
      if (userData['dogum'] != null) {
        final birthday = DateFormat('dd.MM.yyyy').parse(userData['dogum']);
        final nextBirthday = DateTime(
          now.year,
          birthday.month,
          birthday.day,
        );

        // Eğer bu yılki doğum günü geçtiyse, gelecek yılınkini kontrol et
        if (nextBirthday.isBefore(now)) {
          nextBirthday.add(Duration(days: 365));
        }

        // Bir hafta içinde olan doğum günlerini kontrol et
        if (nextBirthday.isAfter(now.subtract(Duration(days: 1))) &&
            nextBirthday.isBefore(oneWeekLater)) {
          upcomingBirthdays.add({
            ...userData,
            'nextBirthday': nextBirthday,
            'id': doc.id,
          });
        }
      }
    }

    // Tarihe göre sırala
    upcomingBirthdays.sort((a, b) => 
      (a['nextBirthday'] as DateTime).compareTo(b['nextBirthday'] as DateTime));

    return upcomingBirthdays;
  }

  Future<void> checkAndSendBirthdayNotifications() async {
    final now = DateTime.now();
    QuerySnapshot snapshot = await _firestore.collection('users').get();

    for (var doc in snapshot.docs) {
      final userData = doc.data() as Map<String, dynamic>;
      if (userData['dogum'] != null) {
        final birthday = DateFormat('dd.MM.yyyy').parse(userData['dogum']);
        final nextBirthday = DateTime(
          now.year,
          birthday.month,
          birthday.day,
        );

        // Doğum günü yarın ise
        if (nextBirthday.difference(now).inDays == 1) {
          _showNotification(
            '🎂 Yaklaşan Doğum Günü',
            '${userData['name']} ${userData['surname']}\'in doğum günü yarın!',
          );
        }
        // Doğum günü bugün ise
        else if (birthday.month == now.month && birthday.day == now.day) {
          _showNotification(
            '🎉 Bugün Doğum Günü',
            '${userData['name']} ${userData['surname']}\'in doğum günü bugün!',
          );
        }
      }
    }
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'birthday_channel',
      'Doğum Günü Bildirimleri',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
