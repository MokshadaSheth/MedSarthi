import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReschedulePage extends StatefulWidget {
  const ReschedulePage({super.key});
  @override
  State<ReschedulePage> createState() => _ReschedulePageState();
}

class _ReschedulePageState extends State<ReschedulePage> {
  List<Map<String, dynamic>> reminders = [
    {
      'title': 'B12 Drops',
      'time': TimeOfDay(hour: 6, minute: 13),
      'dosage': '5 Drops, 1200mg',
    },
    {
      'title': 'Vitamin D',
      'time': TimeOfDay(hour: 7, minute: 0),
      'dosage': '1 Capsule, 1000mg',
    },
  ];

  String formatTime(TimeOfDay t) {
    final now = DateTime.now();
    final dt  = DateTime(now.year, now.month, now.day, t.hour, t.minute);
    return DateFormat.jm().format(dt);
  }

  void _reschedule(int idx) async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: reminders[idx]['time'],
    );
    if (newTime != null) {
      setState(() => reminders[idx]['time'] = newTime);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${reminders[idx]['title']} rescheduled to ${formatTime(newTime)}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reschedule Reminder')),
      body: ListView.builder(
        itemCount: reminders.length,
        itemBuilder: (ctx, i) {
          final r = reminders[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            elevation: 3,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(r['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Time: ${formatTime(r['time'])}'),
                  Text('Dosage: ${r['dosage']}'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.schedule, color: Colors.orangeAccent),
                onPressed: () => _reschedule(i),
              ),
            ),
          );
        },
      ),
    );
  }
}
