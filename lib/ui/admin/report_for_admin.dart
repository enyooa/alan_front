import 'package:cash_control/constant.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Отчет'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Filters and buttons (date range, report type, etc.)
            Row(
              children: [
                Flexible(child: ElevatedButton(onPressed: () {}, child: Text("дата с по"))),
                SizedBox(width: 8),
                Flexible(child: ElevatedButton(onPressed: () {}, child: Text("касса/продажа/склад"))),
                SizedBox(width: 8),
                Flexible(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text("сформировать"),
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // "Отчет по кассе" table
            Text(
              "Отчет по кассе",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Table(
              border: TableBorder.all(color: Colors.grey),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade300),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('остаток на начало дня'),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('приход'),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('расход'),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('сальдо на конец дня'),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.filePdf, color: Colors.red),
                  onPressed: () {
                    // Add functionality for exporting to PDF
                  },
                ),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.fileExcel, color: Colors.green),
                  onPressed: () {
                    // Add functionality for exporting to Excel
                  },
                ),
              ],
            ),
            SizedBox(height: 16),

            // "Отчет по продажам" table
            Text(
              "Отчет по продажам",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Table(
                  border: TableBorder.all(color: Colors.grey),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey.shade300),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('наименование'),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('ед изм'),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('кол во'),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('цена'),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('сумма'),
                        ),
                      ],
                    ),
                    // Rows with empty cells
                    for (int i = 0; i < 10; i++)
                      TableRow(
                        children: [
                          Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                          Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                          Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                          Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                          Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                        ],
                      ),
                    // Total row
                    TableRow(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Итого',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(''),
                        Text(''),
                        Text(''),
                        Text(''),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.filePdf, color: Colors.red),
                  onPressed: () {
                    // Add functionality for exporting sales report to PDF
                  },
                ),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.fileExcel, color: Colors.green),
                  onPressed: () {
                    // Add functionality for exporting sales report to Excel
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart),
            label: 'отчеты',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Товар',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help),
            label: 'справка',
          ),
        ],
      ),
    );
  }
}
