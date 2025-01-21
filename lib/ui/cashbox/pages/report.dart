import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alan/constant.dart';
import 'package:alan/bloc/blocs/cashbox_page_blocs/blocs/financial_order_bloc.dart';
import 'package:alan/bloc/blocs/cashbox_page_blocs/states/financial_order_state.dart';
import 'package:alan/bloc/blocs/cashbox_page_blocs/events/financial_order_event.dart';
import 'package:excel/excel.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class CashReportScreen extends StatefulWidget {
  @override
  _CashReportScreenState createState() => _CashReportScreenState();
}

class _CashReportScreenState extends State<CashReportScreen> {
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    context.read<FinancialOrderBloc>().add(FetchFinancialOrdersEvent());
    requestStoragePermission();
  }

  Future<void> requestStoragePermission() async {
    if (!await Permission.storage.request().isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Необходимо разрешение для сохранения файлов.',
            style: bodyTextStyle,
          ),
          backgroundColor: errorColor,
        ),
      );
    }
  }

  Future<void> pickDateRange(BuildContext context) async {
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
    );

    if (pickedRange != null) {
      setState(() {
        startDate = pickedRange.start;
        endDate = pickedRange.end;
      });
    }
  }

  List<Map<String, dynamic>> filterOrdersByDate(
      List<Map<String, dynamic>> orders) {
    if (startDate == null || endDate == null) return orders;

    return orders.where((order) {
      final orderDate = DateTime.parse(order['date_of_check']);
      return orderDate.isAfter(startDate!.subtract(const Duration(days: 1))) &&
          orderDate.isBefore(endDate!.add(const Duration(days: 1)));
    }).toList();
  }

  Future<void> exportToExcel(
    BuildContext context,
    List<Map<String, dynamic>> incomeOrders,
    List<Map<String, dynamic>> expenseOrders,
    double totalIncome,
    double totalExpense,
    double saldo,
  ) async {
    try {
      var excel = Excel.createExcel();
      var sheet = excel['Отчет по кассе'];

      // Add headers
      sheet.appendRow(['Тип', 'Сумма']);

      // Add income data
      for (var order in incomeOrders) {
        sheet.appendRow(['Приход', order['summary_cash'].toString()]);
      }

      // Add expense data
      for (var order in expenseOrders) {
        sheet.appendRow(['Расход', order['summary_cash'].toString()]);
      }

      // Add totals
      sheet.appendRow([]);
      sheet.appendRow(['Итого приход', totalIncome.toStringAsFixed(2)]);
      sheet.appendRow(['Итого расход', totalExpense.toStringAsFixed(2)]);
      sheet.appendRow(['Сальдо', saldo.toStringAsFixed(2)]);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'отчет_по_кассе_$timestamp.xlsx';

      final directory = Directory('/storage/emulated/0/Download');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
      final path = '${directory.path}/$fileName';
      File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Excel файл "$fileName" перемещен в загрузки.',
            style: bodyTextStyle,
          ),
          backgroundColor: primaryColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ошибка при экспорте Excel: $e',
            style: bodyTextStyle,
          ),
          backgroundColor: errorColor,
        ),
      );
    }
  }

  Future<void> exportToPdf(
    BuildContext context,
    List<Map<String, dynamic>> incomeOrders,
    List<Map<String, dynamic>> expenseOrders,
    double totalIncome,
    double totalExpense,
    double saldo,
  ) async {
    try {
      final pdf = pw.Document();

      final ttf = await rootBundle.load("assets/fonts/Raleway-Regular.ttf");
      final font = pw.Font.ttf(ttf);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Отчет по кассе',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, font: font)),
                pw.SizedBox(height: 10),
                pw.Text('Приходы', style: pw.TextStyle(font: font, fontSize: 16)),
                pw.Table.fromTextArray(
                  data: incomeOrders.map((order) {
                    return ['Приход', order['summary_cash'].toString()];
                  }).toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: font),
                  cellStyle: pw.TextStyle(font: font),
                ),
                pw.SizedBox(height: 10),
                pw.Text('Расходы', style: pw.TextStyle(font: font, fontSize: 16)),
                pw.Table.fromTextArray(
                  data: expenseOrders.map((order) {
                    return ['Расход', order['summary_cash'].toString()];
                  }).toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: font),
                  cellStyle: pw.TextStyle(font: font),
                ),
                pw.Divider(),
                pw.Text('Итого приход: ${totalIncome.toStringAsFixed(2)}', style: pw.TextStyle(font: font)),
                pw.Text('Итого расход: ${totalExpense.toStringAsFixed(2)}', style: pw.TextStyle(font: font)),
                pw.Text('Сальдо: ${saldo.toStringAsFixed(2)}', style: pw.TextStyle(font: font)),
              ],
            );
          },
        ),
      );

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'отчет_по_кассе_$timestamp.pdf';

      final directory = Directory('/storage/emulated/0/Download');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
      final path = '${directory.path}/$fileName';
      final file = File(path);
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'PDF файл "$fileName" перемещен в загрузки.',
            style: bodyTextStyle,
          ),
          backgroundColor: primaryColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ошибка при экспорте PDF: $e',
            style: bodyTextStyle,
          ),
          backgroundColor: errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: pagePadding,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => pickDateRange(context),
                    child: Text(
                      startDate != null && endDate != null
                          ? '${startDate!.toLocal()} - ${endDate!.toLocal()}'
                          : 'Дата с по',
                      style: bodyTextStyle.copyWith(color: primaryColor),
                    ),
                  ),
                ),
                // Expanded(
                //   child: ElevatedButton(
                //     onPressed: () {
                //       context.read<FinancialOrderBloc>().add(FetchFinancialOrdersEvent());
                //     },
                //     style: elevatedButtonStyle,
                //     child: Text(
                //       'показать',
                //       style: buttonTextStyle,
                //     ),
                //   ),
                // ),
              ],
            ),
            const Divider(color: borderColor),
            BlocBuilder<FinancialOrderBloc, FinancialOrderState>(
              builder: (context, state) {
                if (state is FinancialOrderLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is FinancialOrderError) {
                  return Center(
                    child: Text(
                      'Ошибка: ${state.message}',
                      style: bodyTextStyle,
                    ),
                  );
                }
                if (state is FinancialOrderLoaded) {
                  final incomeOrders = filterOrdersByDate(state.financialOrders
                      .where((order) => order['type'] == 'income')
                      .toList());
                  final expenseOrders = filterOrdersByDate(state.financialOrders
                      .where((order) => order['type'] == 'expense')
                      .toList());
                  final totalIncome = incomeOrders.fold<double>(
                    0,
                    (sum, order) => sum + (order['summary_cash'] ?? 0),
                  );
                  final totalExpense = expenseOrders.fold<double>(
                    0,
                    (sum, order) => sum + (order['summary_cash'] ?? 0),
                  );
                  final saldo = totalIncome - totalExpense;

                  return Column(
                    children: [
                      DataTable(
                        sortColumnIndex: 1,
                        showCheckboxColumn: false,
                        border: TableBorder.all(color: borderColor, width: 1.0),
                        columns: const <DataColumn>[
                          DataColumn(
                            label: Text(
                              'остаток дня',
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
                        rows: [
                          DataRow(cells: [
                            DataCell(
                              Text(
                                'Приход',
                                style: bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataCell(
                              Text(
                                '${totalIncome.toStringAsFixed(2)}',
                                style: bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataCell(Text('')),
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
                                '${totalExpense.toStringAsFixed(2)}',
                                style: bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataCell(Text('')),
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
                                '${saldo.toStringAsFixed(2)}',
                                style: bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataCell(Text('')),
                          ]),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.table_chart, color: primaryColor),
                            onPressed: () async {
                              await exportToExcel(
                                context,
                                incomeOrders,
                                expenseOrders,
                                totalIncome,
                                totalExpense,
                                saldo,
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.picture_as_pdf, color: primaryColor),
                            onPressed: () async {
                              await exportToPdf(
                                context,
                                incomeOrders,
                                expenseOrders,
                                totalIncome,
                                totalExpense,
                                saldo,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
