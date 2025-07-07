import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onNewSchedule;
  final VoidCallback onReschedule;

  const ActionButtons({
    super.key,
    required this.onNewSchedule,
    required this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlueAccent,
            foregroundColor: Colors.black,  // 👈 ensures text/icon stay black
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 5,
          ),
          onPressed: onNewSchedule,
          icon: const Icon(Icons.add),
          label: const Text("New Schedule"),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orangeAccent,
            foregroundColor: Colors.black,  // 👈 ensures text/icon stay black
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 5,
          ),
          onPressed: onReschedule,
          icon: const Icon(Icons.edit_calendar),
          label: const Text("Reschedule"),
        ),
      ],
    );
  }
}
