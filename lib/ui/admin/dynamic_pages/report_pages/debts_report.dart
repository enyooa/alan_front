import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// Import your constants and bloc classes.
import 'package:alan/constant.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/blocs/unified_debts_bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/events/unified_debts_event.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/unified_debts_state.dart';
import 'package:alan/bloc/models/debts_row.dart';

class DebtsReportPage extends StatelessWidget {
  const DebtsReportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provide the UnifiedDebtsBloc to the view.
    return BlocProvider(
      create: (_) => UnifiedDebtsBloc(),
      child: const UnifiedDebtsView(),
    );
  }
}

class UnifiedDebtsView extends StatefulWidget {
  const UnifiedDebtsView({Key? key}) : super(key: key);

  @override
  _UnifiedDebtsViewState createState() => _UnifiedDebtsViewState();
}

class _UnifiedDebtsViewState extends State<UnifiedDebtsView> {
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<UnifiedDebtsBloc>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Отчет по долгам', style: headingStyle),
      ),
      backgroundColor: backgroundColor,
      body: BlocBuilder<UnifiedDebtsBloc, UnifiedDebtsState>(
        builder: (context, state) {
          Widget content;
          if (state is UnifiedDebtsLoading) {
            content = const Center(child: CircularProgressIndicator());
          } else if (state is UnifiedDebtsError) {
            content = Center(
              child: Text('Ошибка: ${state.message}', style: bodyTextStyle.copyWith(color: errorColor)),
            );
          } else if (state is UnifiedDebtsLoaded) {
            content = _buildDebtsList(state.rows);
          } else {
            content = const Center(
              child: Text('Нажмите «Сформировать», чтобы загрузить данные.', style: bodyTextStyle),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilters(bloc),
                  const SizedBox(height: 20),
                  if (state is UnifiedDebtsLoaded) _buildExportButtons(state.rows),
                  const SizedBox(height: 20),
                  content,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilters(UnifiedDebtsBloc bloc) {
    return Row(
      children: [
        // "Дата с" filter
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: fromDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() => fromDate = picked);
              }
            },
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate!) : 'Дата с',
                      style: bodyTextStyle.copyWith(fontSize: 12),
                    ),
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // "Дата по" filter
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: toDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() => toDate = picked);
              }
            },
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      toDate != null ? DateFormat('yyyy-MM-dd').format(toDate!) : 'Дата по',
                      style: bodyTextStyle.copyWith(fontSize: 12),
                    ),
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // "Сформировать" button
        ElevatedButton(
          style: elevatedButtonStyle,
          onPressed: () {
            final fromStr = fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate!) : '';
            final toStr = toDate != null ? DateFormat('yyyy-MM-dd').format(toDate!) : '';
            bloc.add(FetchUnifiedDebtsEvent(dateFrom: fromStr, dateTo: toStr));
          },
          child: const Text('Сформировать', style: buttonTextStyle),
        ),
      ],
    );
  }

  Widget _buildExportButtons(List<DebtsRow> rows) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
          onPressed: () async {
            await _exportDebtsToPdf(rows);
          },
        ),
        IconButton(
          icon: const Icon(Icons.table_chart, color: Colors.green),
          onPressed: () async {
            await _exportDebtsToExcel(rows);
          },
        ),
      ],
    );
  }

  Future<void> _exportDebtsToExcel(List<DebtsRow> rows) async {
    try {
      var excel = Excel.createExcel();
      var sheet = excel['Отчет по долгам'];

      // Add header row
      sheet.appendRow(['Наименование', 'Приход', 'Расход', 'Баланс']);

      // Add each row from the debts report
      for (var row in rows) {
        sheet.appendRow([
          row.name ?? '',
          row.incoming?.toStringAsFixed(2) ?? '0.00',
          row.outgoing?.toStringAsFixed(2) ?? '0.00',
          row.balance?.toStringAsFixed(2) ?? '0.00',
        ]);
      }

      // Write file to the Downloads folder
      final directory = Directory('/storage/emulated/0/Download');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
      final filePath = '${directory.path}/debts_report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      File(filePath).writeAsBytesSync(excel.encode()!);

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

  Future<void> _exportDebtsToPdf(List<DebtsRow> rows) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Отчет по долгам', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 16),
                pw.Row(
                  children: [
                    pw.Expanded(child: pw.Text('Наименование', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(child: pw.Text('Приход', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(child: pw.Text('Расход', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(child: pw.Text('Баланс', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                pw.Divider(),
                ...rows.map((row) {
                  return pw.Row(
                    children: [
                      pw.Expanded(child: pw.Text(row.name ?? '')),
                      pw.Expanded(child: pw.Text(row.incoming?.toStringAsFixed(2) ?? '0.00', textAlign: pw.TextAlign.right)),
                      pw.Expanded(child: pw.Text(row.outgoing?.toStringAsFixed(2) ?? '0.00', textAlign: pw.TextAlign.right)),
                      pw.Expanded(child: pw.Text(row.balance?.toStringAsFixed(2) ?? '0.00', textAlign: pw.TextAlign.right)),
                    ],
                  );
                }).toList(),
              ],
            );
          },
        ),
      );

      final directory = Directory('/storage/emulated/0/Download');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
      final path = '${directory.path}/debts_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
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

  Widget _buildDebtsList(List<DebtsRow> rows) {
    if (rows.isEmpty) {
      return const Text('Данные отсутствуют', style: bodyTextStyle);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            color: primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              children: const [
                Expanded(child: Text('Наименование', style: tableHeaderStyle)),
                Expanded(child: Text('Приход', style: tableHeaderStyle)),
                Expanded(child: Text('Расход', style: tableHeaderStyle)),
                Expanded(child: Text('Баланс', style: tableHeaderStyle)),
              ],
            ),
          ),
          // Data rows
          ...rows.map((row) => _buildRow(row)).toList(),
        ],
      ),
    );
  }

  Widget _buildRow(DebtsRow row) {
    final textStyleRight = bodyTextStyle.copyWith(fontSize: 12);

    String fmt(double? val) {
      if (val == null) return '0.00';
      return val.toStringAsFixed(2);
    }

    if (row.rowType == 'group') {
      return Container(
        color: Colors.grey.shade200,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          children: [
            Expanded(child: Text(row.label ?? '', style: bodyTextStyle.copyWith(fontWeight: FontWeight.bold))),
            const Expanded(child: Text('–')),
            const Expanded(child: Text('–')),
            const Expanded(child: Text('–')),
          ],
        ),
      );
    } else if (row.rowType == 'provider') {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        
        child: Row(
          children: [
            Expanded(child: Text(row.name ?? '', style: bodyTextStyle.copyWith(fontWeight: FontWeight.bold))),
            Expanded(child: Text(fmt(row.incoming), textAlign: TextAlign.right, style: textStyleRight)),
            Expanded(child: Text(fmt(row.outgoing), textAlign: TextAlign.right, style: textStyleRight)),
            Expanded(child: Text(fmt(row.balance), textAlign: TextAlign.right, style: textStyleRight.copyWith(color: (row.balance ?? 0) < 0 ? errorColor : null))),
          ],
        ),
      );
    } else if (row.rowType == 'doc') {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(row.name ?? '', style: bodyTextStyle),
              ),
            ),
            Expanded(child: Text(fmt(row.incoming), textAlign: TextAlign.right, style: textStyleRight)),
            Expanded(child: Text(fmt(row.outgoing), textAlign: TextAlign.right, style: textStyleRight)),
            Expanded(child: Text(fmt(row.balance), textAlign: TextAlign.right, style: textStyleRight.copyWith(color: (row.balance ?? 0) < 0 ? errorColor : null))),
          ],
        ),
      );
    } else if (row.rowType == 'client') {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        
        child: Row(
          children: [
            Expanded(child: Text(row.name ?? '', style: bodyTextStyle.copyWith(fontWeight: FontWeight.bold, color: Colors.black87))),
            Expanded(child: Text(fmt(row.incoming), textAlign: TextAlign.right, style: textStyleRight)),
            Expanded(child: Text(fmt(row.outgoing), textAlign: TextAlign.right, style: textStyleRight)),
            Expanded(child: Text(fmt(row.balance), textAlign: TextAlign.right, style: textStyleRight.copyWith(color: (row.balance ?? 0) < 0 ? errorColor : null))),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        
        child: Row(
          children: [
            Expanded(child: Text(row.name ?? '', style: bodyTextStyle)),
            Expanded(child: Text(fmt(row.incoming), textAlign: TextAlign.right, style: textStyleRight)),
            Expanded(child: Text(fmt(row.outgoing), textAlign: TextAlign.right, style: textStyleRight)),
            Expanded(child: Text(fmt(row.balance), textAlign: TextAlign.right, style: textStyleRight)),
          ],
        ),
      );
    }
  }
}
