import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:excel/excel.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter/services.dart';

// BLoCs & States
import 'package:alan/bloc/blocs/cashbox_page_blocs/blocs/financial_order_bloc.dart';
import 'package:alan/bloc/blocs/cashbox_page_blocs/events/financial_order_event.dart';
import 'package:alan/bloc/blocs/cashbox_page_blocs/states/financial_order_state.dart';

import 'package:alan/constant.dart';

class CalculationScreen extends StatefulWidget {
  const CalculationScreen({Key? key}) : super(key: key);

  @override
  _CalculationScreenState createState() => _CalculationScreenState();
}

class _CalculationScreenState extends State<CalculationScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FinancialOrderBloc>().add(FetchFinancialOrdersEvent());
    requestStoragePermission();
  }

  // Ask for storage permission on Android
  Future<void> requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      // The user granted permission
    } else {
      // The user denied permission. Handle gracefully if needed.
    }
  }

  // ---------------------------------------------------------------------------
  // EXCEL EXPORT
  // ---------------------------------------------------------------------------
  Future<void> exportToExcel(List<Map<String, dynamic>> orders) async {
    try {
      var excel = Excel.createExcel();
      var sheet = excel['Финансовые отчеты'];

      // 1) Add headers
      sheet.appendRow(['Контрагент', 'Тип', 'Сумма']);

      // 2) Add rows
      for (var order in orders) {
        // If user is null => fallback
        final userMap = order['user'] ?? {};
        final firstName = userMap['first_name'] ?? 'NoName';
        final lastName  = userMap['last_name'] ?? '';
        final userName = "$firstName $lastName".trim();

        final type = order['type'] == 'income' ? 'Приход' : 'Расход';
        final summaryCash = order['summary_cash'].toString();

        sheet.appendRow([userName, type, summaryCash]);
      }

      // 3) Save to device "Download" folder
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'финансовые_отчеты_$timestamp.xlsx';

      final directory = Directory('/storage/emulated/0/Download');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
      final path = '${directory.path}/$fileName';
      File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Excel файл перемещен в загрузки ($fileName)")),
      );
    } catch (e) {
      print("Error exporting Excel: $e");
    }
  }

  // ---------------------------------------------------------------------------
  // PDF EXPORT
  // ---------------------------------------------------------------------------
  Future<void> exportToPdf(List<Map<String, dynamic>> orders) async {
    try {
      final pdf = pw.Document();

      // Use a font that supports Cyrillic
      final ttf = await rootBundle.load("assets/fonts/Raleway-Regular.ttf");
      final font = pw.Font.ttf(ttf);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Финансовые отчеты',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    font: font,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                  headers: ['Контрагент', 'Тип', 'Сумма'],
                  data: orders.map((order) {
                    final userMap = order['user'] ?? {};
                    final firstName = userMap['first_name'] ?? 'NoName';
                    final lastName  = userMap['last_name'] ?? '';
                    final userName = "$firstName $lastName".trim();

                    final type = order['type'] == 'income' ? 'Приход' : 'Расход';
                    final summaryCash = order['summary_cash'].toString();
                    return [userName, type, summaryCash];
                  }).toList(),
                  cellStyle: pw.TextStyle(font: font),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: font),
                ),
              ],
            );
          },
        ),
      );

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'финансовые_отчеты_$timestamp.pdf';

      final directory = Directory('/storage/emulated/0/Download');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
      final path = '${directory.path}/$fileName';
      final file = File(path);
      await file.writeAsBytes(await pdf.save());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF файл перемещен в загрузки ($fileName)")),
      );
    } catch (e) {
      print("Error exporting PDF: $e");
    }
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: pagePadding,
        child: Column(
          children: [
            // ROW: filter placeholder + "Показать" button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Пока нет фильтра')),
                    );
                  },
                  child: Text('Дата с по', style: bodyTextStyle.copyWith(color: primaryColor)),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // no real filter
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Показать placeholder')),
                      );
                    },
                    style: elevatedButtonStyle,
                    child: const Text('Показать', style: buttonTextStyle),
                  ),
                ),
              ],
            ),
            const Divider(color: borderColor),

            // TABLE
            Expanded(
              child: BlocBuilder<FinancialOrderBloc, FinancialOrderState>(
                builder: (context, state) {
                  if (state is FinancialOrderLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is FinancialOrderError) {
                    return Center(
                      child: Text('Ошибка: ${state.message}', style: bodyTextStyle),
                    );
                  }
                  if (state is FinancialOrderLoaded) {
                    final orders = state.financialOrders;
                    if (orders.isEmpty) {
                      return Center(
                        child: Text('Нет данных для отображения', style: bodyTextStyle),
                      );
                    }

                    // Use a DataTable with a DataTableTheme for modern style
                    return _buildFinanceDataTable(orders);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            // ROW: Excel/PDF icon buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.table_chart, color: primaryColor),
                  onPressed: () async {
                    final state = context.read<FinancialOrderBloc>().state;
                    if (state is FinancialOrderLoaded) {
                      await exportToExcel(state.financialOrders);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf, color: primaryColor),
                  onPressed: () async {
                    final state = context.read<FinancialOrderBloc>().state;
                    if (state is FinancialOrderLoaded) {
                      await exportToPdf(state.financialOrders);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build DataTable with modern styling
  // ---------------------------------------------------------------------------
  Widget _buildFinanceDataTable(List<Map<String, dynamic>> orders) {
    return DataTableTheme(
      data: DataTableThemeData(
        headingRowColor: MaterialStateProperty.all(primaryColor),
        headingTextStyle: tableHeaderStyle.copyWith(color: Colors.white),
        dataTextStyle: bodyTextStyle,
        dataRowColor: MaterialStateProperty.all(Colors.white),
        dividerThickness: 1.0,
        decoration: BoxDecoration(
          
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Контрагент')),
          DataColumn(label: Text('Тип')),
          DataColumn(label: Text('Сумма')),
        ],
        rows: orders.map<DataRow>((order) {
          // Check if user is null
          final userMap = order['user'];
          String userName = 'Нет пользователя';
          if (userMap != null) {
            final fName = userMap['first_name'] ?? 'NoF';
            final lName = userMap['last_name'] ?? 'NoL';
            userName = "$fName $lName".trim();
          }

          // If type=income => 'Приход', else 'Расход'
          final typeStr = (order['type'] == 'income') ? 'Приход' : 'Расход';

          // sum
          final sumStr = order['summary_cash']?.toString() ?? '0';

          return DataRow(
            cells: [
              DataCell(Text(userName)),
              DataCell(Text(typeStr)),
              DataCell(Text(sumStr)),
            ],
          );
        }).toList(),
      ),
    );
  }
}
