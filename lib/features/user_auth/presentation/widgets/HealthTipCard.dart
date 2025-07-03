import 'package:flutter/material.dart';

class HealthTipCard extends StatelessWidget {
  const HealthTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> tips = [
      "Drink a glass of water with every medicine you take 💧",
      "Don’t skip breakfast — it keeps you energized 🌞",
      "A 10-minute walk after meals aids digestion 🚶",
      "Keep your phone away 30 mins before sleeping 😴",
      "Smile more often — it boosts immunity 😊",
      "Eat seasonal fruits for better health 🍎🍊",
      "Avoid screens while eating — be mindful 🍽️",
      "Practice deep breathing for stress relief 🧘",
      "Stay hydrated, aim for 8 glasses daily 🚰",
      "Sleep at least 7 hours to stay healthy 🌙",
      "Stretch for 5 minutes every morning 🧘‍♂️",
      "Wash your hands before meals 🧼",
      "Limit fried and oily foods 🍟",
      "Read something positive before bed 📖",
      "Include green veggies in daily meals 🥬",
      "Take short standing breaks if sitting long 🪑",
      "Use stairs instead of lifts when possible 🏃",
      "Keep healthy snacks like fruits handy 🍓",
      "Don’t skip routine health checkups 🏥",
      "Listen to calming music for relaxation 🎵",
      "Practice gratitude every evening 🙏",
      "Use sunscreen before stepping outdoors 🌞",
      "Clean your phone screen daily 📱",
      "Chew your food slowly, savor each bite 🍽️",
      "Take deep breaths when feeling anxious 🌬️",
      "Avoid caffeine post evening ☕",
      "Spend 5 minutes in fresh air daily 🌳",
      "Replace sugary drinks with lemon water 🍋",
      "Keep your posture straight while sitting 🪑",
      "End your day with positive thoughts ✨",
    ];


    final todayIndex = DateTime.now().day % tips.length;
    final tipOfTheDay = tips[todayIndex];

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "💡 Health Tip of the Day",
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              tipOfTheDay,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSecondaryContainer,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
