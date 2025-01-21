import 'package:alan/bloc/blocs/packer_page_blocs/blocs/couriers_bloc.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/blocs/packer_history_document_bloc.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/repo/courier_repo.dart';
import 'package:alan/constant.dart';
import 'package:alan/ui/main/widgets/profile.dart';
import 'package:alan/ui/packer/pages/courier.dart';
import 'package:alan/ui/packer/pages/main_page.dart';
import 'package:alan/ui/packer/pages/packaging.dart';
import 'package:alan/ui/packer/pages/requests.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PackerScreen extends StatefulWidget {
  @override
  _PackerScreenState createState() => _PackerScreenState();
}

class _PackerScreenState extends State<PackerScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(), // Заявка Page
    const RequestsScreen(), // Накладная Page
    const PackagingScreen(), // Склад Page
    // const CourierScreen(), // Курьеры Page
    const AccountView(),
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
        BlocProvider(
          create: (context) => CourierBloc(repository: CourierRepository(baseUrl: baseUrl)),
          child: CourierScreen(),
        ),
         BlocProvider(
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
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: 'Заявка',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Накладная',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.warehouse),
              label: 'Склад',
            ),
            // const BottomNavigationBarItem(
            //   icon: Icon(Icons.people),
            //   label: 'Курьеры',
            // ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }
}