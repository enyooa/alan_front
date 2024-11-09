import 'package:cash_control/ui/storage/TMZreport.dart';
import 'package:cash_control/ui/client/widgets/appbar.dart';
import 'package:cash_control/ui/client/widgets/bottom_nav_bar.dart';
import 'package:cash_control/ui/widgets/dashboard_card.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
class StorageScreen extends StatelessWidget {
  const StorageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
      
        fontFamily: 'Merriweather',
      
      ),
      debugShowCheckedModeBanner: false,
      title: 'Dashboard',
      home: const DashboardScreen(),
    );
  }
}
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});



 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(
        title: "Склад"
      ),
      body: GridView.count(
        crossAxisCount: 2, // Still showing 2 cards per row
        padding: const EdgeInsets.all(5),
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        children: [
          DashboardCard(title: 'Поступление ТМЗ', onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => TMZReport()));

          }, icon: HugeIcons.strokeRoundedWarehouse),
          DashboardCard(title: 'Склад', onTap: () {}, icon: Icons.inventory),
          DashboardCard(title: 'Продажа', onTap: () {}, icon: Icons.shopping_cart),
          DashboardCard(title: 'Отчет по продажам', onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SalesReportScreen()),
            );
          }, icon: Icons.bar_chart),
          DashboardCard(title: 'Списание', onTap: () {}, icon: Icons.delete),
          DashboardCard(title: 'Инвентаризация', onTap: () {}, icon: Icons.fact_check),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}




class SalesReportScreen extends StatelessWidget {
  const SalesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: "Отчет по продажам"),
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
                  child: const Text('сформировать'),
                ),
                const Text(
                  'дата число год',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            const Row(
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
        padding: const EdgeInsets.all(8.0),
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
