import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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

  @override
  Widget build(BuildContext context) {

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
}
