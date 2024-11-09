import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CourierScreen(),
    );
  }
}

class CourierScreen extends StatelessWidget {
  final List<Map<String, String>> couriers = [
    {'name': 'Асенов Асенов', 'location': 'Магнум Сыганак 44'},
    {'name': 'Хасан Хасанович', 'location': 'Магнум Турган 55'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('курьер', style: TextStyle(color: Colors.blue)),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue, backgroundColor: Colors.lightBlue.shade100,
              ),
              onPressed: () {},
              child: Text("ФИО курьера"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue, backgroundColor: Colors.lightBlue.shade100,
              ),
              onPressed: () {},
              child: Text("Накладная"),
            ),
            SizedBox(height: 20),
            for (var courier in couriers)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(courier['name'] ?? '', style: TextStyle(fontSize: 16)),
                    Text(courier['location'] ?? '', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
          ],
        ),
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
        currentIndex: 3,
        selectedItemColor: Colors.blue,
        onTap: (index) {},
      ),
    );
  }
}
