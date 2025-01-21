import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:alan/constant.dart';
import 'package:alan/bloc/blocs/cashbox_page_blocs/blocs/financial_order_bloc.dart';
import 'package:alan/bloc/blocs/cashbox_page_blocs/states/financial_order_state.dart';
import 'package:alan/bloc/blocs/cashbox_page_blocs/events/financial_order_event.dart';
import 'package:excel/excel.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class CashboxReportPage extends StatefulWidget {
  @override
  _CashboxReportPageState createState() => _CashboxReportPageState();
}

class _CashboxReportPageState extends State<CashboxReportPage> {
  @override
  void initState() {
    super.initState();
    context.read<FinancialOrderBloc>().add(FetchFinancialOrdersEvent());
    _requestStoragePermission();
  }

  Future<void> _requestStoragePermission() async {
    if (!await Permission.storage.request().isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Необходимо разрешение для сохранения файлов.', style: bodyTextStyle),
          backgroundColor: errorColor,
        ),
      );
    }
  }

  Future<void> _exportToExcel(
    List<Map<String, dynamic>> incomeOrders,
    List<Map<String, dynamic>> expenseOrders,
    double totalIncome,
    double totalExpense,
    double saldo,
  ) async {
    try {
      var excel = Excel.createExcel();
      var sheet = excel['Отчет по кассе'];

      sheet.appendRow(['Тип', 'Сумма']);
      incomeOrders.forEach((order) {
        sheet.appendRow(['Приход', order['summary_cash'].toString()]);
      });
      expenseOrders.forEach((order) {
        sheet.appendRow(['Расход', order['summary_cash'].toString()]);
      });

      sheet.appendRow([]);
      sheet.appendRow(['Итого приход', totalIncome.toStringAsFixed(2)]);
      sheet.appendRow(['Итого расход', totalExpense.toStringAsFixed(2)]);
      sheet.appendRow(['Сальдо', saldo.toStringAsFixed(2)]);

      final directory = Directory('/storage/emulated/0/Download');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
      final path = '${directory.path}/cash_report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      File(path).writeAsBytesSync(excel.encode()!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Excel файл сохранен в загрузках.', style: bodyTextStyle),
          backgroundColor: primaryColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при экспорте Excel: $e', style: bodyTextStyle),
          backgroundColor: errorColor,
        ),
      );
    }
  }

  Future<void> _exportToPdf(
    List<Map<String, dynamic>> incomeOrders,
    List<Map<String, dynamic>> expenseOrders,
    double totalIncome,
    double totalExpense,
    double saldo,
  ) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Отчет по кассе', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.Text('Приходы:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ...incomeOrders.map((order) => pw.Text(order['summary_cash'].toString())),
              pw.SizedBox(height: 16),
              pw.Text('Расходы:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ...expenseOrders.map((order) => pw.Text(order['summary_cash'].toString())),
              pw.Divider(),
              pw.Text('Итого приход: $totalIncome'),
              pw.Text('Итого расход: $totalExpense'),
              pw.Text('Сальдо: $saldo'),
            ],
          ),
        ),
      );

      final directory = Directory('/storage/emulated/0/Download');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
      final path = '${directory.path}/cash_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(path);
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF файл сохранен в загрузках.', style: bodyTextStyle),
          backgroundColor: primaryColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при экспорте PDF: $e', style: bodyTextStyle),
          backgroundColor: errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: pagePadding,
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
              final incomeOrders = state.financialOrders.where((order) => order['type'] == 'income').toList();
              final expenseOrders = state.financialOrders.where((order) => order['type'] == 'expense').toList();
              final totalIncome = incomeOrders.fold<double>(0, (sum, order) => sum + (order['summary_cash'] ?? 0));
              final totalExpense = expenseOrders.fold<double>(0, (sum, order) => sum + (order['summary_cash'] ?? 0));
              final saldo = totalIncome - totalExpense;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Отчет по кассе', style: titleStyle),
                  const SizedBox(height: 10),
                  Table(
                    border: TableBorder.all(color: borderColor),
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: primaryColor),
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
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(totalIncome.toStringAsFixed(2), style: bodyTextStyle),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(totalExpense.toStringAsFixed(2), style: bodyTextStyle),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(saldo.toStringAsFixed(2), style: bodyTextStyle),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('-', style: bodyTextStyle),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.filePdf, color: Colors.red),
                        onPressed: () => _exportToPdf(incomeOrders, expenseOrders, totalIncome, totalExpense, saldo),
                      ),
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.fileExcel, color: Colors.green),
                        onPressed: () => _exportToExcel(incomeOrders, expenseOrders, totalIncome, totalExpense, saldo),
                      ),
                    ],
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
