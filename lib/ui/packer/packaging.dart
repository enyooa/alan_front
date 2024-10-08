import 'package:cash_control/ui/packer/requests.dart';
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
        title: Header(title: "Фасовка"),
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
          DashboardCard(title: 'Доступ курьерам', onTap: () {}, icon: Icons.store),
          DashboardCard(title: 'Склад', onTap: () {}, icon: Icons.inventory),
          DashboardCard(title: 'Заявки', onTap: () {

          }, icon: Icons.shopping_cart),
          DashboardCard(title: 'Продажа', onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Requests()),
            );
          }, icon: Icons.bar_chart),
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


