import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cash_control/constant.dart';

class DynamicReportPage extends StatefulWidget {
  @override
  _DynamicReportPageState createState() => _DynamicReportPageState();
}

class _DynamicReportPageState extends State<DynamicReportPage> {
  String selectedReport = 'Отчет по кассе';

  final List<Map<String, dynamic>> reportOptions = [
    {'label': 'Отчет по кассе', 'icon': FontAwesomeIcons.cashRegister},
    {'label': 'Отчет по складу', 'icon': FontAwesomeIcons.warehouse},
  ];

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
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedReport,
                    items: reportOptions.map((report) {
                      return DropdownMenuItem<String>(
                        value: report['label'],
                        child: Row(
                          children: [
                            FaIcon(report['icon'], size: 16, color: primaryColor),
                            const SizedBox(width: 8),
                            Text(report['label'], style: bodyTextStyle),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedReport = value!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Выберите отчет',
                      labelStyle: formLabelStyle,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
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

  Widget _buildCashReport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("Отчет по кассе", style: titleStyle),
        const SizedBox(height: 10),
        Table(
          border: TableBorder.all(color: borderColor),
          children: [
            TableRow(
              decoration: BoxDecoration(color: primaryColor.withOpacity(0.2)),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Остаток на начало дня', style: tableHeaderStyle),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Приход', style: tableHeaderStyle),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Расход', style: tableHeaderStyle),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Сальдо на конец дня', style: tableHeaderStyle),
                ),
              ],
            ),
            TableRow(
              children: List.generate(
                4,
                (index) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('-', style: bodyTextStyle),
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

  Widget _buildInventoryReport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("Отчет по складу", style: headingStyle),
        const SizedBox(height: 10),
        Table(
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
                  child: Text('Приход', style: tableHeaderStyle),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Расход', style: tableHeaderStyle),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Остаток', style: tableHeaderStyle),
                ),
              ],
            ),
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
