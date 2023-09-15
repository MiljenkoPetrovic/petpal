import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:petpal/pages/auth_page.dart';
import 'package:petpal/pages/home_page.dart';
import 'package:petpal/pages/login_or_register.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Clear the user's authentication state
  await FirebaseAuth.instance.signOut();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute:
          '/login_or_register', // Set the initial route to '/login_or_register'
      routes: {
        '/': (context) => AuthPage(), // Define the '/auth' route for AuthPage
        '/home': (context) =>
            HomePage(), // Define the '/home' route for HomePage
        '/login_or_register': (context) =>
            LoginOrRegisterPage(), // Define the '/login_or_register' route
      },
    );
  }
}
