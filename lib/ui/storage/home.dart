import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Ваши импорты
import 'package:alan/bloc/blocs/common_blocs/blocs/unit_bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/blocs/general_warehouse_bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/blocs/storage_receiving_bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/blocs/write_off_bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/blocs/storage_sales_bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/blocs/storage_references_bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/blocs/storage_report_bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/blocs/sales_bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/events/storage_references_event.dart';

import 'package:alan/ui/storage/pages/sales_reports.dart';
import 'package:alan/ui/storage/pages/sales.dart';
import 'package:alan/ui/storage/pages/goods_receipt.dart';
import 'package:alan/ui/storage/pages/write_off.dart';
import 'package:alan/ui/main/widgets/profile.dart';

import 'package:alan/constant.dart';

class StoragePage extends StatefulWidget {
  const StoragePage({Key? key}) : super(key: key);

  @override
  _StoragePageState createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  int _selectedIndex = 0;

  // Ваши страницы (экраны), которые будут выводиться в body: _pages[_selectedIndex]
  final List<Widget> _pages = [
    SalesReportPage(),
    StoragerSalePage(),
    GoodsReceiptPage(),
    WriteOffPage(),
    AccountView(),
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
        // Главное: нигде не передаём child в самих BlocProvider. 
        // Только один общий child у MultiBlocProvider!
        BlocProvider<SalesStorageBloc>(
          create: (_) => SalesStorageBloc(),
        ),
        BlocProvider<StorageReceivingBloc>(
          create: (_) => StorageReceivingBloc(),
        ),
        BlocProvider<WriteOffBloc>(
          create: (_) => WriteOffBloc(),
        ),
        BlocProvider<StorageReferencesBloc>(
          create: (_) => StorageReferencesBloc()..add(FetchAllInstancesEvent()),
        ),
        BlocProvider<UnitBloc>(
          create: (_) => UnitBloc(),
        ),
        BlocProvider<GeneralWarehouseBloc>(
          create: (_) => GeneralWarehouseBloc(),
        ),
        BlocProvider<StorageReportBloc>(
          create: (_) => StorageReportBloc(),
        ),
        // StorageSalesBloc, если нужен отдельно
        BlocProvider<StorageSalesBloc>(
          create: (_) => StorageSalesBloc(),
        ),
      ],
      // Общий child для MultiBlocProvider — Scaffold со страницами
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Склад',
            style: headingStyle, // Using the heading style from constants
          ),
          backgroundColor: primaryColor, // Consistent primary color
          centerTitle: true, // Centered title for a modern look
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: primaryColor,
          unselectedItemColor: unselectednavbar,
          backgroundColor: Colors.white,
          selectedLabelStyle: captionStyle.copyWith(fontWeight: FontWeight.bold),
          unselectedLabelStyle: captionStyle,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Отчет',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt),
              label: 'Накладная',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_shopping_cart),
              label: 'Поступление',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.remove_shopping_cart),
              label: 'Списание',
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
