import 'package:cash_control/bloc/blocs/client_page_blocs/blocs/basket_bloc.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/events/basket_event.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/states/basket_state.dart';
import 'package:cash_control/ui/client/pages/basket_page.dart';
import 'package:cash_control/ui/client/pages/calculations_page.dart';
import 'package:cash_control/ui/client/pages/favorites_page.dart';
import 'package:cash_control/ui/client/pages/main_page.dart';
import 'package:cash_control/ui/main/widgets/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const MainPage(), // Home Page
    const BasketScreen(), // Basket Page
    const FavoritesPage(), // Favorites Page
    const CalculationsPage(), // Calculations Page  
    const AccountView(), // Profile Page
  ];
void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;

    // Trigger FetchBasketEvent when Basket tab is selected
    if (_selectedIndex == 1) { // Basket Page index
      context.read<BasketBloc>().add(FetchBasketEvent());
    }
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
            icon: Icon(Icons.storefront),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart),
                BlocBuilder<BasketBloc, BasketState>(
                  builder: (context, state) {
                    return state.totalItems > 0
                        ? Positioned(
                            right: -6,
                            top: -6,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.red,
                              child: Text('${state.totalItems}',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.white)),
                            ),
                          )
                        : const SizedBox.shrink();
                  },
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
            icon: Icon(Icons.calculate),
            label: 'Расчеты',
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
