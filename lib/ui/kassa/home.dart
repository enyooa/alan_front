import 'package:flutter/material.dart';

void main() {
  runApp(CashControlApp());
}

class CashControlApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainMenu(),
    );
  }
}

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cash Control'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section for "касса" (Cash)
            ElevatedButton(
              onPressed: () {
                // Navigate to cash operations
              },
              child: Text('Касса (Cash Operations)'),
            ),
            SizedBox(height: 20),
            // Section for "Отчет по расходам" (Expense Report)
            ElevatedButton(
              onPressed: () {
                // Navigate to expense report
              },
              child: Text('Отчет по расходам (Expense Report)'),
            ),
            SizedBox(height: 20),
            // Section for "Отчет по долгам" (Debt Report)
            ElevatedButton(
              onPressed: () {
                // Navigate to debt report
              },
              child: Text('Отчет по долгам (Debt Report)'),
            ),
            SizedBox(height: 20),
            // Section for "сформировать" (Generate Report)
            ElevatedButton(
              onPressed: () {
                // Action for generating reports
              },
              child: Text('Сформировать (Generate Report)'),
            ),
          ],
        ),
      ),
    );
  }
}
