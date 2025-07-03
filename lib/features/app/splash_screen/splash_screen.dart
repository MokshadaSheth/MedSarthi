import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:med_sarathi/features/user_auth/presentation/pages/login_page.dart';
import 'package:med_sarathi/features/user_auth/presentation/pages/home_page.dart';
import 'package:med_sarathi/features/user_auth/presentation/pages/noti_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _startApp();
  }

  void _startApp() async {
    _notificationService.setContext(context);
    print("📌 Context set for notification service.");

    await _notificationService.initNotification();

    await Future.delayed(const Duration(seconds: 3));

    final User? user = FirebaseAuth.instance.currentUser;

    if (mounted) {
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.medication, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              'MedSarthi',
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Your Medicine Reminder Companion',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            )
          ],
        ),
      ),
    );
  }
}
