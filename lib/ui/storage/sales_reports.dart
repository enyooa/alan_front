import 'package:cash_control/ui/scaffold_parts/header.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'dart:io';

void main() {
  runApp(SalesReportApp());
}

class SalesReportApp extends StatefulWidget {
  @override
  _SalesReportAppState createState() => _SalesReportAppState();
}

class _SalesReportAppState extends State<SalesReportApp> {
  List<List<String>> _tableData = [];  // To store rows from Excel file

  // Function to pick and parse Excel file


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Header(title: 'Отчет по продажам'),
          actions: [
            IconButton(
              icon: Icon(Icons.upload_file),
              onPressed: (){},
            )
          ],
        ),
        body: _buildTable(),
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
          columns: _buildColumns(),
          rows: _buildRows(),
        ),
      ),
    );
  }

  // Function to dynamically generate columns
  List<DataColumn> _buildColumns() {
    // If the tableData has rows, take the first row as the header, otherwise set default headers
    if (_tableData.isNotEmpty) {
      return _tableData[0].map((header) => DataColumn(label: Text(header))).toList();
    } else {
      return [
        DataColumn(label: Text('Наименование')),
        DataColumn(label: Text('Ед Изм')),
        DataColumn(label: Text('Количество')),
        DataColumn(label: Text('Цена')),
        DataColumn(label: Text('Сумма')),
      ];
    }
  }

  // Function to dynamically generate rows
  List<DataRow> _buildRows() {
    if (_tableData.length > 1) {
      return _tableData
          .sublist(1) // Skip the header row
          .map((row) => DataRow(
                cells: row.map((cell) => DataCell(Text(cell))).toList(),
              ))
          .toList();
    } else {
      // Default empty rows if no data is available
      return List<DataRow>.generate(
        10,
        (index) => DataRow(cells: [
          DataCell(Text('Продукт#: $index')),
          DataCell(Text('Тг')),
          DataCell(Text('${index * 2}')),
          DataCell(Text('100')),
          DataCell(Text('${index * 2 * 100}')),
        ]),
      );
    }
  }
} 
