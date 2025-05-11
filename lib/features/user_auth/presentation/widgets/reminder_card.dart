import 'package:flutter/material.dart';

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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoItem(context, Icons.access_time, time),
                const SizedBox(width: 16),
                _buildInfoItem(context, Icons.medication, dosage),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}