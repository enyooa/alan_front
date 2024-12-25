import 'package:cash_control/bloc/blocs/client_page_blocs/blocs/basket_bloc.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/repositories/basket_repository.dart';
import 'package:cash_control/bloc/blocs/common_blocs/blocs/account_bloc.dart';
import 'package:cash_control/bloc/blocs/common_blocs/blocs/auth_bloc.dart';
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/blocs/admin_cash_bloc.dart';
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/blocs/financial_element.dart';
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/blocs/financial_order_bloc.dart';
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/events/admin_cash_event.dart';
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/events/financial_element.dart';
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/events/financial_order_event.dart';
import 'package:cash_control/bloc/blocs/common_blocs/blocs/connectivity_bloc.dart';
import 'package:cash_control/bloc/blocs/common_blocs/blocs/user_photo_bloc.dart';
import 'package:cash_control/bloc/blocs/common_blocs/events/connectivity_event.dart';
import 'package:cash_control/bloc/blocs/common_blocs/states/auth_state.dart';
import 'package:cash_control/bloc/blocs/common_blocs/states/connectivity_state.dart';
import 'package:cash_control/constant.dart';
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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cash_control/ui/main/widgets/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
  String? token = prefs.getString('token');
  List<String>? roles = prefs.getStringList('roles');

  String initialRoute;

  if (isFirstLaunch) {
    initialRoute = '/onboarding';
  } else if (token != null && token.isNotEmpty) {
    // Check the role to decide the initial dashboard
    if (roles?.contains('admin') ?? false) {
      initialRoute = '/admin_dashboard';
    } else if (roles?.contains('cashbox') ?? false) {
      initialRoute = '/cashbox_dashboard';
    } else if (roles?.contains('client') ?? false) {
      initialRoute = '/client_dashboard';
    } else if (roles?.contains('storage') ?? false) {
      initialRoute = '/storage_dashboard';
    } else if (roles?.contains('packer') ?? false) {
      initialRoute = '/packer_dashboard';
    } else if (roles?.contains('courier') ?? false) {
      initialRoute = '/courier_dashboard';
    } else {
      initialRoute = '/login';
    }
  } else {
    initialRoute = '/login';
  }

  runApp(StartApp(initialRoute: initialRoute));
}


class StartApp extends StatelessWidget {
  final String initialRoute;

  const StartApp({super.key, required this.initialRoute});

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
        BlocProvider(
          create: (context) => ReferenceBloc()..add(FetchReferencesEvent()),
        ),
        BlocProvider(
          create: (context) => FinancialOrderBloc()..add(FetchFinancialOrdersEvent()),
        ),
        BlocProvider(
          create: (context) => AdminCashBloc()..add(FetchAdminCashesEvent()),
        ),
        BlocProvider(create: (context) => AccountBloc(baseUrl: baseUrl)),
        BlocProvider(
        create: (context) => BasketBloc(repository: BasketRepository(baseUrl: baseUrl)),
      ),
      ],
      child: MaterialApp(
        supportedLocales: const [
          Locale('en', 'US'), // English
          Locale('ru', 'RU'), // Russian
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: const Locale('ru', 'RU'),
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
        initialRoute: initialRoute,
        routes: {
          '/onboarding': (context) => const Onboarding(),
          '/login': (context) => const Login(),
          '/profile': (context) => const AccountView(),
          '/admin_dashboard': (context) => AdminDashboardScreen(),
          '/cashbox_dashboard': (context) => CashboxDashboardScreen(),
          '/client_dashboard': (context) => const ClientHome(),
          '/packer_dashboard': (context) => PackerScreen(),
          '/storage_dashboard': (context) => const StoragePage(),
          '/courier_dashboard': (context) => CourierDashboardScreen(),
        },
        builder: (context, child) {
          return MultiBlocListener(
            listeners: [
              BlocListener<AuthBloc, AuthState>(
                listener: (context, state) async {
                  if (state is AuthAuthenticated) {
                    final roles = state.roles;

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
              BlocListener<ConnectivityBloc, ConnectivityState>(
                listener: (context, state) {
                  if (state is ConnectivityLost) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Нет соединение с интернетом!'),
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

