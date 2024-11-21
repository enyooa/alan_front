import 'package:cash_control/ui/cashbox/widgets/app_bar.dart';
import 'package:flutter/material.dart';



class CashReportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CashboxAppbar(title: "Отчет по кассе"),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Filter Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text('Дата с по', style: TextStyle(color: Colors.black)),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: DropdownButton<String>(
                    underline: SizedBox(),
                    hint: Text('Выбор счета'),
                    items: ['Счет 1', 'Счет 2', 'Счет 3']
                        .map((String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                    onChanged: (value) {},
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[400],
                  ),
                  child: Text('сформировать'),
                ),
              ],
            ),
            Divider(),
            // Data Table
            DataTable(
              sortColumnIndex: 1,
              showCheckboxColumn: false,
              border: TableBorder.all(width: 1.0),
              columns: const <DataColumn>[
                DataColumn(
                  label: Text(
                    'остаток на начало дня',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    '',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    '',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              rows: <DataRow>[
                DataRow(cells: [
                  DataCell(
                    Text(
                      'Приход',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                  DataCell(
                    Text(
                      '34,000',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                  DataCell(
                    Text(
                      '1,200',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                ]),
                DataRow(cells: [
                  DataCell(
                    Text(
                      'Расход',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                  DataCell(
                    Text(
                      '29,000',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                  DataCell(
                    Text(
                      '1,000',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                ]),
                DataRow(cells: [
                  DataCell(
                    Text(
                      'Сальдо на конец дня',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                  DataCell(
                    Text(
                      '24,000',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                  DataCell(
                    Text(
                      '800',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                ]),
              ],
            ),
           // Export Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.table_chart, color: Colors.blue[400]),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.picture_as_pdf, color: Colors.blue[400]),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar
      );
  }
}
