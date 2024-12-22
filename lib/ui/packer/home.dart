import 'package:cash_control/ui/main/widgets/profile.dart';
import 'package:cash_control/ui/packer/pages/courier.dart';
import 'package:cash_control/ui/packer/pages/main_page.dart';
import 'package:cash_control/ui/packer/pages/packaging.dart';
import 'package:cash_control/ui/packer/pages/requests.dart';
import 'package:flutter/material.dart';

class PackerScreen extends StatefulWidget {
  @override
  _PackerScreenState createState() => _PackerScreenState();
}

class _PackerScreenState extends State<PackerScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(), // Заявка Page
    const RequestsScreen(), // Накладная Page
    const PackagingScreen(), // Склад Page
    const CourierScreen(), // Курьеры Page
    const AccountView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Заявка',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Накладная',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.warehouse),
            label: 'Склад',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Курьеры',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}