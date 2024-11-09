import 'package:cash_control/ui/cashbox/widgets/app_bar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Order',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ExpenseOrderScreen(),
    );
  }
}

class ExpenseOrderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CashboxAppbar(title: "Расходный ордер"),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Filter Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text('дата с по', style: TextStyle(color: Colors.black)),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('поставщик', style: TextStyle(color: Colors.black)),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[400],
                  ),
                  child: Text('Создать'),
                ),
              ],
            ),
            Divider(),
            // List of Expenses
            Expanded(
              child: ListView(
                children: [
                  ExpenseItem(date: '12.08.2024', supplier: 'вода', amount: '80 000'),
                  ExpenseItem(date: '12.08.2024', supplier: 'КСК', amount: '80 000'),
                ],
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Приходный ордер',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.outbox),
            label: 'Расходный ордер',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'Расчеты с поставщиками',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Отчет по кассе',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Справочник',
          ),
        ],
      ),
    );
  }
}

class ExpenseItem extends StatelessWidget {
  final String date;
  final String supplier;
  final String amount;

  ExpenseItem({required this.date, required this.supplier, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(supplier),
          Text(amount, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
