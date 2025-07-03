import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FloatingButtons extends StatelessWidget {

  final VoidCallback onAddReminderPressed;

  const FloatingButtons({
    super.key,
    required this.onAddReminderPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor,
            heroTag: "addReminder",
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: onAddReminderPressed,
          ),
        ),
      ],
    );
  }
}