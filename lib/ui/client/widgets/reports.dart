import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // For date formatting

import 'package:alan/bloc/blocs/client_page_blocs/blocs/debts_report_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/debts_report_event.dart';
import 'package:alan/bloc/blocs/client_page_blocs/states/debts_report_state.dart';

import 'package:alan/constant.dart';

class DebtsReportPage extends StatefulWidget {
  const DebtsReportPage({Key? key}) : super(key: key);

  @override
  State<DebtsReportPage> createState() => _DebtsReportPageState();
}

class _DebtsReportPageState extends State<DebtsReportPage> {
  // Optional filters
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Trigger the fetch from DebtsReportBloc
    context.read<DebtsReportBloc>().add(FetchDebtsReportEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Отчет по долгам", style: headingStyle),
        backgroundColor: primaryColor,
      ),
      body: BlocBuilder<DebtsReportBloc, DebtsReportState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorMessage != null) {
            return Center(
              child: Text('Ошибка: ${state.errorMessage}', style: bodyTextStyle),
            );
          }

          // 1) Merge Documents + Financial Orders into a single list
          final mergedRows = _mergeData(state.documents, state.financialOrders);

          // 2) Apply local date filter
          final filteredRows = _applyDateFilter(mergedRows);

          return Padding(
            padding: pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // A) Filter Row (date pickers + reset button) at top
                _buildFilterRow(),
                const SizedBox(height: 16),

                // B) The table area (Expanded so it fills remaining space)
                Expanded(
                  child: (filteredRows.isEmpty)
                      ? Text('Нет данных', style: bodyTextStyle)
                      : _buildScrollableTable(filteredRows),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // -----------------------------------------------------
  // SCROLLABLE TABLE WITH VERTICAL + HORIZONTAL SCROLL
  // -----------------------------------------------------
  Widget _buildScrollableTable(List<UnifiedRow> rows) {
    return Scrollbar(
      thumbVisibility: true, // Always show the scrollbar thumb
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTableTheme(
            data: DataTableThemeData(
              headingRowColor: MaterialStateProperty.all(primaryColor),
              headingTextStyle: tableHeaderStyle,
              dataTextStyle: tableCellStyle,
              dataRowColor: MaterialStateProperty.all(Colors.white),
              dividerThickness: 1.0,
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: DataTable(
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Название')),
                DataColumn(label: Text('Сальдо\nначало')),
                DataColumn(label: Text('Сумма заказа')),
                DataColumn(label: Text('Сумма оплаты')),
                DataColumn(label: Text('Сальдо\nконец')),
                DataColumn(label: Text('Дата')),
              ],
              rows: rows.map((row) {
                return DataRow(
                  cells: [
                    DataCell(Text(row.id)),
                    DataCell(Text(row.name)),
                    DataCell(Text(row.startSaldo.toStringAsFixed(2))),
                    DataCell(Text(row.orderSum.toStringAsFixed(2))),
                    DataCell(Text(row.paymentSum.toStringAsFixed(2))),
                    DataCell(Text(row.endSaldo.toStringAsFixed(2))),
                    DataCell(Text(row.dateString)),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------
  // DATE PICKER FILTER ROW
  // -----------------------------------------------------
  Widget _buildFilterRow() {
    return Row(
      children: [
        // 1) Pick Start Date
        ElevatedButton(
          style: elevatedButtonStyle,
          onPressed: _pickStartDate,
          child: Text('Начало', style: buttonTextStyle),
        ),
        const SizedBox(width: 8),
        if (_startDate != null)
          Text(
            DateFormat('yyyy-MM-dd').format(_startDate!),
            style: bodyTextStyle,
          ),
        const SizedBox(width: 16),

        // 2) Pick End Date
        ElevatedButton(
          style: elevatedButtonStyle,
          onPressed: _pickEndDate,
          child: Text('Конец', style: buttonTextStyle),
        ),
        const SizedBox(width: 8),
        if (_endDate != null)
          Text(
            DateFormat('yyyy-MM-dd').format(_endDate!),
            style: bodyTextStyle,
          ),
        const Spacer(),

        // 3) Reset filter
        ElevatedButton(
          style: elevatedButtonStyle.copyWith(
            backgroundColor: MaterialStateProperty.all(Colors.red),
          ),
          onPressed: () {
            setState(() {
              _startDate = null;
              _endDate = null;
            });
          },
          child: Text('Сбросить', style: buttonTextStyle),
        ),
      ],
    );
  }

  // -----------------------------------------------------
  // DATE PICKER LOGIC
  // -----------------------------------------------------
  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  // -----------------------------------------------------
  // FILTER LOGIC: Keep rows in [startDate, endDate]
  // -----------------------------------------------------
  List<UnifiedRow> _applyDateFilter(List<UnifiedRow> rows) {
    if (_startDate == null && _endDate == null) {
      return rows; // no filter
    }
    return rows.where((row) {
      final dt = row.dateValue;
      if (_startDate != null && dt.isBefore(_startDate!)) return false;
      if (_endDate != null && dt.isAfter(_endDate!)) return false;
      return true;
    }).toList();
  }

  // -----------------------------------------------------
  // MERGE LOGIC
  // -----------------------------------------------------
  List<UnifiedRow> _mergeData(
    List<Map<String, dynamic>> documents,
    List<Map<String, dynamic>> orders,
  ) {
    // 1) Convert Documents -> "Сумма заказа" = sum(document_items)
    //    "Сумма оплаты" = 0
    final docRows = documents.map((doc) {
      final docId = doc['id'].toString();
      final docName = (doc['title'] == null || doc['title'].isEmpty)
          ? 'Заказ'
          : doc['title'].toString();

      // date => created_at
      final dateStr = (doc['created_at'] ?? '').toString().split('T').first;
      final dateVal = _parseDate(dateStr);

      // Summation of DocumentItems => "Сумма заказа"
      double docSum = 0.0;
      if (doc['document_items'] != null) {
        for (final item in doc['document_items']) {
          final lineSum = double.tryParse(item['total_sum']?.toString() ?? '0') ?? 0.0;
          docSum += lineSum;
        }
      }

      return UnifiedRow(
        id: docId,
        name: docName,
        dateString: dateStr,
        dateValue: dateVal,
        orderSum: docSum,   // "Сумма заказа"
        paymentSum: 0.0,    // "Сумма оплаты"
      );
    }).toList();

    // 2) Convert Financial Orders -> "Сумма оплаты" = summary_cash
    //    "Сумма заказа" = 0
    final orderRows = orders.map((fo) {
      final foId = fo['id'].toString();
      final name = 'Оплата';

      // date => date_of_check
      final dateStr = (fo['date_of_check'] ?? '').toString().split('T').first;
      final dateVal = _parseDate(dateStr);

      final paySum = double.tryParse(fo['summary_cash']?.toString() ?? '0') ?? 0.0;

      return UnifiedRow(
        id: foId,
        name: name,
        dateString: dateStr,
        dateValue: dateVal,
        orderSum: 0.0,
        paymentSum: paySum,
      );
    }).toList();

    // 3) Combine + sort by date
    final allRows = [...docRows, ...orderRows];
    allRows.sort((a, b) => a.dateValue.compareTo(b.dateValue));

    // 4) Calculate running saldo
    double runningSaldo = 0.0;
    for (final row in allRows) {
      row.startSaldo = runningSaldo;
      // Subtract "Сумма заказа", add "Сумма оплаты"
      runningSaldo = runningSaldo - row.orderSum + row.paymentSum;
      row.endSaldo = runningSaldo;
    }

    return allRows;
  }

  /// If dateStr is invalid, return "1970-01-01"
  DateTime _parseDate(String dateStr) {
    try {
      if (dateStr.isEmpty) return DateTime(1970, 1, 1);
      return DateTime.parse(dateStr);
    } catch (_) {
      return DateTime(1970, 1, 1);
    }
  }
}

/// A single row in the merged table
class UnifiedRow {
  final String id;
  final String name;
  final String dateString;
  final DateTime dateValue;

  final double orderSum;    // "Сумма заказа"
  final double paymentSum;  // "Сумма оплаты"

  double startSaldo;
  double endSaldo;

  UnifiedRow({
    required this.id,
    required this.name,
    required this.dateString,
    required this.dateValue,
    required this.orderSum,
    required this.paymentSum,
    this.startSaldo = 0.0,
    this.endSaldo = 0.0,
  });
}
