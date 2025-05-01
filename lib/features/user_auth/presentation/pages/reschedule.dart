import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReschedulePage extends StatefulWidget {
  const ReschedulePage({super.key});

  @override
  State<ReschedulePage> createState() => _ReschedulePageState();
}

class _ReschedulePageState extends State<ReschedulePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<QuerySnapshot> _remindersStream;
  bool _isLoading = true;
  String? _errorMessage;
  bool _indexError = false;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  void _loadReminders() {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = "User not authenticated";
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _indexError = false;
    });

    try {
      // Modified query to avoid the index requirement
      _remindersStream = _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('reminders')
          .where('isActive', isEqualTo: true)
          .snapshots();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load reminders";
        _indexError = e.toString().contains('index');
      });
    }
  }

  String _formatTime(String timeString) {
    try {
      final time = TimeOfDay(
        hour: int.parse(timeString.split(':')[0]),
        minute: int.parse(timeString.split(':')[1]),
      );
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
      return DateFormat.jm().format(dt);
    } catch (e) {
      return timeString;
    }
  }

  Future<void> _rescheduleReminder(String docId, String currentTime) async {
    final currentTimeOfDay = TimeOfDay(
      hour: int.parse(currentTime.split(':')[0]),
      minute: int.parse(currentTime.split(':')[1]),
    );

    final newTime = await showTimePicker(
      context: context,
      initialTime: currentTimeOfDay,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (newTime != null) {
      final user = _auth.currentUser;
      if (user == null) return;

      final newTimeString = '${newTime.hour}:${newTime.minute}';

      try {
        await _firestore
            .collection('Users')
            .doc(user.uid)
            .collection('reminders')
            .doc(docId)
            .update({
          'time': newTimeString,
          'timestamp': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reminder rescheduled to ${_formatTime(newTimeString)}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error rescheduling: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reschedule Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReminders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            if (_indexError) ...[
              const SizedBox(height: 20),
              const Text('Index needs to be created in Firestore'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // You can launch the URL from the error message here
                  // or guide users to create the index
                },
                child: const Text('Create Index'),
              ),
            ],
          ],
        ),
      )
          : StreamBuilder<QuerySnapshot>(
        stream: _remindersStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reminders = snapshot.data?.docs ?? [];
          if (reminders.isEmpty) {
            return const Center(
              child: Text('No active reminders found'),
            );
          }

          // Sort reminders by time locally
          reminders.sort((a, b) {
            final aTime = (a.data() as Map<String, dynamic>)['time'];
            final bTime = (b.data() as Map<String, dynamic>)['time'];
            return aTime.compareTo(bTime);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final doc = reminders[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data['medication'] ?? 'No medication',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.blueAccent),
                            onPressed: () => _rescheduleReminder(
                                doc.id, data['time']),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Time: ${_formatTime(data['time'])}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dosage: ${data['dosage'] ?? 'Not specified'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (data['notes']?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Notes: ${data['notes']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}