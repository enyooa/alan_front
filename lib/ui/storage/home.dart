import 'package:cash_control/ui/admin/dynamic_pages/product_options/product_inventory_page.dart';
import 'package:cash_control/ui/storage/pages/TMZreport.dart';
import 'package:cash_control/ui/storage/pages/goods_receipt.dart';
import 'package:cash_control/ui/storage/pages/sales_reports.dart';
import 'package:cash_control/ui/storage/pages/write_off.dart';
import 'package:flutter/material.dart';
import 'package:cash_control/constant.dart';

class StoragePage extends StatefulWidget {
  const StoragePage({Key? key}) : super(key: key);

  @override
  _StoragePageState createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    SalesReport(),
    TMZReport(),
    GoodsReceiptPage(),
    WriteOffPage(),
    // InventoryPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        selectedItemColor: primaryColor, // Highlight selected icon with primary color
        unselectedItemColor: unselectednavbar, // Grey color for unselected items
        backgroundColor: Colors.white, // Modern white background
        selectedLabelStyle: captionStyle.copyWith(
          fontWeight: FontWeight.bold,
        ), // Stylish font for selected labels
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
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.inventory),
          //   label: 'Инвентаризация',
          // ),
        ],
      ),
    );
  }
}
