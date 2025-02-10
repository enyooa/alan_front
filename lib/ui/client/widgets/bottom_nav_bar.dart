import 'package:alan/bloc/blocs/client_page_blocs/blocs/basket_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/blocs/favorites_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/basket_event.dart';
import 'package:alan/bloc/blocs/client_page_blocs/states/basket_state.dart';
import 'package:alan/bloc/blocs/client_page_blocs/states/favorites_state.dart';
import 'package:alan/ui/client/pages/basket_page.dart';
import 'package:alan/ui/client/pages/calculations_page.dart';
import 'package:alan/ui/client/pages/favorites_page.dart';
import 'package:alan/ui/client/pages/main_page.dart';
import 'package:alan/ui/main/widgets/profile.dart';
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
      if (_selectedIndex == 1) {
        context.read<BasketBloc>().add(FetchBasketEvent());
      }
    });
  }

  @override
  void initState() {
    super.initState();

    // Fetch initial basket data
    context.read<BasketBloc>().add(FetchBasketEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, favoritesState) {
          return BottomNavigationBar(
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
                      builder: (context, basketState) {
                        return basketState.totalItems > 0
                            ? Positioned(
                                right: -6,
                                top: -6,
                                child: CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.red,
                                  child: Text(
                                    '${basketState.totalItems}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
                label: 'Корзина',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.favorite),
                    if (favoritesState is FavoritesLoaded &&
                        favoritesState.totalFavorites > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.red,
                          child: Text(
                            '${favoritesState.totalFavorites}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
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
          );
        },
      ),
    );
  }
}
