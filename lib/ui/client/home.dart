

import 'package:alan/bloc/blocs/admin_page_blocs/blocs/address_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/blocs/card_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/blocs/client_order_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/blocs/financial_order_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/blocs/price_offer_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/blocs/sub_card_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/card_event.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/client_order_event.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/price_offer_event.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/sub_card_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'widgets/bottom_nav_bar.dart'; // Update to point to your BottomNavBar file

class ClientHome extends StatelessWidget {
  const ClientHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        
        BlocProvider<ProductSubCardBloc>(
          create: (context) => ProductSubCardBloc()..add(FetchProductSubCardsEvent()),
        ),
        BlocProvider<ProductCardBloc>(
          create: (context) => ProductCardBloc()..add(FetchProductCardsEvent()),
        ),
        BlocProvider<FinancialOrderBloc>(
          create: (context) => FinancialOrderBloc(),
        ),
        
        BlocProvider<AddressBloc>(
          create: (context) => AddressBloc(),
        ),
        BlocProvider(
          create: (context) => PriceOfferBloc()
            ..add(FetchPriceOffersEvent()),
        ),
        BlocProvider<ClientOrderBloc>(
          create: (context) => ClientOrderBloc()..add(FetchClientOrdersEvent()),
        ),
      //   BlocProvider(
      //   create: (context) => BasketBloc(repository: BasketRepository(baseUrl: baseUrl)),
      // ),

      ],
      child: BottomNavBar(),
    );
  }
}
