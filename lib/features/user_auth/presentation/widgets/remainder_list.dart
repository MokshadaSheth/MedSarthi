import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:med_sarathi/features/user_auth/presentation/widgets/reminder_card.dart';
import 'package:provider/provider.dart';
import 'package:med_sarathi/features/user_auth/presentation/widgets/IntakeProgressProvider.dart';

DateTime parseReminderTime(String timeString) {
  try {
    if (timeString.contains('T')) {
      return DateTime.parse(timeString);
    } else if (timeString.contains(':')) {
      final parts = timeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    } else {
      return DateTime(2100);
    }
  } catch (e) {
    return DateTime(2100);
  }
}

String formatReminderTime(String timeString) {
  final dateTime = parseReminderTime(timeString);
  return DateFormat.jm().format(dateTime);
}

class ReminderList extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> reminders;
  final void Function(String reminderId) onMedicationTaken;
  final Future<void> Function(String, String, String) onReschedule;

  const ReminderList({
    Key? key,
    required this.reminders,
    required this.onMedicationTaken,
    required this.onReschedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (reminders.isEmpty) {
      Provider.of<IntakeProgressProvider>(context, listen: false).setProgress(0, 0);
      return const Center(
        child: Text('No reminders found\nAdd a new schedule!',
            textAlign: TextAlign.center),
      );
    }

    final sortedReminders = [...reminders];
    sortedReminders.sort((a, b) {
      final timeA = parseReminderTime(a.data()['time']);
      final timeB = parseReminderTime(b.data()['time']);
      return timeA.compareTo(timeB);
    });

    int completedCount = sortedReminders
        .where((r) => r.data()['status']?.toString().toLowerCase() == 'taken')
        .length;
    int totalCount = sortedReminders.length;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<IntakeProgressProvider>(context, listen: false)
          .setProgress(completedCount, totalCount);
    });

    return ListView.builder(
      itemCount: sortedReminders.length,
      itemBuilder: (ctx, i) {
        final data = sortedReminders[i].data();
        final id = sortedReminders[i].id;

        return ReminderCard(
          title: data['medication'] ?? 'No medication',
          time: formatReminderTime(data['time'] ?? ''),
          dosage: data['dosage'] ?? 'No dosage',
          onTaken: () => onMedicationTaken(id),
          onReschedule: (newTime) => onReschedule(id, newTime, ""),
        );
      },
    );
  }
}
