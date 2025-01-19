import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_control/bloc/blocs/courier_page_blocs/blocs/courier_document_bloc.dart';
import 'package:cash_control/bloc/blocs/courier_page_blocs/events/courier_document_event.dart';
import 'package:cash_control/bloc/blocs/courier_page_blocs/states/courier_document_state.dart';
import 'package:cash_control/constant.dart';

class InvoiceScreen extends StatefulWidget {
  @override
  _InvoiceScreenState createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  bool isEditing = false;
  List<Map<String, dynamic>> localDocuments = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      
      body: Padding(
        padding: pagePadding,
        child: Column(
          children: [
            Expanded(
              child: BlocListener<CourierDocumentBloc, CourierDocumentState>(
                listener: (context, state) {
                  if (state is CourierDocumentSubmittedSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('подтверждено курьером')),
                    );
                  } else if (state is CourierDocumentError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${state.error}')),
                    );
                  }
                },
                child: BlocBuilder<CourierDocumentBloc, CourierDocumentState>(
                  builder: (context, state) {
                    if (state is CourierDocumentLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is CourierDocumentLoaded) {
                      // Filter out already created orders
                      localDocuments = List<Map<String, dynamic>>.from(
                        state.documents.where((doc) => doc['courier_document_id'] == null),
                      );
                      return _buildInvoiceTable(localDocuments);
                    } else if (state is CourierDocumentError) {
                      return Center(
                        child: Text(
                          "Error: ${state.error}",
                          style: bodyTextStyle.copyWith(color: errorColor),
                        ),
                      );
                    } else {
                      return const Center(
                        child: Text("No data available.", style: bodyTextStyle),
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            _buildActionIcons(),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (localDocuments.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No documents available to submit.')),
                  );
                  return;
                }

                final List<Map<String, dynamic>> orders = localDocuments.map((doc) {
                  return {
                    'order_id': doc['id'],
                    'order_products': (doc['order_products'] ?? []).map((product) {
                      return {
                        'product_subcard_id': product['product_subcard_id'],
                        'quantity': product['quantity'],
                      };
                    }).toList(),
                  };
                }).toList();

                BlocProvider.of<CourierDocumentBloc>(context).add(
                  SubmitCourierDocumentEvent(
                    courierId: 6, // Replace with actual courier ID
                    orders: orders,
                  ),
                );
              },
              child: const Text('Отправить', style: buttonTextStyle),
              style: elevatedButtonStyle,
            ),
          ],
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
          0: FixedColumnWidth(200.0), // Invoice ID
          1: FixedColumnWidth(200.0), // Delivery Address
          2: FixedColumnWidth(150.0), // Product Name
          3: FixedColumnWidth(100.0), // Quantity
          4: FixedColumnWidth(100.0), // Price
          5: FixedColumnWidth(100.0), // Total
        },
        children: [
          _buildTableHeaderRow(),
          ..._buildDocumentRows(documents),
        ],
      ),
    );
  }

  TableRow _buildTableHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(color: primaryColor),
      children: [
        tableCell('ID Накладной', isHeader: true),
        tableCell('Адрес доставки', isHeader: true),
        tableCell('Продукт', isHeader: true),
        tableCell('Кол-во', isHeader: true),
        tableCell('Цена', isHeader: true),
        tableCell('Сумма', isHeader: true),
      ],
    );
  }

  List<TableRow> _buildDocumentRows(List<Map<String, dynamic>> documents) {
    return documents.expand<TableRow>((doc) {
      final orderProducts = doc['order_products'] ?? [];
      return orderProducts.map<TableRow>((product) {
        final packerDocumentId = doc['packer_document_id']?.toString() ?? 'N/A';
        final address = doc['address'] ?? 'No Address';
        final productName = product['product_sub_card']?['name'] ?? 'N/A';
        final quantity = product['quantity'] ?? 0;
        final price = product['price'] ?? 0.0;
        final total = (quantity * price).toStringAsFixed(2);

        return TableRow(
          children: [
            tableCell(packerDocumentId), // Invoice ID
            tableCell(address),          // Delivery Address
            tableCell(productName),      // Product Name
            tableCell(quantity.toString()), // Quantity
            tableCell(price.toString()),    // Price
            tableCell(total),               // Total
          ],
        );
      }).toList();
    }).toList();
  }

  Widget _buildActionIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(isEditing ? Icons.done : Icons.edit, color: primaryColor),
          onPressed: () {
            setState(() {
              isEditing = !isEditing;
            });
          },
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
