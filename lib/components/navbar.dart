import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:petpal/pages/home_page.dart';
import 'package:petpal/pages/alerts.dart';
import 'package:petpal/pages/veterinarians.dart';

class NavbarPage extends StatefulWidget {
  final Function(int) changePage;

  const NavbarPage({Key? key, required this.changePage}) : super(key: key);

  @override
  State<NavbarPage> createState() => _NavbarPageState();
}

class _NavbarPageState extends State<NavbarPage> {
  int _showPageAtIndex = 0;

  void _changePage(int index) {
    setState(() {
      _showPageAtIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(_showPageAtIndex),
      bottomNavigationBar: Container(
        color: Colors.lightBlueAccent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: GNav(
            backgroundColor: Colors.lightBlueAccent,
            activeColor: const Color.fromARGB(255, 2, 36, 63),
            gap: 8,
            onTabChange: (index) {
              _changePage(index);
            },
            padding: EdgeInsets.all(16),
            tabs: [
              GButton(
                icon: Icons.home,
                text: "Home",
              ),
              GButton(
                icon: Icons.add_alert,
                text: "Alerts",
              ),
              GButton(
                icon: Icons.add_location,
                text: "Veterinarians",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return HomePage();
      case 1:
        return Alerts();
      case 2:
        return Veterinarians();
      default:
        return HomePage();
    }
  }
}