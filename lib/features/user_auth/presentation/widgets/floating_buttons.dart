import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FloatingButtons extends StatelessWidget {
  final VoidCallback onSOSPressed;
  final VoidCallback onAddReminderPressed;

  const FloatingButtons({
    super.key,
    required this.onSOSPressed,
    required this.onAddReminderPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 80,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: Colors.redAccent,
            heroTag: "sos",
            child: const Icon(FontAwesomeIcons.solidBell, color: Colors.white),
            onPressed: onSOSPressed,
          ),
        ),
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