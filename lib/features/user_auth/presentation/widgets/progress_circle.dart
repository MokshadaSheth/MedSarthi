import 'package:flutter/material.dart';


class ProgressCircle extends StatelessWidget {
  final String dayName;
  final int completed;
  final int total;

  const ProgressCircle({
    super.key,
    required this.dayName,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0;

    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: progress.toDouble(),
                  strokeWidth: 10,
                  backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('INTAKES', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('$completed / $total', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 4),
                  Text(dayName, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(thickness: 1, height: 1),
        ],
      ),
    );
  }
}
