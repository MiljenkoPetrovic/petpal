import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class NavbarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(),
      bottomNavigationBar: Container(
        color: Colors.lightBlueAccent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: GNav(
            backgroundColor: Colors.lightBlueAccent,
            activeColor: const Color.fromARGB(255, 2, 36, 63),
            gap: 8,
            padding: EdgeInsets.all(16),
            tabs: [
              _buildTab(Icons.home, "Home", '/home', context),
              _buildTab(Icons.add_alert, "Alerts", '/alerts', context),
              _buildTab(Icons.add_location, "Veterinarians", '/veterinarians',
                  context),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create a GButton for a tab
  GButton _buildTab(
      IconData icon, String text, String routeName, BuildContext context) {
    return GButton(
      icon: icon,
      text: text,
      onPressed: () {
        Navigator.of(context).pushReplacementNamed(routeName);
      },
    );
  }

  Widget _getPage() {
    // Example: return HomePage();
    return Container();
  }
}
