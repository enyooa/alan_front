import 'package:cash_control/ui/cashbox/calculations.dart';
import 'package:cash_control/ui/cashbox/expenses_order.dart';
import 'package:cash_control/ui/cashbox/income_order.dart';
import 'package:cash_control/ui/cashbox/report.dart';
import 'package:flutter/material.dart';

import 'reference_screen.dart';
import 'package:cash_control/constant.dart';

class CashboxDashboardScreen extends StatefulWidget {
  @override
  _CashboxDashboardScreenState createState() => _CashboxDashboardScreenState();
}

class _CashboxDashboardScreenState extends State<CashboxDashboardScreen> {
  int _currentIndex = 0;

  // List of pages to switch between
  final List<Widget> _pages = [
    OrderScreen(),
    ExpenseOrderScreen(),
    CalculationScreen(),
    CashReportScreen(),
    ReferenceScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Касса', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
      ),
      body: _pages[_currentIndex],
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
        ],
      ),
    );
  }
}
