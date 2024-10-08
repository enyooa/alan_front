import 'package:cash_control/ui/scaffold_parts/header.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dashboard',
      home: DashboardScreen(),
    );
  }
}
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Header(title: "склад"),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications button press
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2, // Still showing 2 cards per row
        padding: EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          DashboardCard(title: 'Поступление ТМЗ', onTap: () {}, icon: Icons.store),
          DashboardCard(title: 'Склад', onTap: () {}, icon: Icons.inventory),
          DashboardCard(title: 'Продажа', onTap: () {}, icon: Icons.shopping_cart),
          DashboardCard(title: 'Отчет по продажам', onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SalesReportScreen()),
            );
          }, icon: Icons.bar_chart),
          DashboardCard(title: 'Списание', onTap: () {}, icon: Icons.delete),
          DashboardCard(title: 'Инвентаризация', onTap: () {}, icon: Icons.fact_check),
        ],
      ),
    );
  }
}


class DashboardCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final IconData icon; // Replaced ImageProvider with IconData

  const DashboardCard({
    required this.title,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50, // Reduced height
        width: 50,  // Reduced width
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 100, // Icon size
              color: Colors.blueAccent,
            ),
            SizedBox(height: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 20, // Reduced font size for a smaller button
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class SalesReportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Header(title: 'отчет по продажам',),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle the "сформировать" button press
                  },
                  child: Text('сформировать'),
                ),
                Text(
                  'дата число год',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  buildReportTableHeader(),
                  buildReportRow('Товар 1', 'шт', '10', '100', '1000'),
                  buildReportRow('Товар 2', 'шт', '5', '200', '1000'),
                  // Add more rows as needed
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Итого: 2000',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildReportTableHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildTableCell('наименование'),
        buildTableCell('ед изм'),
        buildTableCell('количество'),
        buildTableCell('цена'),
        buildTableCell('сумма'),
      ],
    );
  }

  Widget buildReportRow(String name, String unit, String quantity, String price, String sum) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildTableCell(name),
        buildTableCell(unit),
        buildTableCell(quantity),
        buildTableCell(price),
        buildTableCell(sum),
      ],
    );
  }

  Widget buildTableCell(String text) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
