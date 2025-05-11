import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:med_sarathi/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const ProfilePage({super.key, required this.userData});

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final username = userData?['username'] ?? 'User';
    final email = userData?['email'] ?? 'No email';
    final phone = userData?['phone']?.toString().isNotEmpty == true
        ? userData!['phone']
        : 'Not provided';
    final authProvider = userData?['authProvider'] ?? 'email';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Add edit profile functionality here
            },
          ),
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () {
              themeProvider.toggleTheme(!(themeProvider.themeMode == ThemeMode.dark));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              username,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 30),
            _buildInfoCard(context, Icons.phone, 'Phone', phone),
            const SizedBox(height: 10),
            _buildInfoCard(
              context,
              _getProviderIcon(authProvider),
              'Login Method',
              _formatAuthProvider(authProvider),
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _signOut(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, IconData icon, String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getProviderIcon(String provider) {
    switch (provider) {
      case 'google':
        return Icons.g_mobiledata;
      case 'email':
        return Icons.email;
      default:
        return Icons.person;
    }
  }

  String _formatAuthProvider(String provider) {
    switch (provider) {
      case 'google':
        return 'Google';
      case 'email':
        return 'Email/Password';
      default:
        return provider;
    }
  }
}