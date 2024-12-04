import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/product_card_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/product_sale_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/product_subcard_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_card_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_sale_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_subcard_event.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/blocs/basket_bloc.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/blocs/favorite_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widgets/bottom_nav_bar.dart'; // Update to point to your BottomNavBar file

class ClientHome extends StatelessWidget {
  const ClientHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BasketBloc>(
      create: (context) => BasketBloc(),
    ),
    BlocProvider<FavoritesBloc>(
      create: (context) => FavoritesBloc(),
    ),
        BlocProvider<ProductSubCardBloc>(
          create: (context) => ProductSubCardBloc()..add(FetchProductSubCardsEvent()),
        ),
        BlocProvider<ProductCardBloc>(
          create: (context) => ProductCardBloc()..add(FetchProductCardsEvent()),
        ),
        BlocProvider<SalesBloc>(
          create: (context) => SalesBloc()..add(FetchSalesEvent()),
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: BottomNavBar(), // Point to the BottomNavBar for navigation
      ),
    );
  }
}
