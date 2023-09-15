import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:petpal/pages/home_page.dart';
import 'package:petpal/pages/alerts.dart';
import 'package:petpal/pages/veterinarians.dart';

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
              GButton(
                icon: Icons.home,
                text: "Home",
                onPressed: () => _navigateToPage(context, HomePage()),
              ),
              GButton(
                icon: Icons.add_alert,
                text: "Alerts",
                onPressed: () => _navigateToPage(context, AlertsPage()),
              ),
              GButton(
                icon: Icons.add_location,
                text: "Veterinarians",
                onPressed: () => _navigateToPage(context, Veterinarians()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

  Widget _getPage() {
    // Depending on your use case, you may want to initialize the default page here.
    // Example: return HomePage();
    return Container();
  }
}
