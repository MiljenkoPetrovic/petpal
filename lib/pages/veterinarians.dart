import 'package:flutter/material.dart';
import 'package:petpal/main.dart';

class Veterinarians extends StatelessWidget {
  const Veterinarians({Key? key}) : super(key: key);

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [IconButton(onPressed: signUserOut, icon: Icon(Icons.logout))],
      ),
      
    );
  }
}

