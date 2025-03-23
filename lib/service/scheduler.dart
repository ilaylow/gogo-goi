import 'dart:math';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:goi/service/log.dart';

import 'notification.dart';

class AlarmManager {
  static void initialize() async {
    bool result = await AndroidAlarmManager.initialize();
    if (result) {
      logInfo("Alarm Manager has successfully started!");
    }

    scheduleRepeatingNotification();
  }

  static Future<void> scheduleRepeatingNotification() async {
    // Schedule the alarm to fire once every hour
    await AndroidAlarmManager.periodic(
      const Duration(minutes: 60),
      0, // ID for this specific alarm
      fireNotification,
      wakeup: false,
      exact: true,
      allowWhileIdle: true,
    );
  }

  static void fireNotification() async {
    List<String> notificationMessages = ["漢字の練習をしょう！", "漢字の勉強を忘れないで！", "漢字の読み方を復習しよう！"];

    logInfo("Sending notification!");

    DateTime now = DateTime.now();
    if (now.hour > 0 && now.hour < 9) {
      logInfo("Not going to send notifications past 12am...");
    } else {
      int id = Random().nextInt(10000);
      await NotificationService().showNotification(id, "Kanji Test", notificationMessages[Random().nextInt(3)], "dummy_payload");
    }
  }
}