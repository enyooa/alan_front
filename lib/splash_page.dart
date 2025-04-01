// lib/splash_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndRoles();
  }

  Future<void> _checkAuthAndRoles() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final roles = prefs.getStringList('roles') ?? [];

    // Check if user is first time? -> Onboarding? ...
    // For brevity, let's skip "isFirstLaunch" here; just show the logic for roles.

    if (token.isEmpty) {
      // No token => go to login
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      // We have a token
      if (roles.isEmpty) {
        // No roles => fallback to login
        Navigator.pushReplacementNamed(context, '/login');
      } else if (roles.length == 1) {
        // Exactly 1 => route directly
        final singleRole = roles.first;
        switch (singleRole) {
          case 'admin':
            Navigator.pushReplacementNamed(context, '/admin_dashboard');
            break;
          case 'cashbox':
            Navigator.pushReplacementNamed(context, '/cashbox_dashboard');
            break;
          case 'client':
            Navigator.pushReplacementNamed(context, '/client_dashboard');
            break;
          case 'packer':
            Navigator.pushReplacementNamed(context, '/packer_dashboard');
            break;
          case 'storager':
            Navigator.pushReplacementNamed(context, '/storage_dashboard');
            break;
          case 'courier':
            Navigator.pushReplacementNamed(context, '/courier_dashboard');
            break;
          default:
            Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        // More than one => show role selection
        Navigator.pushReplacementNamed(context, '/role_selection');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Simple splash design
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
