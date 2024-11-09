import 'package:cash_control/ui/packer/requests.dart';
import 'package:cash_control/ui/client/widgets/appbar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dashboard',
      home: DashboardScreen(),
    );
  }
}
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: "Фасовка"),
      body: GridView.count(
        crossAxisCount: 2, // Still showing 2 cards per row
        padding: const EdgeInsets.all(16),
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
              MaterialPageRoute(builder: (context) =>  Requests()),
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

  const DashboardCard({super.key, 
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
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
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


