import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

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
import 'package:med_sarathi/features/user_auth/presentation/pages/noti_service.dart';
import 'package:med_sarathi/features/user_auth/presentation/widgets/RemainingMedCard.dart';
import 'package:med_sarathi/features/user_auth/presentation/widgets/HealthTipCard.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;
  late final MedicationRepository _medicationRepository;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _reminderStream;

  late final StreamSubscription<
      QuerySnapshot<Map<String, dynamic>>> _reminderSubscription;


  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  int _completedMeds = 0;
  int _totalMeds = 0;

  @override
  void initState() {
    super.initState();
    _medicationRepository = MedicationRepository();
    _initializeAnimations();
    _initializeApp();
    _startReminderListener();
    _scheduleAllReminders();
    _reminderStream = _medicationRepository.getRemindersStream();
    WidgetsBinding.instance.addObserver(this);
    _subscribeToReminders();
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
      await _loadUserData();
      await _loadMedicationCounts();
      // await _scheduleAllReminders();
    } catch (e) {
      debugPrint('Initialization error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  void _startReminderListener() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    print("---------Inside Start Listener---------");
    _reminderSubscription = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('reminders')
        .where('status', isNotEqualTo: 'taken') // Only listen to active reminders
        .snapshots()
        .listen((snapshot) async {
      for (var change in snapshot.docChanges) {
        print("Inside for----------------------------------");
        final data = change.doc.data();
        if (data == null) continue;

        final timeParts = (data['time'] as String).split(':');
        final hour = int.tryParse(timeParts[0]) ?? 0;
        final minute = int.tryParse(timeParts[1]) ?? 0;
        final medName = data['medication'] ?? 'Medicine';
        final id = data['reminderId'] ?? change.doc.id.hashCode;

        final notiService = NotificationService();

        if (change.type == DocumentChangeType.removed) {
          await notiService.cancelNotification(id);
        } else {
          await notiService.scheduleNotification(
            id: id,
            title: 'Medication Reminder',
            body: 'Please take your $medName now!',
            hour: hour,
            minute: minute,
          );
        }
      }
    });


  }

  Future<void> _loadUserData() async {
    _userData = await _medicationRepository.getUserData();
  }

  Future<void> _loadMedicationCounts() async {
    try {
      final remindersSnapshot = await _medicationRepository.getReminders();

      if (mounted) {
        final allReminders = remindersSnapshot.docs;

        setState(() {
          _totalMeds = allReminders.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return (data['status']?.toString().toLowerCase() ?? '') != 'taken';
          }).length;

          _completedMeds = allReminders.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return (data['status']?.toString().toLowerCase() ?? '') == 'taken';
          }).length;
        });
      }
    } catch (e) {
      debugPrint('Error loading medication counts: $e');
    }
  }


  Future<void> _showMedicationDialog(
      DocumentSnapshot<Map<String, dynamic>> doc) async {
    final data = doc.data()!;
    final theme = Theme.of(context);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
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
                  _markAsTaken(doc.id);
                },
                child: Text('Mark Taken',
                    style: TextStyle(color: theme.colorScheme.primary)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _rescheduleReminder(doc.id, data['time'], data['medication']);
                },
                child: Text('Reschedule',
                    style: TextStyle(color: theme.colorScheme.secondary)),
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
            backgroundColor: Theme
                .of(context)
                .colorScheme
                .primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme
                .of(context)
                .colorScheme
                .error,
          ),
        );
      }
    }
  }

  Future<void> _rescheduleReminder(
      String reminderId, String oldTime, String medicineName) async {
    final timeParts = oldTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(timeParts[0]) ?? 0,
      minute: int.tryParse(timeParts[1]) ?? 0,
    );

    final newTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (newTime != null) {
      final newDateTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        newTime.hour,
        newTime.minute,
      );

      try {
        // Cancel the existing notification
        await NotificationService().cancelNotification(reminderId.hashCode);

        // Update Firestore reminder with new time
        await _medicationRepository.rescheduleReminder(
          reminderId,
          newTime: newDateTime,
          medicineName: medicineName,
        );

        // Schedule new notification for this reminder
        await NotificationService().scheduleNotification(
          id: reminderId.hashCode,
          title: 'Medication Reminder',
          body: 'Please take your $medicineName now!',
          hour: newTime.hour,
          minute: newTime.minute,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Rescheduled to ${newTime.format(context)}'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _scheduleAllReminders() async {
    final notificationService = NotificationService();
    await notificationService.initNotification();
    await NotificationService().cancelAllNotifications();
    final remindersSnapshot = await _medicationRepository.getActiveReminders();


    for (var doc in remindersSnapshot.docs) {
      final data = doc.data();

      print("🔍 Scheduling for: ${data['medication']} | status: ${data['status']}");

      final timeParts = (data['time'] as String).split(':');
      final int hour = int.tryParse(timeParts[0]) ?? 0;
      final int minute = int.tryParse(timeParts[1]) ?? 0;
      final String medicationName = data['medication'] ?? 'Medicine';
      final int reminderId = data['reminderId'] ?? doc.id.hashCode;

      await notificationService.scheduleNotification(
        id: reminderId,
        title: 'Time for $medicationName',
        body: 'Please take your $medicationName now!',
        hour: hour,
        minute: minute,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All reminders scheduled successfully!')),
      );
    }
  }




  void _navigateToReschedule() =>
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const ReschedulePage()));

  void _navigateToAddReminder() =>
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const AddReminderPage()));

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfilePage(),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Theme
                .of(context)
                .colorScheme
                .error,
          ),
        );
      }
    }
  }

  void showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _subscribeToReminders() {
    setState(() {
      _reminderStream = _medicationRepository.getRemindersStream();  // however you're initializing it
    });
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("🟢 App resumed — reloading reminders");
      _subscribeToReminders();
    }
  }


  @override
  void dispose() {
    _animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _reminderSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());
    final dayName = DateFormat('EEEE').format(DateTime.now());

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _reminderStream,
      builder: (context, snapshot) {
        print("🔄 StreamBuilder triggered");  // 👈 add this here

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final reminders = snapshot.data!.docs;

        return Scaffold(
          backgroundColor: theme.colorScheme.background,
          drawer: HomeDrawer(
            userData: _userData,
            onProfilePressed: _navigateToProfile,
            onLogoutPressed: _logout,
          ),
          appBar: AppBar(
            backgroundColor: theme.colorScheme.primary,
            title: Text('MedSarthi',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                )),
            leading: Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu, color: theme.colorScheme.onPrimary),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            actions: [
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

          resizeToAvoidBottomInset: true,

          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeHeader(
                    username: _userData?['username'] ?? 'User',
                    currentDate: currentDate,
                  ),
                  const SizedBox(height: 10),
                  RemainingMedCard(remaining: reminders.length),
                  const SizedBox(height: 10),
                  const HealthTipCard(),
                  const SizedBox(height: 10),
                  ActionButtons(
                    onNewSchedule: _navigateToAddReminder,
                    onReschedule: _navigateToReschedule,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Upcoming Reminders',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  /// ✅ Expanded used properly so ReminderList scrolls
                  Expanded(
                    child: ReminderList(
                      reminders: reminders,
                      onMedicationTaken: (String id) async {
                        await _medicationRepository.markAsTaken(id);
                        if (mounted) {
                          showSuccessDialog(context, "✅ Great job! You've taken your medicine 🎉");
                        }
                      },
                      onReschedule: (id, time, name) async {
                        _navigateToReschedule();
                        await _scheduleAllReminders();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          floatingActionButton: FloatingButtons(
            onAddReminderPressed: _navigateToAddReminder,
          ),
        );



      },
    );
  }
}