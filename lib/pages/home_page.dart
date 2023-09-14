import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  //Signout
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(onPressed: signUserOut, icon: Icon(Icons.logout))
          ],
        ),
        body: SingleChildScrollView(
            child: Stack(
          children: <Widget>[
            new Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets//logo.png'),
                      fit: BoxFit.cover)),
            )
          ],
        )));
  }
}
