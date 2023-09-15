import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petpal/pages/home_page.dart';
import 'package:petpal/pages/login_or_register.dart';
import 'package:petpal/pages/login_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Handle the initial loading state while Firebase initializes.
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // Handle any errors that occur during authentication.
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            final user = snapshot.data as User?;
            if (user != null) {
              // User is authenticated, navigate to HomePage.
              return const HomePage();
            }
          }

          // User is not authenticated or initial loading is complete,
          // show the login page.
          return LoginPage(
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginOrRegisterPage()),
              );
            },
          );
        },
      ),
    );
  }
}
