import 'package:cash_control/bloc/models/product_sub_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_control/bloc/blocs/unit_bloc.dart';
import 'package:cash_control/bloc/events/unit_event.dart';
import 'package:cash_control/bloc/states/unit_state.dart';
import 'package:cash_control/constant.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductPricingPage extends StatefulWidget {
  const ProductPricingPage({Key? key}) : super(key: key);

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
   
    // Fetch initial data
    context.read<UnitBloc>().add(FetchUnitsEvent());
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
            _buildClientDropdown(),
            const SizedBox(height: 20),
            _buildProductTable(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildClientDropdown() {
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
                        clientAddress = 'Москва'; // Replace with real logic
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
                  TableRow(
                    decoration: BoxDecoration(color: primaryColor.withOpacity(0.2)),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Подкарточка', style: tableHeaderStyle),
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
                        DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                          ),
                          value: row['subcard_id'],
                          items: productRows.map<DropdownMenuItem<int>>((product) {
                            return DropdownMenuItem<int>(
                              value: product['subcard_id'] as int, // Explicitly cast to int
                              child: Text(
                                'Подкарточка ${product['subcard_id']}',
                                style: bodyTextStyle,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              row['subcard_id'] = value; // Update selected subcard_id
                            });
                          },
                        ),


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
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              row['quantity'] = int.tryParse(value) ?? 0;
                              row['total'] = row['quantity'] * (row['price'] ?? 0);
                            });
                          },
                          decoration: const InputDecoration(hintText: 'Кол-во'),
                          keyboardType: TextInputType.number,
                          style: bodyTextStyle,
                        ),
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              row['price'] = double.tryParse(value) ?? 0.0;
                              row['total'] = row['quantity'] * (row['price'] ?? 0);
                            });
                          },
                          decoration: const InputDecoration(hintText: 'Цена'),
                          keyboardType: TextInputType.number,
                          style: bodyTextStyle,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${row['total']}', style: bodyTextStyle),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              );
            }
            return const Text('Не удалось загрузить данные', style: bodyTextStyle);
          },
        ),
      ],
    );
  }

 }
