import 'package:flutter/material.dart';

class ProductInventoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInventoryTable(),
        const SizedBox(height: 20),
        _buildInventoryManagerTable(),
      ],
    );
  }

  Widget _buildInventoryTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("Склад"),
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

  Widget _buildInventoryManagerTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("Информация о складовщике"),
        const SizedBox(height: 10),
        Table(
          border: TableBorder.all(color: Colors.grey),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade300),
              children: const [
                Padding(padding: EdgeInsets.all(8.0), child: Text('Имя складовщика')),
                Padding(padding: EdgeInsets.all(8.0), child: Text('Адрес складовщика')),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
