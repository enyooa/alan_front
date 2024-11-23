import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/price_request_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/product_subcard_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/price_request_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_subcard_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/product_subcard_state.dart';
import 'package:cash_control/bloc/blocs/unit_bloc.dart';
import 'package:cash_control/bloc/events/unit_event.dart';
import 'package:cash_control/bloc/states/unit_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cash_control/constant.dart';

import '../../../main/models/price_request.dart';

class ProductPricingPage extends StatefulWidget {
  @override
  _ProductPricingPageState createState() => _ProductPricingPageState();
}

class _ProductPricingPageState extends State<ProductPricingPage> {
  String? selectedClient;
  String? clientAddress;

  List<Map<String, dynamic>> productRows = [];

  @override
  void initState() {
    super.initState();
    // Fetch initial data for clients and products
    // context.read<UserBloc>().add(FetchUsersEvent());
    // context.read<ProductCardBloc>().add(FetchProductCardsEvent());
    context.read<UnitBloc>().add(FetchUnitsEvent());
  context.read<ProductSubCardBloc>().add(FetchProductSubCardsEvent());

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ценообразование', style: headingStyle),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildClientDropdownTable(),
            const SizedBox(height: 20),
            _buildProductTable(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitData,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Отправить', style: buttonTextStyle),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientDropdownTable() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Клиент', style: titleStyle),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Выберите клиента',
                      labelStyle: formLabelStyle,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    style: bodyTextStyle,
                    value: selectedClient,
                    items: [
                      {'id': '1', 'name': 'Иван Иванов', 'address': 'Москва'}
                    ].map((client) {
                      return DropdownMenuItem(
                        value: client['id'],
                        child: Text(client['name']!, style: bodyTextStyle),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedClient = value;
                        clientAddress = 'Москва'; // Example, replace with logic
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  clientAddress ?? '—',
                  style: bodyTextStyle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

Widget _buildProductTable() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text('Товары', style: titleStyle),
      const SizedBox(height: 10),
      BlocBuilder<UnitBloc, UnitState>(
        builder: (context, state) {
          if (state is UnitLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UnitError) {
            return Text(
              state.error,
              style: const TextStyle(color: Colors.red),
            );
          } else if (state is UnitSuccess) {
            // Use mock data or replace with actual units from API
            final units = state.message.split(","); // Assuming units are comma-separated

            return Table(
              border: TableBorder.all(color: borderColor),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1),
              },
              children: [
                // Header Row
                TableRow(
                  decoration: BoxDecoration(color: primaryColor.withOpacity(0.2)),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Наименование', style: tableHeaderStyle),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Ед изм', style: tableHeaderStyle),
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
                ...productRows.map((row) {
                  return TableRow(
                    children: [
                      // Product Dropdown
                      BlocBuilder<ProductSubCardBloc, ProductSubCardState>(
                        builder: (context, state) {
                          if (state is ProductSubCardLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state is ProductSubCardsLoaded) {
                            return DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                              ),
                              value: row['product_card_id'],
                              items: state.subcards.map((subCard) {
                                return DropdownMenuItem(
                                  value: subCard.id, // Use subCard.id instead of subCard['id']
                                  child: Text(
                                    subCard.nameOfProducts, // Use subCard.nameOfProducts instead of subCard['name']
                                    style: bodyTextStyle,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  row['product_card_id'] = value;
                                });
                              },
                            );
                          }
                          return const Text('Не удалось загрузить подкарточки', style: bodyTextStyle);
                        },
                      ),

                      // Unit Dropdown
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                        ),
                        value: row['unit'],
                        items: units.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(unit, style: bodyTextStyle),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            row['unit'] = value;
                          });
                        },
                      ),

                      // Quantity TextField
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            row['quantity'] = int.tryParse(value) ?? 0;
                            row['total'] = row['quantity'] * row['price'];
                          });
                        },
                        decoration: const InputDecoration(hintText: 'Кол-во'),
                        keyboardType: TextInputType.number,
                        style: bodyTextStyle,
                      ),

                      // Price TextField
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            row['price'] = double.tryParse(value) ?? 0.0;
                            row['total'] = row['quantity'] * row['price'];
                          });
                        },
                        decoration: const InputDecoration(hintText: 'Цена'),
                        keyboardType: TextInputType.number,
                        style: bodyTextStyle,
                      ),

                      // Total
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${row['total']}', style: bodyTextStyle),
                      ),
                    ],
                  );
                }),
              ],
            );
          }
          return const Text('Не удалось загрузить единицы измерения', style: bodyTextStyle);
        },
      ),
      const SizedBox(height: 10),
      Align(
        alignment: Alignment.centerRight,
        child: IconButton(
          icon: const Icon(Icons.add, color: primaryColor),
          onPressed: () {
            setState(() {
              productRows.add({
                'product_card_id': null,
                'unit': null,
                'quantity': 0,
                'price': 0.0,
                'total': 0.0,
              });
            });
          },
        ),
      ),
    ],
  );
}

  
  void _submitData() {
  if (selectedClient == null || productRows.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Выберите клиента и заполните таблицу')),
    );
    return;
  }

  final requestData = {
    'client_id': selectedClient,
    'products': productRows.map((row) {
      return {
        'product_card_id': row['product_card_id'],
        'quantity': row['quantity'],
        'price': row['price'],
      };
    }).toList(),
  };

  context.read<PriceRequestBloc>().add(
        CreatePriceRequestEvent(priceRequest: PriceRequest.fromJson(requestData)),
      );
}

}
