import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:med_sarathi/features/user_auth/presentation/widgets/medication_repository.dart';
import 'package:med_sarathi/features/user_auth/presentation/pages/home_page.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  final MedicationRepository _medicationRepo = MedicationRepository();
  BuildContext? _appContext;
  final platform = MethodChannel('med_sarthi/exact_alarm');

  // SharedPreferences keys
  static const String notificationPermissionRequestedKey =
      'notificationPermissionRequested';
  static const String exactAlarmPermissionRequestedKey =
      'exactAlarmPermissionRequested';

  void setContext(BuildContext context) {
    _appContext = context;
  }

  Future<void> initNotification() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    const initSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: initSettingsAndroid);

    await notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    final prefs = await SharedPreferences.getInstance();

    // Request notification permission (Android 13+)
    final permissionRequested =
        prefs.getBool(notificationPermissionRequestedKey) ?? false;
    if (!permissionRequested) {
      await _requestNotificationPermission();
      await prefs.setBool(notificationPermissionRequestedKey, true);
    }

    // Request exact alarm permission (Android 12+)
    final alarmPermissionRequested =
        prefs.getBool(exactAlarmPermissionRequestedKey) ?? false;
    if (!alarmPermissionRequested) {
      if (_appContext != null) {
        await _showAlarmPermissionPrompt(_appContext!);
        await prefs.setBool(exactAlarmPermissionRequestedKey, true);
      }
    }

    _isInitialized = true;
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'med_sarthi_channel',
        'MedSarthi Reminders',
        channelDescription: 'Reminder notifications for MedSarathi app',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('med_reminder'), // make sure med_reminder.mp3 exists under android/app/src/main/res/raw/
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction('mark_taken', 'Taken',
              showsUserInterface: true),
          AndroidNotificationAction('reschedule', 'Reschedule',
              showsUserInterface: true),
        ],
      ),
    );
  }

  Future<void> showNotification({
    required int id,
    String? title,
    String? body,
  }) async {
    await notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails(),
      payload: id.toString(),
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduleDate =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduleDate,
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: id.toString(),
    );
  }

  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }

  Future<void> openExactAlarmSettings() async {
    try {
      await platform.invokeMethod('openExactAlarmSettings');
    } on PlatformException catch (e) {
      print("⚠️ Failed to open exact alarm settings: '${e.message}'.");
    }
  }

  Future<bool> _androidNotificationPermissionNeeded() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 33;
    }
    return false;
  }

  Future<void> _requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final needsPermission = await _androidNotificationPermissionNeeded();
      if (needsPermission) {
        final status = await Permission.notification.request();
        if (!status.isGranted) {
          print("⚠️ User denied notification permission.");
        }
      }
    }
  }

  Future<void> _showAlarmPermissionPrompt(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Allow Exact Alarm Permission"),
          content: const Text(
              "To ensure you receive timely medication reminders, please allow the app to set exact alarms."),
          actions: [
            TextButton(
              child: const Text("Deny"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Allow"),
              onPressed: () async {
                Navigator.of(context).pop();
                await openExactAlarmSettings();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleNotificationResponse(NotificationResponse response) async {
    final reminderId = response.payload;
    if (reminderId == null) return;

    if (response.actionId == 'mark_taken') {
      await _medicationRepo.markAsTaken(reminderId);
      await cancelNotification(reminderId.hashCode);

      // ✅ Bring app to HomePage so stream resumes
      if (_appContext != null) {
        Navigator.pushAndRemoveUntil(
          _appContext!,
          MaterialPageRoute(builder: (_) => const HomePage()),
              (route) => false,
        );
      }
    }

    if (response.actionId == 'reschedule') {
      if (_appContext != null) {
        final selectedTime = await showTimePicker(
          context: _appContext!,
          initialTime: TimeOfDay.now(),
        );
        if (selectedTime != null) {
          final newDateTime = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            selectedTime.hour,
            selectedTime.minute,
          );

          await _medicationRepo.rescheduleReminder(
            reminderId,
            newTime: newDateTime,
            medicineName: 'Medicine',
          );

          await cancelNotification(reminderId.hashCode);
          await scheduleNotification(
            id: reminderId.hashCode,
            title: "Medication Reminder",
            body: "Rescheduled to ${selectedTime.format(_appContext!)}.",
            hour: selectedTime.hour,
            minute: selectedTime.minute,
          );

          // ✅ Bring app to HomePage
          Navigator.pushAndRemoveUntil(
            _appContext!,
            MaterialPageRoute(builder: (_) => const HomePage()),
                (route) => false,
          );
        }
      }
    }
  }

//Centralized Notification Scheduler
//   Future<void> scheduleAllReminders(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
//     await initNotification();
//     for (var doc in docs) {
//       final data = doc.data();
//       final timeParts = (data['time'] as String).split(':');
//       final hour = int.tryParse(timeParts[0]) ?? 0;
//       final minute = int.tryParse(timeParts[1]) ?? 0;
//       final String medName = data['medication'] ?? 'Medicine';
//       final int reminderId = data['reminderId'] ?? doc.id.hashCode;
//
//       await scheduleNotification(
//         id: reminderId,
//         title: 'Medication Reminder',
//         body: 'Please take your $medName now!',
//         hour: hour,
//         minute: minute,
//       );
//     }
//   }

}
