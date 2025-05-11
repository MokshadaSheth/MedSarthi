import 'package:flutter/material.dart';
import 'package:med_sarathi/features/user_auth/presentation/pages/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1), // Med Blue
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
