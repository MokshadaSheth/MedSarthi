import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'medication_channel',
          channelName: 'Medication Reminders',
          channelDescription: 'Notifications for medication schedules',
          defaultColor: Colors.blue,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          soundSource: 'resource://raw/alert_sound',
        )
      ],
    );
  }

  Future<void> scheduleMedicationNotification({
    required String reminderId,
    required String time,
    required String medicationName,
  }) async {
    try {
      final timeParts = time.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final now = DateTime.now();
      final scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: reminderId.hashCode,
          channelKey: 'medication_channel',
          title: 'Medication Reminder',
          body: 'Time to take $medicationName',
          payload: {'reminderId': reminderId},
          notificationLayout: NotificationLayout.Default,
        ),
        schedule: NotificationCalendar.fromDate(date: scheduledTime),
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      rethrow;
    }
  }

  Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  Future<void> triggerSOSNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: -1,
        channelKey: 'medication_channel',
        title: 'EMERGENCY ALERT',
        body: 'Help is on the way!',
        payload: {'type': 'sos'},
      ),
    );
  }
}