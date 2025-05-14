import 'package:flutter/material.dart';

class ReminderCard extends StatelessWidget {
  final String title;
  final String time;
  final String dosage;

  final VoidCallback? onTaken;
  final void Function(String newTime)? onReschedule;

  const ReminderCard({
    super.key,
    required this.title,
    required this.time,
    required this.dosage,
    this.onTaken,
    this.onReschedule,
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
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: onTaken,
                  icon: const Icon(Icons.check),
                  label: const Text('Taken'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    // Dummy newTime input for simplicity. Replace with your own time picker if needed.
                    final now = TimeOfDay.now();
                    final newTime = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
                    onReschedule?.call(newTime);
                  },
                  icon: const Icon(Icons.schedule),
                  label: const Text('Reschedule'),
                ),
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
