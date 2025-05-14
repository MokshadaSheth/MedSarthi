import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:med_sarathi/features/user_auth/presentation/widgets/reminder_card.dart';

class ReminderList extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> reminders;
  final void Function(String reminderId) onMedicationTaken;
  final void Function(String reminderId, String newTime) onReschedule;

  const ReminderList({
    Key? key,
    required this.reminders,
    required this.onMedicationTaken,
    required this.onReschedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (reminders.isEmpty) {
      return const Center(
        child: Text(
          'No reminders found\nAdd a new schedule!',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      itemCount: reminders.length,
      itemBuilder: (ctx, i) {
        final data = reminders[i].data();
        final id = reminders[i].id;

        return ReminderCard(
          title: data['medication'] ?? 'No medication',
          time: data['time'] ?? 'No time',
          dosage: data['dosage'] ?? 'No dosage',
          onTaken: () => onMedicationTaken(id),
          onReschedule: (newTime) => onReschedule(id, newTime),
        );
      },
    );
  }
}
