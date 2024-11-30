import 'dart:convert';
import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/product_sale_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_sale_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_subcard_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/product_sale_state.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/product_subcard_state.dart';
import 'package:flutter/material.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/product_subcard_bloc.dart';
import 'package:cash_control/bloc/blocs/unit_bloc.dart';
import 'package:cash_control/bloc/events/unit_event.dart';
import 'package:cash_control/bloc/states/unit_state.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_control/constant.dart';

class ProductSalePage extends StatefulWidget {
  @override
  _ProductSalePageState createState() => _ProductSalePageState();
}

class _ProductSalePageState extends State<ProductSalePage> {
  List<Map<String, dynamic>> saleRows = [];

  @override
  void initState() {
    super.initState();
    // Fetch product subcards and unit measurements
    context.read<ProductSubCardBloc>().add(FetchProductSubCardsEvent());
    context.read<UnitBloc>().add(FetchUnitsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SalesBloc, SalesState>(
    listener: (context, state) {
      if (state is SalesCreated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message)),
        );
      } else if (state is SalesError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message)),
        );
      }
    },

      child: Scaffold(
        // appBar: AppBar(
        //   title: const Text(
        //     'Продажа',
        //     style: headingStyle,
        //   ),
        //   backgroundColor: primaryColor,
        // ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Продажа",
                style: titleStyle,
              ),
              const SizedBox(height: 20),
              _buildSaleTable(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitSalesData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.all(12.0),
                ),
                child: const Text('Сохранить', style: buttonTextStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaleTable() {
    return BlocBuilder<ProductSubCardBloc, ProductSubCardState>(
      builder: (context, subcardState) {
        if (subcardState is ProductSubCardLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (subcardState is ProductSubCardsLoaded) {
          return BlocBuilder<UnitBloc, UnitState>(
            builder: (context, unitState) {
              if (unitState is UnitLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (unitState is UnitSuccess) {
                final units = unitState.message.split(','); // Unit options
                return Column(
                  children: [
                    Table(
  border: TableBorder.all(color: borderColor),
  children: [
    const TableRow(
      decoration: BoxDecoration(color: primaryColor),
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Подкарточки', style: tableHeaderStyle),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Ед. изм.', style: tableHeaderStyle),
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
          child: Text('Удалить', style: tableHeaderStyle),
        ),
      ],
    ),
    ...saleRows.asMap().entries.map((entry) {
      final index = entry.key;
      final row = entry.value;
      return TableRow(
        children: [
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(border: InputBorder.none),
            value: row['product_subcard_id'],
            items: subcardState.productSubCards.map((subcard) {
              return DropdownMenuItem<int>(
                value: subcard['id'],
                child: Text(
                  subcard['name'],
                  style: bodyTextStyle,
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                row['product_subcard_id'] = value;
              });
            },
          ),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(border: InputBorder.none),
            value: row['unit_measurement'],
            items: units.map((unit) {
              return DropdownMenuItem<String>(
                value: unit,
                child: Text(unit, style: bodyTextStyle),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                row['unit_measurement'] = value;
              });
            },
          ),
          TextField(
            onChanged: (value) {
              setState(() {
                row['amount'] = int.tryParse(value) ?? 0;
              });
            },
            decoration: const InputDecoration(hintText: 'Кол-во'),
            keyboardType: TextInputType.number,
            style: bodyTextStyle,
          ),
          TextField(
            onChanged: (value) {
              setState(() {
                row['price'] = int.tryParse(value) ?? 0;
              });
            },
            decoration: const InputDecoration(hintText: 'Цена'),
            keyboardType: TextInputType.number,
            style: bodyTextStyle,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                saleRows.removeAt(index); // Remove row at index
              });
            },
          ),
        ],
      );
    }).toList(),
  ],
),

                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          saleRows.add({
                            'product_subcard_id': null,
                            'unit_measurement': null,
                            'amount': 0,
                            'price': 0,
                          });
                        });
                      },
                    ),
                  ],
                );
              } else {
                return const Center(
                  child: Text(
                    'Ошибка при загрузке единиц измерения',
                    style: bodyTextStyle,
                  ),
                );
              }
            },
          );
        
        } else {
          return const Center(
            child: Text(
              'Ошибка при загрузке подкарточек',
              style: bodyTextStyle,
            ),
          );
        }
      },
    );
  }

  void _submitSalesData() {
  if (saleRows.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Заполните таблицу перед отправкой')),
    );
    return;
  }

  // Validate all rows
  for (var row in saleRows) {
    if (row['product_subcard_id'] == null ||
        row['unit_measurement'] == null ||
        row['amount'] <= 0 ||
        row['price'] <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля для каждой строки')),
      );
      return;
    }
  }

  // Send all rows in one go
  context.read<SalesBloc>().add(
        CreateMultipleSalesEvent(sales: saleRows),
      );
}

  }
