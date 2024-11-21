import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cash_control/constant.dart';

class DynamicReportPage extends StatefulWidget {
  @override
  _DynamicReportPageState createState() => _DynamicReportPageState();
}

class _DynamicReportPageState extends State<DynamicReportPage> {
  String selectedReport = 'Отчет по кассе';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Отчет', style: headingStyle),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Flexible(
                  child: DropdownButton<String>(
                    value: selectedReport,
                    items: const [
                      DropdownMenuItem(
                        value: 'Отчет по кассе',
                        child: Text('Отчет по кассе', style: bodyTextStyle),
                      ),
                      DropdownMenuItem(
                        value: 'Отчет по складу',
                        child: Text('Отчет по складу', style: bodyTextStyle),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedReport = value!;
                      });
                    },
                    style: bodyTextStyle,
                    dropdownColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Add logic to generate the report
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                  child: const Text("Сформировать", style: buttonTextStyle),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: selectedReport == 'Отчет по кассе'
                  ? _buildCashReport()
                  : _buildInventoryReport(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to display the Cash Report
  Widget _buildCashReport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("Отчет по кассе", style: headingStyle),
        const SizedBox(height: 10),
        Table(
          border: TableBorder.all(color: Colors.grey),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade300),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('остаток на начало дня', style: tableHeaderStyle),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('приход', style: tableHeaderStyle),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('расход', style: tableHeaderStyle),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('сальдо на конец дня', style: tableHeaderStyle),
                ),
              ],
            ),
            TableRow(
              children: List.generate(
                4,
                (index) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('', style: bodyTextStyle),
                ),
              ),
            ),
          ],
        ),
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
    );
  }

  // Widget to display the Inventory Report
  Widget _buildInventoryReport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("Отчет по складу", style: headingStyle),
        const SizedBox(height: 10),
        Table(
          border: TableBorder.all(color: Colors.grey),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade300),
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
                  child: Text('Приход кол', style: tableHeaderStyle),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Расход кол', style: tableHeaderStyle),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Остаток кол', style: tableHeaderStyle),
                ),
              ],
            ),
            TableRow(
              children: List.generate(
                5,
                (index) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('', style: bodyTextStyle),
                ),
              ),
            ),
          ],
        ),
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
    );
  }
}
