import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BirthdayService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const platform = MethodChannel('com.program.ucgul1/notifications');

  Future<void> initialize() async {
    try {
      final bool result = await platform.invokeMethod('initializeNotifications');
      print('Notification initialization result: $result');
    } on PlatformException catch (e) {
      print('Failed to initialize notifications: ${e.message}');
    }
  }

  Future<List<Map<String, dynamic>>> getUpcomingBirthdays() async {
    final now = DateTime.now();
    final tenDaysLater = now.add(Duration(days: 10));

    QuerySnapshot snapshot = await _firestore.collection('users').get();
    List<Map<String, dynamic>> upcomingBirthdays = [];

    for (var doc in snapshot.docs) {
      final userData = doc.data() as Map<String, dynamic>;
      final dogumStr = userData['dogum'];
      if (dogumStr != null && dogumStr is String && dogumStr.isNotEmpty) {
        try {
          final birthday = DateFormat('dd.MM.yyyy').parse(dogumStr);
          var nextBirthday = DateTime(
            now.year,
            birthday.month,
            birthday.day,
          );
          // Eğer bu yılki doğum günü geçtiyse, gelecek yılınkini kontrol et
          if (nextBirthday.isBefore(now)) {
            nextBirthday = nextBirthday.add(Duration(days: 365));
          }
          // 10 gün içinde olan doğum günlerini kontrol et
          if (nextBirthday.isAfter(now.subtract(Duration(days: 1))) &&
              nextBirthday.isBefore(tenDaysLater)) {
            upcomingBirthdays.add({
              ...userData,
              'nextBirthday': nextBirthday,
              'id': doc.id,
            });
          }
        } catch (e) {
          // Hatalı tarih formatı, logla veya yut
          continue;
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
    final tomorrow = DateTime(now.year, now.month, now.day + 1); // Yarın
    final tenDaysLater = now.add(Duration(days: 10));

    QuerySnapshot snapshot = await _firestore.collection('users').get();

    for (var doc in snapshot.docs) {
      final userData = doc.data() as Map<String, dynamic>;
      final dogumStr = userData['dogum'];

      if (dogumStr != null && dogumStr is String && dogumStr.isNotEmpty) {
        try {
          final birthday = DateFormat('dd.MM.yyyy').parse(dogumStr);
          var nextBirthday = DateTime(now.year, birthday.month, birthday.day);

          // Eğer doğum günü bu yıl geçtiyse, bir sonraki yılın doğum günü
          if (nextBirthday.isBefore(now)) {
            nextBirthday = DateTime(now.year + 1, birthday.month, birthday.day);
          }

          // Yarın kontrolü: Eğer doğum günü yarınsa
          if (nextBirthday.isAtSameMomentAs(tomorrow)) {
            _showNotification(
              '🎂 Yaklaşan Doğum Günü',
              '${userData['name']} ${userData['surname']}\'in doğum günü yarın!',
              durationSeconds: 3,
            );
          }
          // Bugün doğum günü kontrolü: Eğer doğum günü bugünse
          else if (nextBirthday.isAtSameMomentAs(now)) {
            _showNotification(
              '🎉 Bugün Doğum Günü',
              '${userData['name']} ${userData['surname']}\'in doğum günü bugün!',
              durationSeconds: 3,
            );
          }
        } catch (e) {
          // Hatalı tarih formatı, logla veya yut
          continue;
        }
      }
    }
  }


  Future<void> _showNotification(String title, String body, {int durationSeconds = 3}) async {
    try {
      await platform.invokeMethod('showNotification', {
        'title': title,
        'body': body,
        'id': DateTime.now().millisecondsSinceEpoch.remainder(100000),
        'duration': durationSeconds,
      });
    } on PlatformException catch (e) {
      print('Failed to show notification: e.message}');
    }
  }
}
