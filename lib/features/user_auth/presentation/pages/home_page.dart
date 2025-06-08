import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:med_sarathi/features/user_auth/presentation/pages/add_reminder_page.dart';
import 'package:med_sarathi/features/user_auth/presentation/pages/reschedule.dart';
import 'package:med_sarathi/features/user_auth/presentation/pages/profile_page.dart';
import 'package:med_sarathi/features/user_auth/presentation/widgets/home_header.dart';
import 'package:med_sarathi/features/user_auth/presentation/widgets/progress_circle.dart';
import 'package:med_sarathi/features/user_auth/presentation/widgets/action_buttons.dart';
import 'package:med_sarathi/features/user_auth/presentation/widgets/remainder_list.dart';
import 'package:med_sarathi/features/user_auth/presentation/widgets/floating_buttons.dart';
import 'package:med_sarathi/features/user_auth/presentation/widgets/home_drawer.dart';
import 'package:med_sarathi/features/user_auth/presentation/widgets/medication_repository.dart';
import 'package:med_sarathi/features/user_auth/presentation/widgets/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;
  late final MedicationRepository _medicationRepository;
  // late final NotificationService _notificationService;

  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  int _completedMeds = 0;
  int _totalMeds = 0;

  @override
  void initState() {
    super.initState();
    _medicationRepository = MedicationRepository();
    // _notificationService = NotificationService();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
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
  }

  Future<void> _initializeApp() async {
    try {
      // await _notificationService.initialize();
      await _loadUserData();
      await _loadMedicationCounts();
    } catch (e) {
      debugPrint('Initialization error: $e');
      // Handle error appropriately
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadUserData() async {
    _userData = await _medicationRepository.getUserData();
  }

  Future<void> _loadMedicationCounts() async {
    try {
      final remindersSnapshot = await _medicationRepository.getReminders();

      setState(() {
        _totalMeds = remindersSnapshot.docs.length;
        _completedMeds = remindersSnapshot.docs
            .where((doc) =>
        (doc.data() as Map<String, dynamic>)['status']?.toString().toLowerCase() == 'taken')
            .length;
      });
    } catch (e) {
      debugPrint('Error loading medication counts: $e');
      setState(() {
        _totalMeds = 0;
        _completedMeds = 0;
      });
    }
  }


  Future<void> _showMedicationDialog(String reminderId) async {
    final reminderDoc = await _medicationRepository.getReminders();
    final doc = reminderDoc.docs.firstWhere(
          (doc) => doc.id == reminderId,
      orElse: () => throw Exception('Reminder not found'),
    );

    final data = doc.data() as Map<String, dynamic>;
    final theme = Theme.of(context);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Time for ${data['medication']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Dosage: ${data['dosage']}'),
            const SizedBox(height: 10),
            Text('Scheduled Time: ${data['time']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _markAsTaken(reminderId);
            },
            child: Text('Mark Taken', style: TextStyle(color: theme.colorScheme.primary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _rescheduleReminder(reminderId, data['time']);
            },
            child: Text('Reschedule', style: TextStyle(color: theme.colorScheme.secondary)),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsTaken(String reminderId) async {
    try {
      await _medicationRepository.markAsTaken(reminderId);
      if (mounted) {
        setState(() => _completedMeds++);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Medication marked as taken'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _rescheduleReminder(String reminderId, String oldTime) async {
    final timeParts = oldTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    if (!mounted) return;

    final newTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (newTime != null) {
      final newTimeStr = '${newTime.hour}:${newTime.minute}';

      try {
        await _medicationRepository.rescheduleReminder(
          reminderId,
          newTime: newTimeStr,
        );

        // await _notificationService.cancelNotification(reminderId.hashCode);
        // await _notificationService.scheduleMedicationNotification(
        //   reminderId: reminderId,
        //   time: newTimeStr,
        //   medicationName: 'your medication', // You might want to pass the actual name
        // );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Rescheduled to $newTimeStr'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  void _showSOSDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Emergency SOS", style: theme.textTheme.headlineSmall),
        content: Text("Are you sure you want to trigger SOS?",
            style: theme.textTheme.bodyLarge),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: theme.colorScheme.error)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              // await _notificationService.triggerSOSNotification();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("SOS Triggered! Help is on the way!"),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                );
              }
            },
            child: Text("Confirm", style: TextStyle(color: theme.colorScheme.onPrimary)),
          ),
        ],
      ),
    );
  }

  void _navigateToReschedule() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ReschedulePage()));
  }

  void _navigateToAddReminder() {
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
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final theme = Theme.of(context);
    final currentDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());
    final dayName = DateFormat('EEEE').format(DateTime.now());

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      drawer: HomeDrawer(
        userData: _userData,
        onProfilePressed: _navigateToProfile,
        onLogoutPressed: _logout,
      ),
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: Text('MedSarthi', style: theme.textTheme.headlineSmall?.copyWith(
          color: theme.colorScheme.onPrimary,
        )),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: theme.colorScheme.onPrimary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: theme.colorScheme.onPrimary),
            onPressed: () {
              // Navigate to notifications page
            },
          ),
          GestureDetector(
            onTap: _navigateToProfile,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                backgroundColor: theme.colorScheme.secondary,
                child: Text(
                  _userData?['username']?.toString().isNotEmpty == true
                      ? _userData!['username'][0].toUpperCase()
                      : 'U',
                  style: TextStyle(color: theme.colorScheme.onSecondary),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SlideTransition(
            position: _slideAnimation,
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
                  completed: _completedMeds,
                  total: _totalMeds,
                ),
                const SizedBox(height: 20),
                ActionButtons(
                  onNewSchedule: _navigateToAddReminder,
                  onReschedule: _navigateToReschedule,
                ),
                const SizedBox(height: 20),
                Text(
                  'Upcoming Reminders',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                // Text
                const SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>
                    (
                    stream: _medicationRepository.getRemindersStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No reminders found'));
                      }

                      return ReminderList(
                        reminders: snapshot.data!.docs,
                        onMedicationTaken: _markAsTaken,
                        onReschedule: _rescheduleReminder,
                      );

                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingButtons(
        onSOSPressed: _showSOSDialog,
        onAddReminderPressed: _navigateToAddReminder,
      ),
    );
  }
}