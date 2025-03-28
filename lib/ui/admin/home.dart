import 'package:alan/bloc/blocs/admin_page_blocs/blocs/address_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/docs_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/inventory_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/operations_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/price_offer_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/product_card_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/product_receiving_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/product_sale_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/product_subcard_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/storage_address_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/write_off_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/blocs/provider_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/events/employee_event.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/blocs/storage_report_bloc.dart';
import 'package:alan/constant.dart';
import 'package:alan/ui/admin/dynamic_pages/dynamic_product_page.dart';
import 'package:alan/ui/admin/dynamic_pages/dynamic_report_page.dart';

import 'package:alan/ui/main/widgets/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/blocs/unit_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/blocs/employee_bloc.dart';
import 'package:alan/ui/admin/dynamic_pages/dynamic_form_page.dart';
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  // The pages used in the bottom nav
  final List<Widget> _pages = [
    DynamicReportPage(),
    DynamicProductPage(),
    DynamicFormPage(), // <--- Here is where we have the FAB to create "Address"
    const AccountView(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Provide the userBloc once here
        BlocProvider(create: (context) => UserBloc()..add(FetchUsersEvent())),
        BlocProvider(create: (context) => ProductCardBloc()),
        BlocProvider(create: (context) => UnitBloc()),
        BlocProvider(create: (context) => ProviderBloc()),
        BlocProvider(create: (_) => ProductWriteOffBloc()),
        BlocProvider(create: (context) => ProductSubCardBloc()),
        BlocProvider(create: (context) => ProductReceivingBloc()),
        BlocProvider(create: (context) => SalesBloc()),
        BlocProvider(create: (context) => InventoryBloc()),
        BlocProvider(create: (context) => StorageReportBloc()),
        BlocProvider(create: (context) => PriceOfferBloc()),
        BlocProvider(create: (context) => OperationsBloc()),
        BlocProvider(create: (context) => AddressBloc()),
        BlocProvider(create: (_) => StorageAddressBloc()),
        BlocProvider(create: (_) => DocsBloc()),
      ],
      child: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          selectedItemColor: Colors.black,
          unselectedItemColor: unselectednavbar,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Отчеты'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Товары'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Справка'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
          ],
        ),
      ),
    );
  }
}
