import 'package:flutter/material.dart';
import 'package:petpal/main.dart';

class Alerts extends StatelessWidget {
  const Alerts({Key? key}) : super(key: key);

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [IconButton(onPressed: signUserOut, icon: Icon(Icons.logout))],
      ),
      
    );
  }
}
