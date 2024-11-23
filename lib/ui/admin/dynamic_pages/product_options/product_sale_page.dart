import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cash_control/constant.dart';

class ProductSalePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Продажа',
          style: headingStyle,
        ),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Продажа",
              style: titleStyle,
            ),
            const SizedBox(height: 10),
            _buildSaleTable(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.filePdf, color: Colors.red),
                  onPressed: () {
                    // Add functionality for exporting to PDF
                  },
                ),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.fileExcel, color: Colors.green),
                  onPressed: () {
                    // Add functionality for exporting to Excel
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleTable() {
    return Table(
      border: TableBorder.all(color: borderColor),
      children: [
        TableRow(
          decoration: BoxDecoration(color: primaryColor.withOpacity(0.2)),
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Наименование', style: tableHeaderStyle),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Ед изм', style: tableHeaderStyle),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Кол-во', style: tableHeaderStyle),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Цена', style: tableHeaderStyle),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Сумма', style: tableHeaderStyle),
            ),
          ],
        ),
        // Example data row
        TableRow(
          children: List.generate(
            5,
            (index) => const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('-', style: bodyTextStyle),
            ),
          ),
        ),
      ],
    );
  }
}
