import 'package:flutter/material.dart';


class InvoiceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        title: Text('накладная'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  border: TableBorder.all(color: Colors.grey),
                  columnWidths: {
                    0: FixedColumnWidth(150.0), // Adjust width as needed
                    1: FixedColumnWidth(100.0),
                    2: FixedColumnWidth(100.0),
                    3: FixedColumnWidth(100.0),
                    4: FixedColumnWidth(100.0),
                    5: FixedColumnWidth(100.0),
                  },
                  children: [
                    TableRow(
                      children: [
                        tableCell('Наименование поставщика'),
                        tableCell('адрес доставки'),
                        tableCell('телефон'),
                        tableCell(''),
                        tableCell(''),
                        tableCell(''),
                      ],
                    ),
                    TableRow(
                      children: [
                        tableCell('наименование'),
                        tableCell('ед изм'),
                        tableCell('количество\nв поставке'),
                        tableCell('Фактическая\nпоставка'),
                        tableCell('цена'),
                        tableCell('сумма'),
                      ],
                    ),
                    for (var i = 0; i < 10; i++) // Generate multiple rows
                      TableRow(
                        children: [
                          tableCell(''),
                          tableCell(''),
                          tableCell(''),
                          tableCell(''),
                          tableCell(''),
                          tableCell(''),
                        ],
                      ),
                    TableRow(
                      children: [
                        tableCell('Итого', isHeader: true),
                        tableCell(''),
                        tableCell(''),
                        tableCell(''),
                        tableCell(''),
                        tableCell(''),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.table_chart, color: Colors.blue),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.document_scanner, color: Colors.blue),
                  onPressed: () {},
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {},
              child: Text('Отправить'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black, backgroundColor: Colors.blue[100],
              ),
            ),
          ],
        ),
      ),
       );
  }

  Widget tableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: 14.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
