import 'package:cash_control/constant.dart';
import 'package:cash_control/ui/courier/chat.dart';
import 'package:cash_control/ui/courier/consignment.dart';
import 'package:flutter/material.dart';

class CourierDashboardScreen extends StatefulWidget {
  @override
  _CourierDashboardScreenState createState() => _CourierDashboardScreenState();
}

class _CourierDashboardScreenState extends State<CourierDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    DeliveryHomeScreen(),
    InvoiceScreen(),
    ChatScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Кабинет курьера',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.document_scanner),
            label: 'Документ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Чат',
          ),
        ],
      ),
    );
  }
}

// Example placeholder screen for Delivery home (Главная)
class DeliveryHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 5, // Number of items
      itemBuilder: (context, index) {
        return DeliveryItem();
      },
    );
  }
}

// Example delivery item widget
class DeliveryItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue),
              SizedBox(width: 8.0),
              Text('склад №1 Кажымуханова 55', style: TextStyle(fontSize: 16.0)),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 24.0),
            child: Column(
              children: [
                Icon(Icons.arrow_downward, color: Colors.blue),
                Row(
                  children: [
                    Icon(Icons.store, color: Colors.blue),
                    SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        'магазин Магнум Есильский район ул.Сауран 5г',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
