import 'package:flutter/material.dart';
import 'package:cash_control/ui/widgets/menu.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Screen')),
      drawer: Menu(),  // Adding the navigation menu
      body: Center(
        child: Text('Welcome to Home Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
