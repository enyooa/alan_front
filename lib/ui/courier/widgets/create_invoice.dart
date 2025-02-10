import 'package:alan/bloc/blocs/courier_page_blocs/blocs/courier_document_bloc.dart';
import 'package:alan/bloc/blocs/courier_page_blocs/events/courier_document_event.dart';
import 'package:alan/bloc/blocs/courier_page_blocs/states/courier_document_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'package:alan/constant.dart';


class InvoicePage extends StatefulWidget {
  final Map<String, dynamic> orderDetails;

  const InvoicePage({Key? key, required this.orderDetails}) : super(key: key);

  @override
  _InvoicePageState createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  late Map<int, double> updatedQuantities;

  @override
  void initState() {
    super.initState();

    // Initialize quantities
    final products = widget.orderDetails['order_products'] ?? [];
    updatedQuantities = {
      for (var product in products)
        if (product['product_sub_card'] != null)
          product['product_sub_card']['id']: product['quantity'].toDouble(),
    };
  }

  void _submitDelivery(BuildContext context) {
    final products = widget.orderDetails['order_products'];

    if (products == null || products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет доступных продуктов для доставки.')),
      );
      return;
    }

    final List<Map<String, dynamic>> orderProducts = products
        .where((product) => product['product_sub_card'] != null)
        .map<Map<String, dynamic>>((product) => {
              'product_subcard_id': product['product_sub_card']['id'],
              'quantity': updatedQuantities[product['product_sub_card']['id']] ?? 0.0,
              'price': product['price'] ?? 0.0,
              'source_table_id': product['source_table_id'],
            })
        .toList();

    if (orderProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет допустимых продуктов для обработки.')),
      );
      return;
    }

    context.read<CourierDocumentBloc>().add(
          SubmitCourierDocumentEvent(
            deliveryAddress: widget.orderDetails['address'] ?? 'Неизвестный адрес',
            orderProducts: orderProducts,
            orderId: widget.orderDetails['id'], // Include orderId
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final clientName = widget.orderDetails['user_id'] ?? 'Unknown Client';
    final address = widget.orderDetails['address'] ?? 'Unknown Address';
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
                Navigator.pop(context); // Return to the previous page
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
              Text('Клиент: $clientName', style: subheadingStyle),
              const SizedBox(height: verticalPadding),
              Text('Адрес доставки: $address', style: subheadingStyle),
              const SizedBox(height: verticalPadding),
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
                            child: Text('Наименование', style: tableHeaderStyle, textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Ед. изм.', style: tableHeaderStyle, textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Кол-во', style: tableHeaderStyle, textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Цена', style: tableHeaderStyle, textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Сумма', style: tableHeaderStyle, textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                      for (var product in products)
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                product['product_sub_card']?['name'] ?? 'N/A',
                                style: tableCellStyle,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                product['source']?['unit_measurement'] ?? 'N/A',
                                style: tableCellStyle,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                initialValue: updatedQuantities[product['product_sub_card']['id']]
                                    ?.toStringAsFixed(2),
                                onChanged: (value) {
                                  setState(() {
                                    updatedQuantities[product['product_sub_card']['id']] =
                                        double.tryParse(value) ?? 0.0;
                                  });
                                },
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                product['price']?.toString() ?? '0',
                                style: tableCellStyle,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                ((updatedQuantities[product['product_sub_card']['id']] ?? 0.0) *
                                        (product['price'] ?? 0))
                                    .toStringAsFixed(2),
                                style: tableCellStyle,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: verticalPadding),
              BlocBuilder<CourierDocumentBloc, CourierDocumentState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state is CourierDocumentLoading ? null : () => _submitDelivery(context),
                    style: elevatedButtonStyle,
                    child: state is CourierDocumentLoading
                        ? const CircularProgressIndicator()
                        : const Text('Отправить клиенту', style: buttonTextStyle),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
