import 'package:cash_control/bloc/blocs/common_blocs/blocs/auth_bloc.dart';
import 'package:cash_control/bloc/blocs/packer_page_blocs/blocs/packer_document_bloc.dart';
import 'package:cash_control/bloc/blocs/packer_page_blocs/events/packer_document_event.dart';
import 'package:cash_control/bloc/blocs/packer_page_blocs/states/packer_document_state.dart';

import 'package:cash_control/bloc/blocs/common_blocs/states/auth_state.dart';
import 'package:cash_control/bloc/blocs/common_blocs/events/auth_event.dart';
import 'package:cash_control/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InvoicePage extends StatefulWidget {
  final Map<String, dynamic> orderDetails;

  const InvoicePage({Key? key, required this.orderDetails}) : super(key: key);

  @override
  _InvoicePageState createState() => _InvoicePageState();
}
class _InvoicePageState extends State<InvoicePage> {
  String? selectedCourier;
  Map<int, double> updatedQuantities = {}; // Store updated quantities for products

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(FetchCourierUsersEvent());

    // Initialize quantities with default values from order details
    final products = widget.orderDetails['order_products'] ?? [];
    for (var product in products) {
      updatedQuantities[product['product_sub_card']['id']] = product['quantity'].toDouble();
    }
  }

  void _submitDelivery(BuildContext context) {
    final address = widget.orderDetails['address'] ?? 'Unknown Address';

    if (selectedCourier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, выберите курьера')),
      );
      return;
    }

    updatedQuantities.forEach((productSubcardId, quantity) {
      context.read<PackerDocumentBloc>().add(
            SubmitPackerDocumentEvent(
              idCourier: int.parse(selectedCourier!),
              deliveryAddress: address,
              productSubcardId: productSubcardId,
              amountOfProducts: quantity,
            ),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final clientName = widget.orderDetails['user_id'] ?? 'Unknown Client';
    final address = widget.orderDetails['address'] ?? 'Unknown Address';
    final products = widget.orderDetails['order_products'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Накладная',
          style: headingStyle,
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<PackerDocumentBloc, PackerDocumentState>(
            listener: (context, state) {
              if (state is PackerDocumentSubmitted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              } else if (state is PackerDocumentError) {
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
              Text(
                'Клиент: $clientName',
                style: subheadingStyle,
              ),
              const SizedBox(height: verticalPadding),
              Text(
                'Адрес доставки: $address',
                style: subheadingStyle,
              ),
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
                              child: Text(product['product_sub_card']['name'] ?? 'N/A', style: tableCellStyle),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(product['unit_measurement'] ?? 'N/A', style: tableCellStyle),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                initialValue: updatedQuantities[product['product_sub_card']['id']]?.toString() ?? '0',
                                keyboardType: TextInputType.number,
                                style: tableCellStyle,
                                onChanged: (value) {
                                  setState(() {
                                    updatedQuantities[product['product_sub_card']['id']] =
                                        double.tryParse(value) ?? 0;
                                  });
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(product['price'].toString(), style: tableCellStyle),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                (updatedQuantities[product['product_sub_card']['id']] ?? 0 *
                                        product['price'])
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
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is CourierUsersLoaded) {
                    return DropdownButtonFormField<String>(
                      value: selectedCourier,
                      onChanged: (value) => setState(() => selectedCourier = value),
                      items: state.courierUsers
                          .map((courier) => DropdownMenuItem(
                                value: courier['id'].toString(),
                                child: Text(courier['name'], style: bodyTextStyle),
                              ))
                          .toList(),
                      decoration: const InputDecoration(
                        labelText: 'Выберите курьера',
                        labelStyle: formLabelStyle,
                        border: OutlineInputBorder(),
                      ),
                    );
                  } else {
                    return const Text(
                      'Не удалось загрузить курьеров.',
                      style: bodyTextStyle,
                    );
                  }
                },
              ),
              const SizedBox(height: verticalPadding),
              ElevatedButton(
                onPressed: () => _submitDelivery(context),
                style: elevatedButtonStyle,
                child: const Text('Отправить на доставку', style: buttonTextStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
