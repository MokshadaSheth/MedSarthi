// home_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:med_sarathi/constants/colors.dart';
import 'package:med_sarathi/features/user_auth/presentation/widgets/reminder_card.dart';
import 'package:med_sarathi/features/user_auth/presentation/pages/add_reminder_page.dart';
import 'package:med_sarathi/features/user_auth/presentation/pages/reschedule.dart';
import 'package:med_sarathi/features/user_auth/presentation/pages/profile_page.dart';

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

  @override
  Widget build(BuildContext context) {
    final currentDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());
    final dayName = DateFormat('EEEE').format(DateTime.now());

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
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
                backgroundColor: Colors.blueGrey,
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
      drawer: _buildDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(currentDate),
              const SizedBox(height: 20),
              _buildProgressCircle(dayName),
              const SizedBox(height: 20),
              _buildActionButtons(),
              const SizedBox(height: 20),
              const Text(
                'Upcoming Reminders',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              _buildRemindersList(),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingButtons(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              _userData?['username'] ?? 'User',
              style: const TextStyle(fontSize: 18),
            ),
            accountEmail: Text(
              _userData?['email'] ?? 'No email',
              style: const TextStyle(fontSize: 14),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                _userData?['username']?.toString().isNotEmpty == true
                    ? _userData!['username'][0].toUpperCase()
                    : 'U',
                style: const TextStyle(fontSize: 40, color: Colors.blueGrey),
              ),
            ),
            decoration: const BoxDecoration(color: Colors.blueGrey),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfilePage(userData: _userData),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await _auth.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String currentDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, ${_userData?['username'] ?? 'User'}!',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        Text(
          currentDate,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.blueGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCircle(String dayName) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.grey.shade400, blurRadius: 10)],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(
                value: 0.5,
                strokeWidth: 12,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueGrey),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('INTAKES', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('0 / 2', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                Text(dayName, style: const TextStyle(fontSize: 14, color: Colors.blueGrey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlueAccent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 5,
          ),
          onPressed: _newScheduleReminder,
          icon: const Icon(Icons.add),
          label: const Text("New Schedule"),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orangeAccent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 5,
          ),
          onPressed: _rescheduleReminder,
          icon: const Icon(Icons.edit_calendar),
          label: const Text("Reschedule"),
        ),
      ],
    );
  }

  Widget _buildRemindersList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Users')
            .doc(_currentUser?.uid)
            .collection('reminders')
            .orderBy('timestamp', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading reminders'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reminders = snapshot.data?.docs ?? [];

          if (reminders.isEmpty) {
            return const Center(
              child: Text(
                'No reminders found\nAdd a new schedule!',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: reminders.length,
            itemBuilder: (ctx, i) {
              final data = reminders[i].data() as Map<String, dynamic>;
              return ReminderCard(
                title: data['medication'] ?? 'No medication',
                time: data['time'] ?? 'No time',
                dosage: data['dosage'] ?? 'No dosage',
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFloatingButtons() {
    return Stack(
      children: [
        Positioned(
          bottom: 80,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: Colors.redAccent,
            heroTag: "sos",
            child: const Icon(FontAwesomeIcons.solidBell, color: Colors.white),
            onPressed: _showSOSDialog,
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: Colors.amber,
            heroTag: "addReminder",
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: _newScheduleReminder,
          ),
        ),
      ],
    );
  }
}