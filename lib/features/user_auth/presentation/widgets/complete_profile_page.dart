// complete_profile_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _relativeNameController = TextEditingController();
  final _relativePhoneController = TextEditingController();
  final _relativeEmailController = TextEditingController();
  final _relativeRelationController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _relativeNameController.dispose();
    _relativePhoneController.dispose();
    _relativeEmailController.dispose();
    _relativeRelationController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
        'phone': _phoneController.text,
        'relative': {
          'name': _relativeNameController.text,
          'phone': _relativePhoneController.text,
          'email' : _relativeEmailController.text,
          'relation': _relativeRelationController.text,
        },
        'profileCompleted': true,
        'email': user.email,
      }, SetOptions(merge: true));

      // Navigate to home page after successful submission
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Your Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Your Phone Number*',
                  hintText: 'Enter your 10-digit phone number',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                    return 'Please enter a valid 10-digit number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Emergency Contact Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _relativeNameController,
                decoration: const InputDecoration(
                  labelText: 'Relative Name*',
                  hintText: 'Enter full name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter relative name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _relativePhoneController,
                decoration: const InputDecoration(
                  labelText: 'Relative Phone Number*',
                  hintText: 'Enter 10-digit phone number',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                    return 'Please enter a valid 10-digit number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _relativeEmailController,
                decoration: const InputDecoration(
                  labelText: 'Relative Email*',
                  hintText: 'Enter abc@gmail.com',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email id';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _relativeRelationController,
                decoration: const InputDecoration(
                  labelText: 'Relationship*',
                  hintText: 'E.g. Father, Mother, Son, Daughter',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter relationship';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}