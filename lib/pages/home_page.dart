import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petpal/pages/login_or_register.dart';
import 'package:petpal/components/navbar.dart'; // Import NavbarPage

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  void signUserOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => LoginOrRegisterPage(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(
            onPressed: () => signUserOut(context),
            icon: Icon(Icons.logout),
          )
        ],
        title: Text("Home"),
      ),
      body: Center(
        child: Text(
          "Welcome, ${user?.email ?? 'Guest'}!",
          style: TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: NavbarPage(), 
    );
  }
}
