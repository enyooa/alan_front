import 'package:alan/bloc/blocs/courier_page_blocs/blocs/invoice_bloc.dart';
import 'package:alan/bloc/blocs/courier_page_blocs/events/invoice_event.dart';
import 'package:flutter/material.dart';
import 'package:alan/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InvoiceDetailsPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const InvoiceDetailsPage({Key? key, required this.order}) : super(key: key);

  @override
  _InvoiceDetailsPageState createState() => _InvoiceDetailsPageState();
}

class _InvoiceDetailsPageState extends State<InvoiceDetailsPage> {
  late Map<int, TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = {
      for (var product in widget.order['order_products'])
        product['id']: TextEditingController(
          text: product['quantity'].toString(),
        ),
    };
  }

  void _submitOrder(BuildContext context) {
  final updatedProducts = widget.order['order_products']
      .map((product) => {
            'product_id': product['id'],
            'quantity': int.tryParse(controllers[product['id']]?.text ?? '0') ?? product['quantity'],
          })
      .toList();

  // Dispatch the event to the bloc to handle the backend logic
  context.read<InvoiceBloc>().add(
        SubmitCourierDocument(
          orderId: widget.order['id'],
          updatedProducts: updatedProducts,
        ),
      );

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Submitting order...')),
  );
}

  @override
  Widget build(BuildContext context) {
    final products = widget.order['order_products'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали заказа', style: headingStyle),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Заказ №${widget.order['id']}', style: subheadingStyle),
            const SizedBox(height: 8),
            Text('Адрес: ${widget.order['address']}', style: bodyTextStyle),
            const SizedBox(height: 16),
            const Text('Продукты:', style: subheadingStyle),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  border: TableBorder.all(color: borderColor),
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(color: primaryColor),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Продукт', style: tableHeaderStyle),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Кол-во', style: tableHeaderStyle),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Цена', style: tableHeaderStyle),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Сумма', style: tableHeaderStyle),
                        ),
                      ],
                    ),
                    ...products.map((product) {
                      final price = product['price'];
                      final quantity = int.tryParse(controllers[product['id']]?.text ?? '0') ?? 0;
                      final total = quantity * price;

                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(product['product_sub_card']['name'], style: tableCellStyle),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: controllers[product['id']],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                              ),
                              textAlign: TextAlign.center,
                              style: bodyTextStyle,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(price.toStringAsFixed(2), style: tableCellStyle),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(total.toStringAsFixed(2), style: tableCellStyle),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _submitOrder(context),
              style: elevatedButtonStyle,
              child: const Text('Отправить', style: buttonTextStyle),
            ),
          ],
        ),
      ),
    );
  }
}
