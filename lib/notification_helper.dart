import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'main_channel',
          'Main Channel',
          channelDescription: 'Channel for meeting/task reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> scheduleMultipleNotifications({
    required int id,
    required String title,
    required String body,
    required DateTime startTime,
    required DateTime endTime,
    required String status,
  }) async {
    // 2 hours before
    await scheduleNotification(
      id: id,
      title: title,
      body: '$body dans 2 heures.',
      scheduledTime: startTime.subtract(const Duration(hours: 2)),
    );
    // At start
    await scheduleNotification(
      id: id + 1,
      title: title,
      body: '$body commence maintenant.',
      scheduledTime: startTime,
    );
    // At end, only if not "terminer"
    if (status != 'terminer') {
      await scheduleNotification(
        id: id + 2,
        title: title,
        body: '$body est terminé. Veuillez mettre à jour le statut.',
        scheduledTime: endTime,
      );
    }
  }

  static Future<void> requestPermissions(BuildContext context) async {
    if (Platform.isAndroid) {
      if (await Permission.notification.isDenied) {
        final status = await Permission.notification.request();
        if (!status.isGranted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Permission requise'),
              content: const Text("Veuillez autoriser les notifications dans les paramètres de l'application pour recevoir des rappels."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
  }
}
