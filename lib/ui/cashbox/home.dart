

import 'package:alan/ui/cashbox/pages/calculations.dart';
import 'package:alan/ui/cashbox/pages/expenses_order.dart';
import 'package:alan/ui/cashbox/pages/income_order.dart';
import 'package:alan/ui/cashbox/pages/report.dart';
import 'package:alan/ui/cashbox/pages/reference_screen.dart';
import 'package:alan/ui/main/widgets/profile.dart';
import 'package:flutter/material.dart';
import 'package:alan/constant.dart';
class CashboxDashboardScreen extends StatefulWidget {
  @override
  _CashboxDashboardScreenState createState() => _CashboxDashboardScreenState();
}

class _CashboxDashboardScreenState extends State<CashboxDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    OrderScreen(),
    ExpenseOrderScreen(),
    CalculationScreen(),
    CashReportScreen(),
    ReferenceScreen(),
    AccountView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Касса', style: TextStyle(color: Colors.white)),
          backgroundColor: primaryColor,
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Приходный ордер',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt),
              label: 'Расходный ордер',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate),
              label: 'Расчеты',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Отчет по кассе',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: 'Справочник',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Профиль',
            ),
          ],
        ),
      
    );
  }
}
