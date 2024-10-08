import 'package:cash_control/ui/scaffold_parts/header.dart';
import 'package:flutter/material.dart';


class Requests extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Header(title: 'отчет по продажам',),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle the "сформировать" button press
                  },
                  child: Text('сформировать'),
                ),
                Text(
                  'дата число год',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  buildReportTableHeader(),
                  buildReportRow('список документов','поступило'),
                  buildReportRow('список документов','поступило'),
                  // Add more rows as needed
                ],
              ),
            ),
            SizedBox(height: 20),
            ],
        ),
      ),
    );
  }

  Widget buildReportTableHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildTableCell('наименование'),
        buildTableCell('поступило'),
        
      ],
    );
  }

  Widget buildReportRow(String name, String quantity) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildTableCell(name),
        
        buildTableCell(quantity),
        
      ],
    );
  }

  Widget buildTableCell(String text) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}