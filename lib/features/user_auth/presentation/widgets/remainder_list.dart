import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:med_sarathi/features/user_auth/presentation/widgets/reminder_card.dart';

class ReminderList extends StatelessWidget {
  final String? userId;

  const ReminderList({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection('reminders')
            .orderBy('timestamp', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading reminders'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reminders = snapshot.data?.docs ?? [];

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
              final data = reminders[i].data() as Map<String, dynamic>;
              return ReminderCard(
                title: data['medication'] ?? 'No medication',
                time: data['time'] ?? 'No time',
                dosage: data['dosage'] ?? 'No dosage',
              );
            },
          );
        },
      ),
    );
  }
}