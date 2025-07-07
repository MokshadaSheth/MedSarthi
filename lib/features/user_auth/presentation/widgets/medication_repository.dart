import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:med_sarathi/features/user_auth/presentation/pages/noti_service.dart';

class MedicationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  MedicationRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Fetch logged in user's profile data
  Future<Map<String, dynamic>?> getUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('Users').doc(user.uid).get();
    return doc.data();
  }

  /// Fetch all reminders for current user
  Future<QuerySnapshot> getReminders() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    return await _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('reminders')
        .get();
  }

  /// Mark a reminder as taken and optionally cancel its notification
  Future<void> markAsTaken(String reminderId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('reminders')
        .doc(reminderId)
        .update({
      'lastTaken': FieldValue.serverTimestamp(),
      'status': 'taken',
    });

    // Optional: cancel notification when taken
    // await NotificationService.cancelNotification(reminderId.hashCode);
  }

  /// Reschedule a reminder to a new time and optionally update its notification
  Future<void> rescheduleReminder(
      String reminderId, {
        required DateTime newTime,
        required String medicineName,
      }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('reminders')
        .doc(reminderId)
        .update({
      'time': newTime.toIso8601String(),
      'status': 'rescheduled',
      'rescheduledAt': FieldValue.serverTimestamp(),
    });

    // Optional: Cancel previous & schedule new notification
    // await NotificationService.cancelNotification(reminderId.hashCode);
    // await NotificationService.scheduleNotification(
    //   id: reminderId.hashCode,
    //   title: "Medication Reminder Rescheduled",
    //   body: "Your reminder for $medicineName is now at ${newTime.hour}:${newTime.minute.toString().padLeft(2, '0')}.",
    //   scheduledTime: newTime,
    // );
  }

  // /// Get live stream of all reminders for current user
  Stream<QuerySnapshot<Map<String, dynamic>>> getRemindersStream() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    return _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('reminders')
        .where('status', whereIn: ['pending', 'rescheduled'])
        .withConverter<Map<String, dynamic>>(
      fromFirestore: (snapshot, _) => snapshot.data()!,
      toFirestore: (data, _) => data,
    )
        .snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getActiveReminders() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    return _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('reminders')
        .where('status', whereIn: ['pending', 'rescheduled'])
        .withConverter<Map<String, dynamic>>(
      fromFirestore: (snapshot, _) => snapshot.data()!,
      toFirestore: (data, _) => data,
    )
        .get();
  }

}
