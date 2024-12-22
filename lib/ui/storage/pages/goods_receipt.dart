import 'package:flutter/material.dart';

class GoodsReceiptPage extends StatelessWidget {
  const GoodsReceiptPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to goods receipt creation logic
          },
          child: const Text('Добавить Поступление ТМЗ'),
        ),
      ),
    );
  }
}
