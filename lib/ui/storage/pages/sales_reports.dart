import 'package:flutter/material.dart';
import 'package:cash_control/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({Key? key}) : super(key: key);

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  List<dynamic> salesData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSalesData();
  }

  Future<void> _fetchSalesData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }

    final url = Uri.parse(baseUrl + 'fetchSalesReport');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          salesData = data['sales'];
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка получения данных: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Отчет по продажам', style: headingStyle),
        backgroundColor: primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildTable(),
    );
  }

  Widget _buildTable() {
    if (salesData.isEmpty) {
      return const Center(child: Text('Нет данных для отображения.', style: tableHeaderStyle));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(primaryColor),
          dataRowColor: MaterialStateProperty.all(Colors.grey.shade100),
          border: TableBorder.all(color: borderColor),
          headingTextStyle: tableHeaderStyle,
          dataTextStyle: tableCellStyle,
          columns: const [
            DataColumn(label: Text('Наименование', style: tableHeaderStyle)),
            DataColumn(label: Text('Ед Изм', style: tableHeaderStyle)),
            DataColumn(label: Text('Количество', style: tableHeaderStyle)),
            DataColumn(label: Text('Цена', style: tableHeaderStyle)),
            DataColumn(label: Text('Сумма', style: tableHeaderStyle)),
          ],
          rows: salesData.map((sale) {
            return DataRow(
              cells: [
                DataCell(Text(sale['product'] ?? '', style: tableCellStyle)),
                DataCell(Text(sale['unit'] ?? '', style: tableCellStyle)),
                DataCell(Text(sale['quantity'].toString(), style: tableCellStyle)),
                DataCell(Text(sale['price'].toString(), style: tableCellStyle)),
                DataCell(Text(sale['total'].toString(), style: tableCellStyle)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
