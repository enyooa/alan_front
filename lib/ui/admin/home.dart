import 'package:alan/bloc/blocs/admin_page_blocs/blocs/address_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/inventory_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/operations_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/price_offer_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/product_card_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/product_receiving_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/product_sale_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/product_subcard_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/storage_address_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/blocs/provider_bloc.dart';
import 'package:alan/constant.dart';
import 'package:alan/ui/admin/dynamic_pages/dynamic_product_page.dart';
import 'package:alan/ui/admin/dynamic_pages/dynamic_report_page.dart';
import 'package:alan/ui/admin/dynamic_pages/reference_page.dart';
import 'package:alan/ui/admin/dynamic_pages/form_pages/product_card_page.dart';
import 'package:alan/ui/admin/dynamic_pages/form_pages/subproduct_card_page.dart';
import 'package:alan/ui/main/widgets/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/blocs/unit_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/blocs/employee_bloc.dart';
import 'package:alan/ui/admin/dynamic_pages/dynamic_form_page.dart';

class AdminDashboardScreen extends StatefulWidget {
  
  const AdminDashboardScreen({
    Key? key,
   
  }) : super(key: key);

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    DynamicReportPage(),
    DynamicProductPage(),
    DynamicFormPage(),
    OperationHistoryPage(),
    const AccountView(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ProductCardBloc(),child: ProductCardPage(),),        
        BlocProvider(create: (context) => UserBloc()),
        // BlocProvider(create: (context) => OrganizationBloc(organizationService: widget.organizationService)),
        BlocProvider(create: (context) => UnitBloc()),
        BlocProvider(create: (context) => ProviderBloc()),

        BlocProvider(create: (context) => ProductSubCardBloc(),child: ProductSubCardPage(),),        
        BlocProvider(create: (context) => ProductReceivingBloc()),
        BlocProvider(create: (context) => SalesBloc()),
        BlocProvider(create: (context) => InventoryBloc()),
        BlocProvider(create: (context) => PriceOfferBloc()),

        BlocProvider(create: (context) => OperationsBloc()),

        BlocProvider(create: (context) => AddressBloc()),
        BlocProvider(create: (_) => StorageAddressBloc()),



      ],
      child: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: primaryColor,
          unselectedItemColor: unselectednavbar,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Отчеты',),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Товары'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Справка'),
            BottomNavigationBarItem(icon: Icon(Icons.history),label: 'Справочная'),
            BottomNavigationBarItem(icon: Icon(Icons.person),label: 'Профиль'),


          ],
        ),
      ),
    );
  }
}
