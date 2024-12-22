import 'package:cash_control/bloc/blocs/packer_page_blocs/blocs/packer_document_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_control/constant.dart';
import 'package:cash_control/bloc/blocs/packer_page_blocs/states/packer_document_state.dart';
import 'package:cash_control/bloc/blocs/packer_page_blocs/events/packer_document_event.dart';

class InvoiceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PackerDocumentBloc()..add(FetchPackerDocumentsEvent()),
      child: Scaffold(
        backgroundColor: backgroundColor,
        
        body: Padding(
          padding: pagePadding,
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<PackerDocumentBloc, PackerDocumentState>(
                  builder: (context, state) {
                    if (state is PackerDocumentLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is PackerDocumentsFetched) {
                      return _buildInvoiceTable(state.documents);
                    } else if (state is PackerDocumentError) {
                      return Center(
                        child: Text(
                          "Error: ${state.error}",
                          style: bodyTextStyle.copyWith(color: errorColor),
                        ),
                      );
                    } else {
                      return const Center(
                        child: Text("No data available."),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              _buildIconActions(),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Add logic for submit button
                },
                child: const Text('Отправить', style: buttonTextStyle),
                style: elevatedButtonStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceTable(List<Map<String, dynamic>> documents) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(color: borderColor, width: 1.0),
        columnWidths: const {
          0: FixedColumnWidth(200.0),
          1: FixedColumnWidth(150.0),
          2: FixedColumnWidth(150.0),
          3: FixedColumnWidth(150.0),
          4: FixedColumnWidth(150.0),
          5: FixedColumnWidth(150.0),
        },
        children: [
          _buildTableHeaderRow(),
                    ..._buildDocumentRows(documents),

          _buildSubHeaderRow(),
          _buildFooterRow(documents),
        ],
      ),
    );
  }

  TableRow _buildTableHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(color: primaryColor),
      children:  [
        tableCell('айди накладной', isHeader: true),
        tableCell('Адрес доставки', isHeader: true),
        tableCell('Телефон', isHeader: true),
        tableCell('Клиент айди', isHeader: true),
        tableCell('', isHeader: true),
        tableCell('', isHeader: true),
      ],
    );
  }

  TableRow _buildSubHeaderRow() {
    return TableRow(
      decoration: const BoxDecoration(color: accentColor),
      children:  [
        tableCell('Наименование', isHeader: true),
        tableCell('Ед изм', isHeader: true),
        tableCell('Количество\nв поставке', isHeader: true),
        tableCell('Фактическая\nпоставка', isHeader: true),
        tableCell('Цена', isHeader: true),
        tableCell('Сумма', isHeader: true),
      ],
    );
  }

  List<TableRow> _buildDocumentRows(List<Map<String, dynamic>> documents) {
  return documents.map((doc) {
    return TableRow(
      decoration: BoxDecoration(
        color: doc['id'] % 2 == 0 ? Colors.white : Colors.grey.shade100,
      ),
      children: [
        // Since there's no `supplier_name` in your data, use placeholders
        tableCell(' ${doc['id']}' ?? 'Unknown'), // Example improvisation
        tableCell(doc['delivery_address'] ?? 'Unknown'),
        tableCell('нет номера'), // Replace with actual field if available
        tableCell(doc['amount_of_products'].toString() ?? '0'),
        tableCell('Not Applicable'), // Replace with actual price field if available
        tableCell((doc['amount_of_products'] * 500).toString()), // Improvised "total amount"
      ],
    );
  }).toList();
}


  TableRow _buildFooterRow(List<Map<String, dynamic>> documents) {
    final total = documents.fold<double>(
      0,
      (sum, doc) => sum + (doc['total_amount'] ?? 0),
    );

    return TableRow(
      decoration: BoxDecoration(color: primaryColor.withOpacity(0.2)),
      children: [
         tableCell('Итого', isHeader: true),
         tableCell(''),
         tableCell(''),
         tableCell(''),
         tableCell(''),
        tableCell(total.toString(), isHeader: true),
      ],
    );
  }

  Widget _buildIconActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: primaryColor),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.table_chart, color: primaryColor),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.document_scanner, color: primaryColor),
          onPressed: () {},
        ),
      ],
    );
  }
}

Widget tableCell(String text, {bool isHeader = false}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      text,
      style: isHeader ? tableHeaderStyle : tableCellStyle,
      textAlign: TextAlign.center,
    ),
  );
}
