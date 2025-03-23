import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:goi/pages/kanji_practice.dart';
import 'package:goi/pages/loading.dart';
import 'package:goi/service/db.dart';
import 'package:goi/service/log.dart';

import '../main.dart';


/* This class will manage the display and control of sending notifications and the response when a user reacts to a notification.
*  Ideally, this class should provide two functions, showNotification() and selectNotification().
* */
class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);

    await createNotificationChannels();
  }

  Future<void> createNotificationChannels() async {
    logInfo("Creating Notification Channels...");
    const AndroidNotificationChannel callChannel = AndroidNotificationChannel(
      'kanji', // channel ID
      'kanji_name', // channel name
      description: 'Kanji Test Notification Channel',
      playSound: true,
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('jack'),
    );

    var platformSpecificPluginImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    logInfo(platformSpecificPluginImplementation as Object);
    await platformSpecificPluginImplementation?.createNotificationChannel(callChannel);
  }

  Future selectNotification(String? payload) async {
    // Handle navigation on tap
    if (payload != null) {
      // Ensure app has initialized and navigatorKey is accessible
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.push(MaterialPageRoute(builder: (_) => KanjiPracticeLoadingScreen()));
        }
      });
    }
  }

  Future<void> showNotification(int id, String title, String body, String payload) async {
    const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
            'kanji', 'kanji_name',
            channelDescription: 'Kanji Test Notification Channel',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'Kanji Practice Time!'));

    await flutterLocalNotificationsPlugin.show(
        id, title, body, notificationDetails, payload: payload);
  }
}