import 'package:flutter/material.dart';



class PackerScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<PackerScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> orders = [
    {'name': 'Магнум Сагындык 44', 'status': ''},
    {'name': 'Магнум Турган 55', 'status': ''},
    {'name': 'Ресторан Мята', 'status': 'в работе'},
    {'name': 'Ресторан Пинта', 'status': 'передано курьеру'},
    {'name': 'Магазин Сакен', 'status': 'Доставлено'},
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
        title: Text('Заявки', style: TextStyle(color: Colors.blue)),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.blue),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return ListTile(
            title: Text(
              order['name'],
              style: TextStyle(
                fontWeight: order['status'].isEmpty ? FontWeight.bold : FontWeight.normal,
                fontSize: order['status'].isEmpty ? 18 : 16,
              ),
            ),
            trailing: Text(
              order['status'],
              style: TextStyle(
                color: order['status'] == 'в работе'
                    ? Colors.orange
                    : order['status'] == 'передано курьеру'
                        ? Colors.blue
                        : order['status'] == 'Доставлено'
                            ? Colors.red
                            : Colors.black,
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
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
            icon: Icon(Icons.people),
            label: 'Курьеры',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
