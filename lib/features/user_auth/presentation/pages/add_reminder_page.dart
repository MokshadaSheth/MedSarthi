import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:med_sarathi/features/user_auth/presentation/pages/noti_service.dart'; // <--- add this import

class AddReminderPage extends StatefulWidget {
  const AddReminderPage({super.key});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  final _formKey = GlobalKey<FormState>();
  final _medicationController = TextEditingController();
  final _dosageController = TextEditingController();
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _errorMessage;
  bool _isLoading = false;
  TimeOfDay? _selectedTime;

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar("User not authenticated", isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final docRef = await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('reminders')
          .add({
        'medication': _medicationController.text.trim(),
        'dosage': _dosageController.text.trim(),
        'time': _timeController.text.trim(),
        'notes': _notesController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'isActive': true,
        'status': 'pending',
      });

      // Schedule notification
      final timeParts = _timeController.text.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      await NotificationService().scheduleNotification(
        id: docRef.id.hashCode,
        title: 'Medication Reminder',
        body: 'Please take your ${_medicationController.text.trim()} now!',
        hour: hour,
        minute: minute,
      );

      if (mounted) {
        _showSnackBar("Reminder added and notification scheduled successfully!");

        // Optionally: Clear form after save
        _formKey.currentState!.reset();
        _timeController.clear();
        _selectedTime = null;

        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar("Failed to save reminder: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
      ),
    );
  }


  @override
  void dispose() {
    _medicationController.dispose();
    _dosageController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Reminder',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: colorScheme.onPrimary,
          ),
        ),
        elevation: 0,
        backgroundColor: colorScheme.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Medication Name
              TextFormField(
                controller: _medicationController,
                decoration: InputDecoration(labelText: 'Medication Name*'),
                validator: (value) =>
                value?.isEmpty ?? true ? 'Required field' : null,
              ),
              const SizedBox(height: 20),

              // Dosage
              TextFormField(
                controller: _dosageController,
                decoration: InputDecoration(labelText: 'Dosage*'),
                validator: (value) =>
                value?.isEmpty ?? true ? 'Required field' : null,
              ),
              const SizedBox(height: 20),

              // Time Picker
              TextFormField(
                controller: _timeController,
                readOnly: true,
                onTap: () => _pickTime(context),
                decoration: InputDecoration(labelText: 'Time*'),
                validator: (value) =>
                value?.isEmpty ?? true ? 'Required field' : null,
              ),
              const SizedBox(height: 20),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 30),

              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _saveReminder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Save Reminder',
                  style: TextStyle(
                    color: Colors.white, // 👈 white text color here
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
