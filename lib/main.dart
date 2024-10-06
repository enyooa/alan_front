import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cash_control/ui/widgets/onboarding/onboarding.dart';
import 'package:cash_control/ui/main/home.dart';
import 'package:cash_control/ui/main/settings.dart'; 
import 'package:cash_control/ui/main/profile.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  runApp(MyApp(isFirstLaunch: isFirstLaunch));
}

class MyApp extends StatelessWidget {
  final bool isFirstLaunch;

  MyApp({required this.isFirstLaunch});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cash Control',
      initialRoute: isFirstLaunch ? '/onboarding' : '/home',
      routes: {
        '/onboarding': (context) => Onbording(),
        '/home': (context) => Home(),
        '/settings': (context) => SettingsScreen(),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}
