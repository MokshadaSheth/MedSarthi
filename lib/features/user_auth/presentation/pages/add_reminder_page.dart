import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:med_sarathi/themes/theme_provider.dart';

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
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).colorScheme.background,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _errorMessage = "User not authenticated");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _firestore
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
      });

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _errorMessage = "Error saving reminder: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Medication Name*',
                  labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                  prefixIcon: Icon(Icons.medical_services, color: colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
              ),
              const SizedBox(height: 20),

              // Dosage
              TextFormField(
                controller: _dosageController,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Dosage*',
                  labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                  prefixIcon: Icon(Icons.medication, color: colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
              ),
              const SizedBox(height: 20),

              // Time Picker
              TextFormField(
                controller: _timeController,
                style: TextStyle(color: colorScheme.onSurface),
                readOnly: true,
                onTap: () => _pickTime(context),
                decoration: InputDecoration(
                  labelText: 'Time*',
                  labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                  prefixIcon: Icon(Icons.access_time, color: colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
              ),
              const SizedBox(height: 20),

              // Notes
              TextFormField(
                controller: _notesController,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Notes (optional)',
                  labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                  prefixIcon: Icon(Icons.note, color: colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 30),

              // Error message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: colorScheme.error, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _saveReminder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Save Reminder',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
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