import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:alan/constant.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/blocs/storage_report_bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/events/storage_report_event.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/storage_report_state.dart';
import 'package:alan/ui/admin/widgets/storage_report_item.dart';

class StorageReportPage extends StatelessWidget {
  const StorageReportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provide the StorageReportBloc to the view.
    return BlocProvider(
      create: (_) => StorageReportBloc(),
      child: const StorageReportView(),
    );
  }
}

class StorageReportView extends StatefulWidget {
  const StorageReportView({Key? key}) : super(key: key);

  @override
  _StorageReportViewState createState() => _StorageReportViewState();
}

class _StorageReportViewState extends State<StorageReportView> {
  DateTime? selectedDateFrom;
  DateTime? selectedDateTo;

  @override
  void initState() {
    super.initState();
    _requestStoragePermission();
  }

  /// Request storage permission on Android.
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

  /// Export report data to Excel.
  Future<void> _exportToExcel(List<StorageReportItem> reportData) async {
    try {
      var excel = Excel.createExcel();
      var sheet = excel['Отчет по складу'];

      // Add header row.
      sheet.appendRow(['Склад', 'Товар', 'Приход', 'Расход', 'Остаток', 'Себестоимость']);

      // Add each row.
      for (var item in reportData) {
        sheet.appendRow([
          item.warehouseName,
          item.productName,
          item.totalInbound?.toStringAsFixed(2) ?? '0.00',
          item.totalOutbound?.toStringAsFixed(2) ?? '0.00',
          item.remainder?.toStringAsFixed(2) ?? '0.00',
          item.currentCostPrice?.toStringAsFixed(2) ?? '0.00',
        ]);
      }

      // Save file in Downloads folder.
      final directory = Directory('/storage/emulated/0/Download');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
      final filePath = '${directory.path}/storage_report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
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

  /// Export report data to PDF.
  Future<void> _exportToPdf(List<StorageReportItem> reportData) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Отчет по складу', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 16),
                // Header row.
                pw.Row(
                  children: [
                    pw.Expanded(child: pw.Text('Склад', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(child: pw.Text('Товар', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(child: pw.Text('Приход', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(child: pw.Text('Расход', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(child: pw.Text('Остаток', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(child: pw.Text('Себестоимость', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                pw.Divider(),
                // Data rows.
                ...reportData.map((item) {
                  return pw.Row(
                    children: [
                      pw.Expanded(child: pw.Text(item.warehouseName)),
                      pw.Expanded(child: pw.Text(item.productName)),
                      pw.Expanded(child: pw.Text(item.totalInbound?.toStringAsFixed(2) ?? '0.00', textAlign: pw.TextAlign.right)),
                      pw.Expanded(child: pw.Text(item.totalOutbound?.toStringAsFixed(2) ?? '0.00', textAlign: pw.TextAlign.right)),
                      pw.Expanded(child: pw.Text(item.remainder?.toStringAsFixed(2) ?? '0.00', textAlign: pw.TextAlign.right)),
                      pw.Expanded(child: pw.Text(item.currentCostPrice?.toStringAsFixed(2) ?? '0.00', textAlign: pw.TextAlign.right)),
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
      final path = '${directory.path}/storage_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
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
    final bloc = context.read<StorageReportBloc>();

    return BlocBuilder<StorageReportBloc, StorageReportState>(
      builder: (context, state) {
        Widget content;
        if (state is StorageReportLoading) {
          content = const Center(child: CircularProgressIndicator());
        } else if (state is StorageReportError) {
          content = Center(
            child: Text(
              'Ошибка: ${state.message}',
              style: bodyTextStyle.copyWith(color: errorColor),
            ),
          );
        } else if (state is StorageReportLoaded) {
          content = _buildDataTable(state.storageData);
        } else {
          content = const Center(
            child: Text('Нажмите "Сформировать", чтобы загрузить данные.', style: bodyTextStyle),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: primaryColor,
            title: const Text('Отчёт по складу', style: headingStyle),
          ),
          backgroundColor: backgroundColor,
          body: SingleChildScrollView(
            padding: pagePadding,
            child: Column(
              children: [
                _buildFilters(bloc),
                const SizedBox(height: 20),
                if (state is StorageReportLoaded) _buildExportButtons(state.storageData),
                const SizedBox(height: 20),
                content,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilters(StorageReportBloc bloc) {
    return Row(
      children: [
        // "Дата от" filter.
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDateFrom ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() {
                  selectedDateFrom = picked;
                });
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
                      selectedDateFrom != null
                          ? DateFormat('yyyy-MM-dd').format(selectedDateFrom!)
                          : 'Дата от',
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
        // "Дата по" filter.
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDateTo ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() {
                  selectedDateTo = picked;
                });
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
                      selectedDateTo != null
                          ? DateFormat('yyyy-MM-dd').format(selectedDateTo!)
                          : 'Дата по',
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
        // "Сформировать" button.
        ElevatedButton(
          style: elevatedButtonStyle,
          onPressed: () {
            final fromStr = selectedDateFrom != null ? DateFormat('yyyy-MM-dd').format(selectedDateFrom!) : '';
            final toStr = selectedDateTo != null ? DateFormat('yyyy-MM-dd').format(selectedDateTo!) : '';
            bloc.add(FetchStorageReportEvent(dateFrom: fromStr, dateTo: toStr));
          },
          child: const Text('Сформировать', style: buttonTextStyle),
        ),
      ],
    );
  }

  Widget _buildExportButtons(List<StorageReportItem> storageData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
          onPressed: () async {
            await _exportToPdf(storageData);
          },
        ),
        IconButton(
          icon: const Icon(Icons.table_chart, color: Colors.green),
          onPressed: () async {
            await _exportToExcel(storageData);
          },
        ),
      ],
    );
  }

  Widget _buildDataTable(List<StorageReportItem> reportData) {
    if (reportData.isEmpty) {
      return const Text('Нет данных', style: bodyTextStyle);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24,
        headingRowColor: MaterialStateProperty.all(primaryColor),
        columns: [
          DataColumn(label: Text('Склад', style: tableHeaderStyle)),
          DataColumn(label: Text('Товар', style: tableHeaderStyle)),
          DataColumn(label: Text('Приход', style: tableHeaderStyle)),
          DataColumn(label: Text('Расход', style: tableHeaderStyle)),
          DataColumn(label: Text('Остаток', style: tableHeaderStyle)),
          DataColumn(label: Text('Себестоимость', style: tableHeaderStyle)),
        ],
        rows: reportData.map((item) {
          return DataRow(
            cells: [
              DataCell(Text(item.warehouseName, style: bodyTextStyle)),
              DataCell(Text(item.productName, style: bodyTextStyle)),
              DataCell(Text(item.totalInbound.toStringAsFixed(2), style: bodyTextStyle)),
              DataCell(Text(item.totalOutbound.toStringAsFixed(2), style: bodyTextStyle)),
              DataCell(Text(item.remainder.toStringAsFixed(2), style: bodyTextStyle)),
              DataCell(Text(item.currentCostPrice.toStringAsFixed(2), style: bodyTextStyle)),
            ],
          );
        }).toList(),
      ),
    );
  }
}
