import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String username;
  final String currentDate;

  const HomeHeader({
    super.key,
    required this.username,
    required this.currentDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, $username!',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          currentDate,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 16),
        const Divider(thickness: 1, height: 1),
      ],
    );
  }
}