import 'package:cash_control/constant.dart';
import 'package:cash_control/ui/cashbox/calculations.dart';
import 'package:cash_control/ui/client/home.dart';
import 'package:flutter/material.dart';

import '../../main/profile.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0; 
  List<Map<String, dynamic>> cartItems = [];

  final List<Widget> _screens = [
   CalculationScreen(),
    //  const CartScreen(cartItems: []),
    //     const CartScreen(cartItems: []),

    const AccountView(),// Профиль
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        currentIndex: _selectedIndex, // Track the selected item index
        selectedItemColor: primaryColor, // Color for selected item
        unselectedItemColor: Colors.grey, // Color for unselected items
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Карточка',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Расчеты',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (cartItems.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${cartItems.length}', // Show number of items in the cart
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Корзина',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Избранное',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      
    );
  }
}
