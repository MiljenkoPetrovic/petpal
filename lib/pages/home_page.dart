import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petpal/pages/login_or_register.dart';
import 'package:petpal/components/navbar.dart';

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(
            onPressed: () => signUserOut(context), // Pass the context here
            icon: Icon(Icons.logout),
          )
        ],
        title: Text("Home"),
      ),
      body: Center(
        child: Text("Add your home page content here."),
      ),
      bottomNavigationBar: NavbarPage(),
    );
  }
}
