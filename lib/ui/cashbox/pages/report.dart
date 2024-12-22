import 'package:flutter/material.dart';
import 'package:cash_control/constant.dart';

class CashReportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: pagePadding,
        child: Column(
          children: [
            // Filter Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    // Handle date filter action
                  },
                  child: Text(
                    'Дата с по',
                    style: bodyTextStyle.copyWith(color: primaryColor),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: DropdownButton<String>(
                    underline: SizedBox(),
                    hint: Text(
                      'Выбор счета',
                      style: bodyTextStyle,
                    ),
                    items: ['Счет 1', 'Счет 2', 'Счет 3']
                        .map((String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: bodyTextStyle),
                            ))
                        .toList(),
                    onChanged: (value) {
                      // Handle dropdown selection
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle generate action
                  },
                  style: elevatedButtonStyle,
                  child: Text(
                    'сформировать',
                    style: buttonTextStyle,
                  ),
                ),
              ],
            ),
            Divider(color: borderColor),
            // Data Table
            DataTable(
              sortColumnIndex: 1,
              showCheckboxColumn: false,
              border: TableBorder.all(color: borderColor, width: 1.0),
              columns: const <DataColumn>[
                DataColumn(
                  label: Text(
                    'остаток на начало дня',
                    style: subheadingStyle,
                  ),
                ),
                DataColumn(
                  label: Text(
                    '',
                    style: subheadingStyle,
                  ),
                ),
                DataColumn(
                  label: Text(
                    '',
                    style: subheadingStyle,
                  ),
                ),
              ],
              rows: <DataRow>[
                DataRow(cells: [
                  DataCell(
                    Text(
                      'Приход',
                      style: bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataCell(
                    Text(
                      '34,000',
                      style: bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataCell(
                    Text(
                      '1,200',
                      style: bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ]),
                DataRow(cells: [
                  DataCell(
                    Text(
                      'Расход',
                      style: bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataCell(
                    Text(
                      '29,000',
                      style: bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataCell(
                    Text(
                      '1,000',
                      style: bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ]),
                DataRow(cells: [
                  DataCell(
                    Text(
                      'Сальдо на конец дня',
                      style: bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataCell(
                    Text(
                      '24,000',
                      style: bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataCell(
                    Text(
                      '800',
                      style: bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ]),
              ],
            ),
            SizedBox(height: verticalPadding),
            // Export Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.table_chart, color: primaryColor),
                  onPressed: () {
                    // Handle export to table
                  },
                ),
                IconButton(
                  icon: Icon(Icons.picture_as_pdf, color: primaryColor),
                  onPressed: () {
                    // Handle export to PDF
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
