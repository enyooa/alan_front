import 'package:flutter/material.dart';

class ProductSalePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("Продажа"),
        const SizedBox(height: 10),
        Table(
          border: TableBorder.all(color: Colors.grey),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade300),
              children: const [
                Padding(padding: EdgeInsets.all(8.0), child: Text('Наименование')),
                Padding(padding: EdgeInsets.all(8.0), child: Text('Ед изм')),
                Padding(padding: EdgeInsets.all(8.0), child: Text('Кол-во')),
                Padding(padding: EdgeInsets.all(8.0), child: Text('Цена')),
                Padding(padding: EdgeInsets.all(8.0), child: Text('Сумма')),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
