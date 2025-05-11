import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:med_sarathi/themes/theme_provider.dart';

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
  final Map<String, TextEditingController> _editControllers = {};

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  @override
  void dispose() {
    // Dispose all edit controllers
    _editControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
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

  Future<void> _showEditDialog(Map<String, dynamic> data, String docId) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Initialize controllers if not already done
    if (!_editControllers.containsKey(docId)) {
      _editControllers[docId] = TextEditingController(text: data['medication']);
    }
    if (!_editControllers.containsKey('${docId}_dosage')) {
      _editControllers['${docId}_dosage'] = TextEditingController(text: data['dosage']);
    }
    if (!_editControllers.containsKey('${docId}_notes')) {
      _editControllers['${docId}_notes'] = TextEditingController(text: data['notes'] ?? '');
    }

    TimeOfDay? selectedTime;
    try {
      final timeParts = data['time'].split(':');
      selectedTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    } catch (e) {
      selectedTime = TimeOfDay.now();
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Reminder', style: theme.textTheme.headlineSmall),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _editControllers[docId],
                      decoration: InputDecoration(
                        labelText: 'Medication',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _editControllers['${docId}_dosage'],
                      decoration: InputDecoration(
                        labelText: 'Dosage',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime ?? TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() => selectedTime = time);
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Time',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              selectedTime?.format(context) ?? 'Select time',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _editControllers['${docId}_notes'],
                      decoration: InputDecoration(
                        labelText: 'Notes (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: theme.textTheme.bodyLarge),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  onPressed: () async {
                    await _updateReminder(
                      docId,
                      _editControllers[docId]!.text,
                      _editControllers['${docId}_dosage']!.text,
                      selectedTime!,
                      _editControllers['${docId}_notes']!.text,
                    );
                    if (mounted) Navigator.pop(context);
                  },
                  child: Text('Save', style: theme.textTheme.bodyLarge),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateReminder(
      String docId,
      String medication,
      String dosage,
      TimeOfDay time,
      String notes,
      ) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('reminders')
          .doc(docId)
          .update({
        'medication': medication,
        'dosage': dosage,
        'time': '${time.hour}:${time.minute}',
        'notes': notes,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reminder updated successfully'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating reminder: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
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
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error rescheduling: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteReminder(String docId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('reminders')
          .doc(docId)
          .delete();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reminder deleted successfully'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting reminder: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reschedule Reminders',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onPrimary,
          ),
        ),
        backgroundColor: colorScheme.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.onPrimary),
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
            return Center(
              child: Text(
                'No active reminders found',
                style: theme.textTheme.bodyLarge,
              ),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data['medication'] ?? 'No medication',
                            style: theme.textTheme.titleLarge,
                          ),
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert, color: colorScheme.primary),
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditDialog(data, doc.id);
                              } else if (value == 'time') {
                                _rescheduleReminder(doc.id, data['time']);
                              } else if (value == 'delete') {
                                _deleteReminder(doc.id);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit Details'),
                              ),
                              PopupMenuItem(
                                value: 'time',
                                child: Text('Change Time'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Time: ${_formatTime(data['time'])}',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dosage: ${data['dosage'] ?? 'Not specified'}',
                        style: theme.textTheme.bodyLarge,
                      ),
                      if (data['notes']?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Notes: ${data['notes']}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
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