import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MedSarathi Home'),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: const Center(
        child: Text(
          'Welcome to MedSarathi!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D47A1),
          ),
        ),
      ),
    );
  }
}
