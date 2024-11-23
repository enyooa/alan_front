import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/price_request_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/product_card_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/product_receiving_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/product_subcard_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_card_event.dart';
import 'package:cash_control/constant.dart';
import 'package:cash_control/ui/admin/dynamic_pages/dynamic_product_page.dart';
import 'package:cash_control/ui/admin/dynamic_pages/dynamic_report_page.dart';
import 'package:cash_control/ui/admin/dynamic_pages/reference_page.dart';
import 'package:cash_control/ui/admin/form_pages/subproduct_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_control/bloc/blocs/organization_bloc.dart';
import 'package:cash_control/bloc/blocs/unit_bloc.dart';

import 'package:cash_control/bloc/blocs/product_bloc.dart';
import 'package:cash_control/bloc/blocs/employee_bloc.dart';
import 'package:cash_control/ui/admin/dynamic_pages/dynamic_form_page.dart';

class AdminDashboardScreen extends StatefulWidget {
  
  const AdminDashboardScreen({
    Key? key,
   
  }) : super(key: key);

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    DynamicReportPage(),
    DynamicProductPage(),
    DynamicFormPage(),
    OperationHistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ProductSubCardBloc(),child: ProductSubCardPage()),
        BlocProvider(create: (context) => ProductReceivingBloc()),
        BlocProvider(create: (context) => PriceRequestBloc()),
        BlocProvider(create: (context) => ProductCardBloc()),
        BlocProvider(create: (context) => UserBloc()),
        // BlocProvider(create: (context) => OrganizationBloc(organizationService: widget.organizationService)),
        BlocProvider(create: (context) => UnitBloc()),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Администратор')),
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: primaryColor,
          unselectedItemColor: unselectednavbar,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Отчеты',),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Товары'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Справка'),
            BottomNavigationBarItem(icon: Icon(Icons.history),label: 'Справочная'),
          ],
        ),
      ),
    );
  }
}
