import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Requests(),
    );
  }
}

class Requests extends StatelessWidget {
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("наименование клиента", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("адрес доставки", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Table(
              border: TableBorder.all(color: Colors.grey),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade300),
                  children: [
                    Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text('наименование'))),
                    Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text('ед изм'))),
                    Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text('количество'))),
                    Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text('цена'))),
                    Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text('сумма'))),
                  ],
                ),
                // Add as many rows as needed
                for (int i = 0; i < 10; i++)
                  TableRow(
                    children: [
                      Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                      Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                      Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                      Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                      Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                    ],
                  ),
                TableRow(
                  children: [
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Итого', style: TextStyle(fontWeight: FontWeight.bold))),
                    Text(''),
                    Text(''),
                    Text(''),
                    Text(''),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.article),
                  color: Colors.blue,
                  onPressed: () {},
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.print),
                  color: Colors.blue,
                  onPressed: () {},
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue, backgroundColor: Colors.lightBlue.shade100,
              ),
              onPressed: () {},
              child: Text("в работе"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue, backgroundColor: Colors.lightBlue.shade100,
              ),
              onPressed: () {},
              child: Text("Создать накладную"),
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
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        onTap: (index) {},
      ),
    );
  }
}
