// lib/main.dart

import 'package:alan/role_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

// BLoC Imports (Adjust according to your actual imports)
import 'package:alan/bloc/blocs/common_blocs/blocs/connectivity_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/blocs/auth_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/blocs/provider_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/blocs/account_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/blocs/basket_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/blocs/favorites_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/repositories/basket_repository.dart';
import 'package:alan/bloc/blocs/client_page_blocs/repositories/favorites_repository.dart';
import 'package:alan/bloc/blocs/cashbox_page_blocs/blocs/admin_cash_bloc.dart';
import 'package:alan/bloc/blocs/cashbox_page_blocs/blocs/financial_order_bloc.dart';
import 'package:alan/bloc/blocs/cashbox_page_blocs/blocs/financial_element.dart';
import 'package:alan/bloc/blocs/cashbox_page_blocs/events/admin_cash_event.dart';
import 'package:alan/bloc/blocs/cashbox_page_blocs/events/financial_order_event.dart';
import 'package:alan/bloc/blocs/common_blocs/events/connectivity_event.dart';
import 'package:alan/bloc/blocs/common_blocs/states/auth_state.dart';
import 'package:alan/bloc/blocs/common_blocs/states/connectivity_state.dart';
import 'package:alan/bloc/blocs/cashbox_page_blocs/events/financial_element.dart';
import 'package:alan/bloc/blocs/common_blocs/events/auth_event.dart';

// Your UI pages
import 'package:alan/ui/main/widgets/onboarding/onboarding.dart';
import 'package:alan/ui/main/auth/login.dart';
import 'package:alan/ui/admin/home.dart';         // AdminDashboardScreen
import 'package:alan/ui/cashbox/home.dart';       // CashboxDashboardScreen
import 'package:alan/ui/client/home.dart';        // ClientHome
import 'package:alan/ui/courier/home.dart';       // CourierDashboardScreen
import 'package:alan/ui/packer/home.dart';        // PackerScreen
import 'package:alan/ui/storage/home.dart';       // StoragePage
import 'package:alan/ui/main/widgets/profile.dart';


// Constants
import 'package:alan/constant.dart';

/// The main function
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
  String? token = prefs.getString('token');
  List<String>? roles = prefs.getStringList('roles');

  String initialRoute;

  if (isFirstLaunch) {
    // First time user -> Onboarding
    initialRoute = '/onboarding';
  } else if (token != null && token.isNotEmpty) {
    // User is logged in, check roles:
    if (roles != null && roles.isNotEmpty) {
      if (roles.length == 1) {
        // Exactly one role -> jump directly
        if (roles.contains('admin')) {
          initialRoute = '/admin_dashboard';
        } else if (roles.contains('cashbox')) {
          initialRoute = '/cashbox_dashboard';
        } else if (roles.contains('client')) {
          initialRoute = '/client_dashboard';
        } else if (roles.contains('storager')) {
          initialRoute = '/storage_dashboard';
        } else if (roles.contains('packer')) {
          initialRoute = '/packer_dashboard';
        } else if (roles.contains('courier')) {
          initialRoute = '/courier_dashboard';
        } else {
          // Unknown role fallback
          initialRoute = '/login';
        }
      } else {
        // More than 1 role -> let user pick which role to use
        initialRoute = '/role_selection';
      }
    } else {
      // No roles, fallback
      initialRoute = '/login';
    }
  } else {
    // Not logged in or no token
    initialRoute = '/login';
  }

  runApp(StartApp(initialRoute: initialRoute));
}

class StartApp extends StatelessWidget {
  final String initialRoute;

  const StartApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Connectivity BLoC
        BlocProvider(
          create: (context) => ConnectivityBloc()..add(CheckConnectivity()),
        ),
        // Auth BLoC
        BlocProvider(
          create: (context) => AuthBloc(),
        ),
        // If you have references:
        BlocProvider(
          create: (context) => ReferenceBloc()..add(FetchReferencesEvent()),
        ),
        BlocProvider(
          create: (context) => FinancialOrderBloc()..add(FetchFinancialOrdersEvent()),
        ),
        BlocProvider(
          create: (context) => AdminCashBloc()..add(FetchAdminCashesEvent()),
        ),
        // Account BLoC
        BlocProvider(
          create: (context) => AccountBloc(baseUrl: baseUrl),
        ),
        // Basket & Favorites
        BlocProvider<BasketBloc>(
          create: (context) => BasketBloc(repository: BasketRepository(baseUrl: baseUrl)),
        ),
        BlocProvider<FavoritesBloc>(
          create: (context) => FavoritesBloc(repository: FavoritesRepository(baseUrl: baseUrl)),
        ),
        BlocProvider(create: (_) => ProviderBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Cash Control',
        // Internationalization
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('ru', 'RU'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: const Locale('ru', 'RU'),
        // Theming
        theme: ThemeData(
          fontFamily: 'Raleway',
          textTheme: const TextTheme(
            bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            bodyLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        // Starting page logic
        initialRoute: initialRoute,

        // Define all your routes here
        routes: {
          '/onboarding': (context) => const Onboarding(),
          '/login': (context) => const Login(),
          '/profile': (context) => const AccountView(),
          '/role_selection': (context) => const RoleSelectionScreen(),
          '/admin_dashboard': (context) => AdminDashboardScreen(),
          '/cashbox_dashboard': (context) => CashboxDashboardScreen(),
          '/client_dashboard': (context) => const ClientHome(),
          '/packer_dashboard': (context) => PackerScreen(),
          '/storage_dashboard': (context) => const StoragePage(),
          '/courier_dashboard': (context) => CourierDashboardScreen(),
        },
        // Listen for events like successful login, connectivity changes, etc.
        builder: (context, child) {
          return MultiBlocListener(
            listeners: [
              // Auth BLoC
              BlocListener<AuthBloc, AuthState>(
                listener: (context, state) async {
                  if (state is AuthAuthenticated) {
                    final roles = state.roles;

                    // If user re-authenticated, go to relevant dashboard
                    if (roles.contains('admin')) {
                      Navigator.pushReplacementNamed(context, '/admin_dashboard');
                    } else if (roles.contains('cashbox')) {
                      Navigator.pushReplacementNamed(context, '/cashbox_dashboard');
                    } else if (roles.contains('client')) {
                      Navigator.pushReplacementNamed(context, '/client_dashboard');
                    } else if (roles.contains('storager')) {
                      Navigator.pushReplacementNamed(context, '/storage_dashboard');
                    } else if (roles.contains('packer')) {
                      Navigator.pushReplacementNamed(context, '/packer_dashboard');
                    } else if (roles.contains('courier')) {
                      Navigator.pushReplacementNamed(context, '/courier_dashboard');
                    } else {
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
              ),
              // Connectivity BLoC
              BlocListener<ConnectivityBloc, ConnectivityState>(
                listener: (context, state) {
                  if (state is ConnectivityLost) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Нет соединения с интернетом!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (state is ConnectivityRestored) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Соединение с интернетом восстановлено'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
              ),
            ],
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
