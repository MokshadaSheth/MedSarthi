import 'package:flutter/material.dart';

class HomeDrawer extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final VoidCallback onProfilePressed;
  final VoidCallback onLogoutPressed;

  const HomeDrawer({
    super.key,
    required this.userData,
    required this.onProfilePressed,
    required this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              userData?['username'] ?? 'User',
              style: const TextStyle(fontSize: 18),
            ),
            accountEmail: Text(
              userData?['email'] ?? 'No email',
              style: const TextStyle(fontSize: 14),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                userData?['username']?.toString().isNotEmpty == true
                    ? userData!['username'][0].toUpperCase()
                    : 'U',
                style: const TextStyle(fontSize: 40, color: Colors.blueGrey),
              ),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: onProfilePressed,
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: onLogoutPressed,
          ),
        ],
      ),
    );
  }
}