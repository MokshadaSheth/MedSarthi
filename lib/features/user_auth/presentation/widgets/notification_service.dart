// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:med_sarathi/features/user_auth/presentation/widgets/medication_repository.dart';
//
// class NotificationService {
//   final FirebaseMessaging _messaging = FirebaseMessaging.instance;
//   final MedicationRepository _repository = MedicationRepository();
//
//   Future<void> initializeNotifications() async {
//     await _messaging.requestPermission();
//
//     // Get the FCM token
//     final token = await _messaging.getToken();
//     print('FCM Token: $token');
//
//     if (token != null) {
//       await _repository.saveUserToken(token);
//     }
//
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('📩 New message received: ${message.notification?.title}');
//       // You can show local notifications here if needed
//     });
//   }
// }
