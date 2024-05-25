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
      wakeup: true,
      exact: true,
      allowWhileIdle: true,
    );
  }

  static void fireNotification() async {
    List<String> notificationMessages = ["漢字はどれくらいわかるかなぁ？", "漢字の勉強も忘れたか？", "真面目に漢字を勉強してください"];

    logInfo("Sending notification!");

    DateTime now = DateTime.now();
    if (now.hour > 0 && now.hour < 9) {
      logInfo("Not going to send notifications past 2am...");
    } else {
      int id = Random().nextInt(10000);
      await NotificationService().showNotification(id, "Kanji Test", notificationMessages[Random().nextInt(2)], "dummy_payload");
    }
  }
}