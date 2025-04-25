import 'package:flutter/material.dart';
import 'package:med_sarathi/features/user_auth/presentation/widgets/custom_button.dart';
import 'package:med_sarathi/features/user_auth/presentation/widgets/custom_textfield.dart';
import 'package:med_sarathi/constants/colors.dart';

class AddReminderPage extends StatelessWidget {
  const AddReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Reminder')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const CustomTextField(
              hintText: 'Medication Name',
              icon: Icons.medical_services,
            ),
            const SizedBox(height: 20),
            const CustomTextField(
              hintText: 'Dosage',
              icon: Icons.medication,
            ),
            const SizedBox(height: 20),
            const CustomTextField(
              hintText: 'Time',
              icon: Icons.access_time,
            ),
            const SizedBox(height: 20),
            const CustomTextField(
              hintText: 'Notes (optional)',
              icon: Icons.note,
              maxLines: 3,
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: 'Save Reminder',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
