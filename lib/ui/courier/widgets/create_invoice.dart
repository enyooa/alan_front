import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:alan/bloc/blocs/courier_page_blocs/blocs/courier_document_bloc.dart';
import 'package:alan/bloc/blocs/courier_page_blocs/events/courier_document_event.dart';
import 'package:alan/bloc/blocs/courier_page_blocs/states/courier_document_state.dart';
import 'package:alan/constant.dart';

class InvoicePage extends StatefulWidget {
  final Map<String, dynamic> orderDetails;

  const InvoicePage({Key? key, required this.orderDetails}) : super(key: key);

  @override
  _InvoicePageState createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  // Map holding updated quantities per order_item_id
  late Map<int, double> updatedQuantities;
  late int? statusId; // Read from orderDetails

  @override
  void initState() {
    super.initState();

    final products = widget.orderDetails['order_products'] ?? [];
    // Initialize quantities from either courier_quantity or packer_quantity or 0
    updatedQuantities = {
      for (var product in products)
        if (product['id'] != null)
          product['id']: (product['courier_quantity'] ?? product['packer_quantity'] ?? 0).toDouble(),
    };

    statusId = widget.orderDetails['status_id'] as int?;

    // Request storage permission for export features
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

  // Called when user taps "Отправить"
  void _submitCourierData() {
    final products = widget.orderDetails['order_products'] ?? [];
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет продуктов для обработки.')),
      );
      return;
    }

    // Build the list of product data to submit
    final List<Map<String, dynamic>> requestProducts = products.map<Map<String, dynamic>>((p) {
      final orderItemId = p['id'];
      final newQty = updatedQuantities[orderItemId] ?? 0.0;
      return {
        'order_item_id': orderItemId,
        'courier_quantity': newQty.toInt(),
      };
    }).toList();

    final orderId = widget.orderDetails['id'];

    // Dispatch the submission event
    context.read<CourierDocumentBloc>().add(
      SubmitCourierDocumentEvent(
        orderId: orderId,
        orderProducts: requestProducts,
      ),
    );
  }

  /// Export the invoice table to Excel.
  Future<void> _exportToExcelInvoice() async {
    try {
      var excel = Excel.createExcel();
      var sheet = excel['Накладная'];

      // Header row
      sheet.appendRow(['Наименование', 'Кол-во', 'Цена', 'Сумма']);

      final products = widget.orderDetails['order_products'] ?? [];
      for (var product in products) {
        final orderItemId = product['id'];
        final productName = product['product_sub_card']?['name'] ?? 'N/A';
        final price = (product['price'] ?? 0).toDouble();
        final currentQty = updatedQuantities[orderItemId] ?? 0.0;
        final subtotal = currentQty * price;
        sheet.appendRow([
          productName,
          currentQty.toStringAsFixed(2),
          price.toStringAsFixed(2),
          subtotal.toStringAsFixed(2),
        ]);
      }

      final directory = Directory('/storage/emulated/0/Download');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
      final filePath = '${directory.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.xlsx';
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

  /// Export the invoice table to PDF.
  Future<void> _exportToPdfInvoice() async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Накладная', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 16),
                // Header row
                pw.Row(
                  children: [
                    pw.Expanded(child: pw.Text('Наименование', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(child: pw.Text('Кол-во', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(child: pw.Text('Цена', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(child: pw.Text('Сумма', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                pw.Divider(),
                // Data rows
                ...widget.orderDetails['order_products'].map<Widget>((product) {
                  final orderItemId = product['id'];
                  final productName = product['product_sub_card']?['name'] ?? 'N/A';
                  final price = (product['price'] ?? 0).toDouble();
                  final currentQty = updatedQuantities[orderItemId] ?? 0.0;
                  final subtotal = currentQty * price;
                  return pw.Row(
                    children: [
                      pw.Expanded(child: pw.Text(productName)),
                      pw.Expanded(child: pw.Text(currentQty.toStringAsFixed(2), textAlign: pw.TextAlign.right)),
                      pw.Expanded(child: pw.Text(price.toStringAsFixed(2), textAlign: pw.TextAlign.right)),
                      pw.Expanded(child: pw.Text(subtotal.toStringAsFixed(2), textAlign: pw.TextAlign.right)),
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
      final path = '${directory.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf';
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
    final address = widget.orderDetails['address'] ?? 'Неизвестный адрес';
    final products = widget.orderDetails['order_products'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Накладная', style: headingStyle),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<CourierDocumentBloc, CourierDocumentState>(
            listener: (context, state) {
              if (state is CourierDocumentSubmitted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
                Navigator.pop(context);
              } else if (state is CourierDocumentError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка: ${state.error}')),
                );
              }
            },
          ),
        ],
        child: Padding(
          padding: pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Display address
              Text('Адрес: $address', style: subheadingStyle),
              const SizedBox(height: verticalPadding),
              // Invoice table
              Expanded(
                child: SingleChildScrollView(
                  child: Table(
                    border: TableBorder.all(color: borderColor),
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: primaryColor),
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Наименование',
                              style: tableHeaderStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Кол-во',
                              style: tableHeaderStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Цена',
                              style: tableHeaderStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Сумма',
                              style: tableHeaderStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      for (final product in products) _buildProductRow(product),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: verticalPadding),
              // Modern export buttons (PDF and Excel)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    style: elevatedButtonStyle,
                    onPressed: _exportToPdfInvoice,
                    icon: const FaIcon(FontAwesomeIcons.filePdf, color: Colors.white),
                    label: const Text('Выгрузить PDF', style: buttonTextStyle),
                  ),
                  ElevatedButton.icon(
                    style: elevatedButtonStyle,
                    onPressed: _exportToExcelInvoice,
                    icon: const FaIcon(FontAwesomeIcons.fileExcel, color: Colors.white),
                    label: const Text('Выгрузить Excel', style: buttonTextStyle),
                  ),
                ],
              ),
              const SizedBox(height: verticalPadding),
              // Conditionally show the submit button (hide if statusId==4)
              if (statusId != 4) ...[
                BlocBuilder<CourierDocumentBloc, CourierDocumentState>(
                  builder: (context, state) {
                    final isLoading = state is CourierDocumentLoading;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _submitCourierData,
                      style: elevatedButtonStyle,
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Отправить', style: buttonTextStyle),
                    );
                  },
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    'Статус: исполнено - редактирование не доступно',
                    style: bodyTextStyle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildProductRow(Map<String, dynamic> product) {
    final orderItemId = product['id'];
    final productName = product['product_sub_card']?['name'] ?? 'N/A';
    final price = (product['price'] ?? 0).toDouble();
    final double currentQty = updatedQuantities[orderItemId] ?? 0.0;
    final double subtotal = currentQty * price;

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(productName, style: tableCellStyle),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            initialValue: currentQty.toStringAsFixed(2),
            onChanged: (value) {
              setState(() {
                updatedQuantities[orderItemId] = double.tryParse(value) ?? 0.0;
              });
            },
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: InputBorder.none),
            enabled: (statusId != 4), // disable if status=4
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(price.toStringAsFixed(2), style: tableCellStyle),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(subtotal.toStringAsFixed(2), style: tableCellStyle),
        ),
      ],
    );
  }
}
