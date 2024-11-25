import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_card_event.dart';
import 'package:cash_control/bloc/blocs/auth_bloc.dart';
import 'package:cash_control/bloc/blocs/connectivity_bloc.dart';
import 'package:cash_control/bloc/events/connectivity_event.dart';

import 'package:cash_control/bloc/states/auth_state.dart';
import 'package:cash_control/ui/admin/home.dart';
import 'package:cash_control/ui/cashbox/home.dart';
import 'package:cash_control/ui/client/home.dart';
import 'package:cash_control/ui/courier/home.dart';
import 'package:cash_control/ui/main/auth/login.dart';
import 'package:cash_control/ui/packer/home.dart';
import 'package:cash_control/ui/storage/home.dart';
import 'package:cash_control/ui/main/widgets/onboarding/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cash_control/ui/client/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Retrieve whether it's the first launch from SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  runApp(StartApp(isFirstLaunch: isFirstLaunch));
}

class StartApp extends StatelessWidget {
  final bool isFirstLaunch;

  const StartApp({super.key, required this.isFirstLaunch});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ConnectivityBloc()..add(CheckConnectivity()),
        ),
        BlocProvider(
          create: (context) => AuthBloc(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          fontFamily: 'Raleway',
          textTheme: const TextTheme(
            bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            bodyLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        debugShowCheckedModeBanner: false,
        title: 'Cash Control',
        initialRoute: isFirstLaunch ? '/onboarding' : '/login',

        routes: {
          '/onboarding': (context) => const Onboarding(),
          '/login': (context) => const Login(),
          '/profile': (context) => const AccountView(),
          '/admin_dashboard': (context) => AdminDashboardScreen(),
          '/cashbox_dashboard': (context) => CashboxDashboardScreen(),
          '/client_dashboard': (context) => const ClientDashboardScreen(),
          '/packer_dashboard': (context) => PackerScreen(),
          '/storage_dashboard': (context) => const StorageScreen(),
          '/courier_dashboard': (context) => CourierDashboardScreen(),
        },
        builder: (context, child) {
          return BlocListener<AuthBloc, AuthState>(
            listener: (context, state) async {
              if (state is AuthAuthenticated) {
                final roles = state.roles;

                // Navigate to the appropriate dashboard based on the user's roles
                if (roles.contains('admin')) {
                  Navigator.pushReplacementNamed(context, '/admin_dashboard');
                } else if (roles.contains('cashbox')) {
                  Navigator.pushReplacementNamed(context, '/cashbox_dashboard');
                } else if (roles.contains('client')) {
                  Navigator.pushReplacementNamed(context, '/client_dashboard');
                } else if (roles.contains('storage')) {
                  Navigator.pushReplacementNamed(context, '/storage_dashboard');
                } else if (roles.contains('packer')) {
                  Navigator.pushReplacementNamed(context, '/packer_dashboard');
                } else if (roles.contains('courier')) {
                  Navigator.pushReplacementNamed(context, '/courier_dashboard');
                } else {
                  // Default fallback if no matching role is found
                  Navigator.pushReplacementNamed(context, '/login');
                }
              } else if (state is AuthUnauthenticated) {
                Navigator.pushReplacementNamed(context, '/login');
              } else if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            child: child,
          );
        },
      ),
    );
  }
}
