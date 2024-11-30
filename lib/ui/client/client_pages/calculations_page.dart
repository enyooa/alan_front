import 'package:flutter/material.dart';

class CalculationsPage extends StatelessWidget {
  const CalculationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Расчеты')),
      body: const Center(
        child: Text(
          'Расчеты и аналитика',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
