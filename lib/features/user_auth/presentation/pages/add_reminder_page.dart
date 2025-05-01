import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:med_sarathi/features/user_auth/presentation/widgets/custom_button.dart';
import 'package:med_sarathi/constants/colors.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Reminder'),
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _medicationController,
                decoration: InputDecoration(
                  labelText: 'Medication Name*',
                  prefixIcon: Icon(Icons.medical_services, color: AppColors.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _dosageController,
                decoration: InputDecoration(
                  labelText: 'Dosage*',
                  prefixIcon: Icon(Icons.medication, color: AppColors.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _timeController,
                decoration: InputDecoration(
                  labelText: 'Time*',
                  prefixIcon: Icon(Icons.access_time, color: AppColors.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes (optional)',
                  prefixIcon: Icon(Icons.note, color: AppColors.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                text: 'Save Reminder',
                onPressed: _saveReminder,
              ),
            ],
          ),
        ),
      ),
    );
  }
}