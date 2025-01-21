import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:alan/constant.dart';

class StorageReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Отчет по складу', style: headingStyle),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Отчет по складу", style: titleStyle),
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
        ),
      ),
    );
  }
}
