import 'package:flutter/material.dart';
import 'package:cash_control/ui/widgets/menu.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      drawer: Menu(),  // Adding the navigation menu
      body: Center(
        child: Text('Profile Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
