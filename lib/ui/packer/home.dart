import 'package:alan/bloc/blocs/packer_page_blocs/blocs/all_instances_bloc.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/blocs/packer_history_document_bloc.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/blocs/packer_order_bloc.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/blocs/warehouse_bloc.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/repo/all_instances_repository.dart';
import 'package:alan/constant.dart';
import 'package:alan/ui/main/widgets/profile.dart';
import 'package:alan/ui/packer/pages/courier.dart';
import 'package:alan/ui/packer/pages/main_page.dart';
import 'package:alan/ui/packer/pages/packaging.dart';
import 'package:alan/ui/packer/pages/requests.dart';
import 'package:alan/ui/packer/widgets/create_invoice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PackerScreen extends StatefulWidget {
  const PackerScreen({Key? key}) : super(key: key);

  @override
  _PackerScreenState createState() => _PackerScreenState();
}

class _PackerScreenState extends State<PackerScreen> {
  int _selectedIndex = 0;

  // "Заявка", "Накладная", "Склад", "Профиль"
  final List<Widget> _screens = [
    const HomeScreen(),     // requests
    const RequestsScreen(), // Invoice or "Накладная"
    PackagingScreen(),      // "Склад"
    const AccountView(),    // "Профиль"
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Provide WarehouseMovementBloc ONCE
        BlocProvider<WarehouseMovementBloc>(
          create: (_) => WarehouseMovementBloc(),
        ),

        // Optionally provide other blocs:
        BlocProvider<AllInstancesBloc>(
          create: (context) => AllInstancesBloc(repository: AllInstancesRepository()),
        ),
        BlocProvider<PackerHistoryDocumentBloc>(
          create: (context) => PackerHistoryDocumentBloc(baseUrl: baseUrl),
        ),
       
      ],
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: 'Заявка',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Накладная',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.warehouse),
              label: 'Склад',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }
}
