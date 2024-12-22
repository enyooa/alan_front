import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/price_offer_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/product_card_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/product_sale_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/product_subcard_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/price_offer_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_card_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_sale_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_subcard_event.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/blocs/basket_bloc.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/blocs/favorites_bloc.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/repositories/basket_repository.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/repositories/favorites_repository.dart';
import 'package:cash_control/bloc/blocs/packer_page_blocs/blocs/packer_document_bloc.dart';
import 'package:cash_control/bloc/blocs/packer_page_blocs/events/packer_document_event.dart';
import 'package:cash_control/constant.dart';
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
      create: (context) => BasketBloc(repository: BasketRepository(baseUrl: baseUrl)),
    ),
    BlocProvider<FavoritesBloc>(
      create: (context) => FavoritesBloc(repository: FavoritesRepository(baseUrl: baseUrl)),
    ),
        BlocProvider<ProductSubCardBloc>(
          create: (context) => ProductSubCardBloc()..add(FetchProductSubCardsEvent()),
        ),
        BlocProvider<ProductCardBloc>(
          create: (context) => ProductCardBloc()..add(FetchProductCardsEvent()),
        ),
        BlocProvider<SalesBloc>(
          create: (context) => SalesBloc()..add(FetchSalesWithDetailsEvent()),
        ),
        BlocProvider<PackerDocumentBloc>(
          create: (context) => PackerDocumentBloc()..add(FetchPackerDocumentsEvent()),
        ),
        
        BlocProvider(
          create: (context) => PriceOfferBloc()
            ..add(FetchPriceOffersEvent()),
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: BottomNavBar(), // Point to the BottomNavBar for navigation
      ),
    );
  }
}
