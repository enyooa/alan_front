import 'package:cash_control/ui/widgets/onboarding/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:cash_control/ui/widgets/menu.dart';
import 'package:cash_control/ui/main/home.dart'; // Example screen
import 'package:cash_control/ui/main/settings.dart'; // Example screen for settings
import 'package:cash_control/ui/main/profile.dart'; // Example screen for profile

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cash Control',
      initialRoute: '/splashScreen',
      routes: {
        '/splashScreen': (context) => Onbording(),    // Home screen
        '/settings': (context) => SettingsScreen(),  // Settings screen
        '/profile': (context) => ProfileScreen(),  // Profile screen
      },
    );
  }
}
