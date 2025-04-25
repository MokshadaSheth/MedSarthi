import 'package:flutter/material.dart';
import 'package:med_sarathi/constants/colors.dart';

class ReminderCard extends StatelessWidget {
  final String title;
  final String time;
  final String dosage;

  const ReminderCard({
    super.key,
    required this.title,
    required this.time,
    required this.dosage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Time: $time'),
                Text('Dosage: $dosage'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
