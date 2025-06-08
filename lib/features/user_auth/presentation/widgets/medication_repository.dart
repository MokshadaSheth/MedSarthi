import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  MedicationRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<Map<String, dynamic>?> getUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('Users').doc(user.uid).get();
    return doc.data();
  }

  Future<QuerySnapshot> getReminders() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    return await _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('reminders')
        .get();
  }

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
  }

  Future<void> rescheduleReminder(
      String reminderId, {
        required String newTime,
      }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('reminders')
        .doc(reminderId)
        .update({
      'time': newTime,
      'status': 'rescheduled',
      'rescheduledAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getRemindersStream() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    return _firestore
        .collection('Users')
        .doc(user.uid)
        .collection('reminders')
        .withConverter<Map<String, dynamic>>(
      fromFirestore: (snapshot, _) => snapshot.data()!,
      toFirestore: (data, _) => data,
    ).snapshots();
  }

}
