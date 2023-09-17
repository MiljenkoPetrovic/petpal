import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petpal/pages/login_or_register.dart';
import 'package:petpal/pages/alerts.dart';
import 'package:petpal/pages/veterinarians.dart';
import 'package:petpal/pages/tracker.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Define a list of page widgets for navigation
  final List<Widget> _pages = [
    HomeContent(),
    TrackerPage(
      storage: FirebaseStorage.instance,
    ),
    AlertsPage(),
    Veterinarians(),
  ];

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
        title: Text("PetPal"),
      ),
      body: _pages[_currentIndex], // Ensure _currentIndex is within valid range
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.lightBlueAccent,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          // No need for Navigator on the web, just update the index
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Tracker',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_alert),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_location),
            label: 'Veterinarias',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return Center(
      child: Text(
        "Welcome, ${user?.email ?? 'Guest'}!",
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

// Define other pages similarly to TrackerPage, AlertsPage, and VeterinariansPage
