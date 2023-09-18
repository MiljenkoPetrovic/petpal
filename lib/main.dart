import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:petpal/pages/alerts.dart';
import 'package:petpal/pages/auth_page.dart';
import 'package:petpal/pages/home_page.dart';
import 'package:petpal/pages/login_or_register.dart';
import 'package:petpal/pages/tracker.dart';
import 'package:petpal/pages/veterinarians.dart';
import 'firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging
      .instance; // Create an instance of Firebase Cloud Messaging

  @override
  Widget build(BuildContext context) {
    _handleNotificationSelection(); // Handle notification selection when the app is opened

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login_or_register',
      routes: {
        '/': (context) => AuthPage(),
        '/home': (context) => HomePage(),
        '/login_or_register': (context) => LoginOrRegisterPage(),
        '/alerts': (context) => AlertsPage(),
        '/veterinarians': (context) => Veterinarians(),
        '/tracker': (context) => TrackerPage(storage: _storage),
      },
    );
  }

  // Handle notification selection when the app is opened
  void _handleNotificationSelection() async {
    // Check if the app was opened from a notification
    final RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      // The app was opened from a notification
      // Handle the notification data or navigate to a specific page
      print("Opened from notification: ${initialMessage.data}");
    }

    // Subscribe to notification topics or handle additional notification logic here
    // Example: _firebaseMessaging.subscribeToTopic('your_topic');
  }
}
