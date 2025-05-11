import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:med_sarathi/themes/theme_provider.dart';
import 'package:med_sarathi/features/user_auth/presentation/pages/add_reminder_page.dart';
import 'package:med_sarathi/features/user_auth/presentation/pages/reschedule.dart';
import 'package:med_sarathi/features/user_auth/presentation/pages/profile_page.dart';
import 'package:med_sarathi/features/user_auth/presentation/widgets/home_header.dart';
import 'package:med_sarathi/features/user_auth/presentation/widgets/progress_circle.dart';
import 'package:med_sarathi/features/user_auth/presentation/widgets/action_buttons.dart';
import 'package:med_sarathi/features/user_auth/presentation/widgets/remainder_list.dart';
import 'package:med_sarathi/features/user_auth/presentation/widgets/floating_buttons.dart';
import 'package:med_sarathi/features/user_auth/presentation/widgets/home_drawer.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  User? _currentUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      _currentUser = _auth.currentUser;
      if (_currentUser != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('Users')
            .doc(_currentUser!.uid)
            .get();
        if (userDoc.exists) {
          setState(() => _userData = userDoc.data() as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showSOSDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Emergency SOS"),
        content: const Text("Are you sure you want to trigger SOS?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("SOS Triggered! Help is on the way!")),
              );
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  void _rescheduleReminder() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ReschedulePage()));
  }

  void _newScheduleReminder() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AddReminderPage()));
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilePage(userData: _userData),
      ),
    );
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());
    final dayName = DateFormat('EEEE').format(DateTime.now());

    return Scaffold(
      drawer: HomeDrawer(
        userData: _userData,
        onProfilePressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProfilePage(userData: _userData),
            ),
          );
        },
        onLogoutPressed: () async {
          await _auth.signOut();
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
                (route) => false,
          );
        },
      ), // Add this line
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfilePage(userData: _userData)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  _userData?['username']?.toString().isNotEmpty == true
                      ? _userData!['username'][0].toUpperCase()
                      : 'U',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],

      ),

    backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(
                username: _userData?['username'] ?? 'User',
                currentDate: currentDate,
              ),
              const SizedBox(height: 20),
              ProgressCircle(
                dayName: dayName,
                completed: 0,
                total: 2,
              ),
              const SizedBox(height: 20),
              ActionButtons(
                onNewSchedule: _newScheduleReminder,
                onReschedule: _rescheduleReminder,
              ),
              const SizedBox(height: 20),
              Text(
                'Upcoming Reminders',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ReminderList(userId: _currentUser?.uid),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingButtons(
        onSOSPressed: _showSOSDialog,
        onAddReminderPressed: _newScheduleReminder,
      ),
    );
  }
}