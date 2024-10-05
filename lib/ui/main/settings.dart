import 'package:flutter/material.dart';
import 'package:cash_control/ui/widgets/menu.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      drawer: Menu(),  // Adding the navigation menu
      body: Center(
        child: Text('Settings Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
