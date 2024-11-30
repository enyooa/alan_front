import 'package:flutter/material.dart';
import '../client_pages/main_page.dart'; // Main Page
import '../client_pages/basket_page.dart'; // Basket Page
import '../client_pages/favorites_page.dart'; // Favorites Page
import '../client_pages/calculations_page.dart'; // Calculations Page
import '../profile.dart'; // Profile Page

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const MainPage(), // Main/Home Page without BottomNavBar inside
    const BasketPage(), // Basket Page
    const FavoritesPage(), // Favorites Page
    const CalculationsPage(), // Calculations Page
    const AccountView(), // Profile Page
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
        selectedItemColor: Colors.blue, // Customize selected icon color
        unselectedItemColor: Colors.grey, // Customize unselected icon color
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Корзина',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Избранное',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Расчеты',
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
