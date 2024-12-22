import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/blocs/financial_order_bloc.dart';
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/events/financial_order_event.dart';
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/states/financial_order_state.dart';
import 'package:cash_control/constant.dart';
import 'package:excel/excel.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class CalculationScreen extends StatefulWidget {
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

  Future<void> requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
    } else {
    }
  }

  Future<void> exportToExcel(List<Map<String, dynamic>> orders) async {
  try {
    var excel = Excel.createExcel();
    var sheet = excel['Финансовые отчеты'];

    // Add headers
    sheet.appendRow(['Контрагент', 'Тип', 'Сумма']);

    // Add data
    for (var order in orders) {
      final user = order['user'];
      final userName = "${user['first_name']} ${user['last_name']}";
      final type = order['type'] == 'income' ? 'Приход' : 'Расход';
      final summaryCash = order['summary_cash'].toString();
      sheet.appendRow([userName, type, summaryCash]);
    }

    // Generate a unique file name with timestamp
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Excel файл перемещен в загрузки ($fileName)")),
    );
  } catch (e) {
    print("Error exporting Excel: $e");
  }
}


  Future<void> exportToPdf(List<Map<String, dynamic>> orders) async {
  try {
    final pdf = pw.Document();

    // Use a font that supports Cyrillic characters
    final ttf = await rootBundle.load("assets/fonts/Raleway-Regular.ttf");
    final font = pw.Font.ttf(ttf);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Финансовые отчеты',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, font: font)),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Контрагент', 'Тип', 'Сумма'],
                data: orders.map((order) {
                  final user = order['user'];
                  final userName = "${user['first_name']} ${user['last_name']}";
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

    // Generate a unique file name with timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'финансовые_отчеты_$timestamp.pdf';

    final directory = Directory('/storage/emulated/0/Download');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    final path = '${directory.path}/$fileName';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("PDF файл перемещен в загрузки ($fileName)")),
    );
  } catch (e) {
    print("Error exporting PDF: $e");
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
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Дата с по',
                    style: bodyTextStyle.copyWith(color: primaryColor),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: elevatedButtonStyle,
                    child: Text('Показать', style: buttonTextStyle),
                  ),
                ),
              ],
            ),
            const Divider(color: borderColor),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              color: Colors.grey[300],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Контрагент', style: subheadingStyle.copyWith(fontWeight: FontWeight.bold)),
                  Text('Тип', style: subheadingStyle.copyWith(fontWeight: FontWeight.bold)),
                  Text('Сумма', style: subheadingStyle.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
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
                    return ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final user = order['user'];
                        final userName = "${user['first_name']} ${user['last_name']}";
                        final type = order['type'] == 'income' ? 'Приход' : 'Расход';
                        final summaryCash = order['summary_cash'].toString();

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(userName, style: bodyTextStyle),
                                  ),
                                  Text(type, style: bodyTextStyle),
                                  SizedBox(width: MediaQuery.sizeOf(context).width*0.2,),
                                  Text(summaryCash, style: bodyTextStyle.copyWith(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const Divider(color: borderColor),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
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
}
