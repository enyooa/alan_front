import 'package:flutter/material.dart';
import 'package:cash_control/constant.dart';
import 'package:cash_control/ui/client/widgets/appbar.dart';

class SalesReport extends StatefulWidget {
  const SalesReport({super.key});

  @override
  _SalesReportAppState createState() => _SalesReportAppState();
}

class _SalesReportAppState extends State<SalesReport> {
  final List<List<String>> _tableData = []; // To store rows from Excel file

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Отчет по продажам',
              style: subheadingStyle, // Modern heading style
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildTable()), // Expand table to fit the screen
          ],
        ),
      ),
    );
  }

  // Function to build the DataTable
  Widget _buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          headingRowColor:
              MaterialStateProperty.all(primaryColor), // Stylish header color
          dataRowColor: MaterialStateProperty.all(Colors.white), // Clean row color
          border: TableBorder.all(color: borderColor, width: 1), // Consistent border styling
          headingTextStyle: tableHeaderStyle, // Use consistent header style
          dataTextStyle: tableCellStyle, // Use consistent cell style
          columns: _buildColumns(),
          rows: _buildRows(),
        ),
      ),
    );
  }

  // Function to dynamically generate columns
  List<DataColumn> _buildColumns() {
    if (_tableData.isNotEmpty) {
      return _tableData[0]
          .map((header) => DataColumn(label: Text(header, style: tableHeaderStyle)))
          .toList();
    } else {
      return [
        const DataColumn(label: Text('Наименование', style: tableHeaderStyle)),
        const DataColumn(label: Text('Ед Изм', style: tableHeaderStyle)),
        const DataColumn(label: Text('Количество', style: tableHeaderStyle)),
        const DataColumn(label: Text('Цена', style: tableHeaderStyle)),
        const DataColumn(label: Text('Сумма', style: tableHeaderStyle)),
      ];
    }
  }

  // Function to dynamically generate rows
  List<DataRow> _buildRows() {
    if (_tableData.length > 1) {
      return _tableData
          .sublist(1) // Skip the header row
          .map(
            (row) => DataRow(
              cells: row.map((cell) => DataCell(Text(cell, style: tableCellStyle))).toList(),
            ),
          )
          .toList();
    } else {
      // Default empty rows if no data is available
      return List<DataRow>.generate(
        10,
        (index) => DataRow(
          cells: [
            DataCell(Text('Продукт#: $index', style: tableCellStyle)),
            const DataCell(Text('Тг', style: tableCellStyle)),
            DataCell(Text('${index * 2}', style: tableCellStyle)),
            const DataCell(Text('100', style: tableCellStyle)),
            DataCell(Text('${index * 2 * 100}', style: tableCellStyle)),
          ],
        ),
      );
    }
  }
}
