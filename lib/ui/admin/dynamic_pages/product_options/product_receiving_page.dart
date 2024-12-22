import 'dart:convert';
import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/product_card_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/product_receiving_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_card_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_receiving_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/product_card_state.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/product_receiving_state.dart';
import 'package:cash_control/bloc/blocs/common_blocs/blocs/provider_bloc.dart';
import 'package:cash_control/bloc/blocs/common_blocs/blocs/unit_bloc.dart';
import 'package:cash_control/bloc/blocs/common_blocs/events/unit_event.dart';
import 'package:cash_control/bloc/blocs/common_blocs/states/provider_state.dart';
import 'package:cash_control/bloc/blocs/common_blocs/states/unit_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_control/constant.dart';
import 'package:intl/intl.dart';

import '../../../../bloc/blocs/common_blocs/events/provider_event.dart';

class ProductReceivingPage extends StatefulWidget {
  @override
  _ProductReceivingPageState createState() => _ProductReceivingPageState();
}

class _ProductReceivingPageState extends State<ProductReceivingPage> {
  List<Map<String, dynamic>> productRows = [];
  DateTime? selectedDate;
  int? selectedProviderId;

  @override
  void initState() {
    super.initState();
    // Fetch product cards and units on initialization
    context.read<ProductCardBloc>().add(FetchProductCardsEvent());
    context.read<UnitBloc>().add(FetchUnitsEvent());
    context.read<ProviderBloc>().add(FetchProvidersEvent());

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Поступление товара', style: headingStyle),
        backgroundColor: primaryColor,
      ),
      body: BlocListener<ProductReceivingBloc, ProductReceivingState>(
        listener: (context, state) {
          if (state is ProductReceivingCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            setState(() {
              productRows.clear();
              selectedDate = null;
              selectedProviderId = null;
            });
          } else if (state is ProductReceivingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProviderAndDateTable(),
              const SizedBox(height: 20),
              _buildProductTable(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitReceivingData,
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

  Widget _buildProviderAndDateTable() {
    return BlocBuilder<ProviderBloc, ProviderState>(
      builder: (context, state) {
        if (state is ProviderLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProvidersLoaded) {
          return Table(
            border: TableBorder.all(color: borderColor),
            children: [
              TableRow(
                decoration: BoxDecoration(color: primaryColor),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Поставщик', style: tableHeaderStyle),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Дата', style: tableHeaderStyle),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField<int>(
                      value: selectedProviderId,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                      hint: const Text('Выберите поставщика', style: bodyTextStyle),
                      items: state.providers.map((provider) {
                        return DropdownMenuItem<int>(
                          value: provider.id,
                          child: Text(provider.name, style: bodyTextStyle),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedProviderId = value;
                        });
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        selectedDate != null
                            ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                            : 'Выберите дату',
                        style: bodyTextStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          return const Center(
            child: Text(
              'Ошибка при загрузке поставщиков',
              style: bodyTextStyle,
            ),
          );
        }
      },
    );
  }
  
 Widget _buildProductTable() {
  return BlocBuilder<ProductCardBloc, ProductCardState>(
    builder: (context, productCardState) {
      if (productCardState is ProductCardLoading) {
        return const Center(child: CircularProgressIndicator());
      } else if (productCardState is ProductCardsLoaded) {
        return BlocBuilder<UnitBloc, UnitState>(
          builder: (context, unitState) {
            if (unitState is UnitLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (unitState is UnitSuccess) {
              final units = unitState.message.split(',');
              return Column(
                children: [
                  Table(
  border: TableBorder.all(color: borderColor),
  children: [
    // Header Row
    TableRow(
      decoration: BoxDecoration(color: primaryColor),
      children: const [
        Padding(padding: EdgeInsets.all(8.0), child: Text('Товар', style: tableHeaderStyle)),
        Padding(padding: EdgeInsets.all(8.0), child: Text('Ед изм', style: tableHeaderStyle)),
        Padding(padding: EdgeInsets.all(8.0), child: Text('Кол-во', style: tableHeaderStyle)),
        Padding(padding: EdgeInsets.all(8.0), child: Text('Цена', style: tableHeaderStyle)),
        Padding(padding: EdgeInsets.all(8.0), child: Text('Сумма', style: tableHeaderStyle)),
        Padding(padding: EdgeInsets.all(8.0), child: Text('Удалить', style: tableHeaderStyle)),
      ],
    ),
    // Data Rows
    ...productRows.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, dynamic> row = entry.value;
      return TableRow(
        children: [
          // Product dropdown
          DropdownButtonFormField<int>(
            value: row['product_card_id'],
            items: productCardState.productCards.map((product) {
              return DropdownMenuItem<int>(
                value: product['id'],
                child: Text(product['name_of_products'] ?? 'Unnamed Product'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                row['product_card_id'] = value;
              });
            },
          ),
          // Unit dropdown
          DropdownButtonFormField<String>(
            value: row['unit_measurement'],
            items: units.map((unit) {
              return DropdownMenuItem<String>(
                value: unit,
                child: Text(unit),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                row['unit_measurement'] = value;
              });
            },
          ),
          // Quantity input
          TextField(
            onChanged: (value) {
              setState(() {
                row['quantity'] = double.tryParse(value) ?? 0.0;
              });
            },
            decoration: const InputDecoration(hintText: 'Кол-во'),
            keyboardType: TextInputType.number,
          ),
          // Price input
          TextField(
            onChanged: (value) {
              setState(() {
                row['price'] = double.tryParse(value) ?? 0.0;
              });
            },
            decoration: const InputDecoration(hintText: 'Цена'),
            keyboardType: TextInputType.number,
          ),
          // Total sum
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text((row['quantity'] * row['price']).toStringAsFixed(2)),
          ),
          // Delete icon
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                productRows.removeAt(index);
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
                        productRows.add({
                          'product_card_id': null,
                          'unit_measurement': null,
                          'quantity': 0.0,
                          'price': 0.0,
                          'total_sum': 0.0,
                        });
                      });
                    },
                  ),
                ],
              );
            } else {
              return const Center(child: Text('Ошибка при загрузке единиц измерения.'));
            }
          },
        );
      } else {
        return const Center(child: Text('Ошибка при загрузке карточек товаров.'));
      }
    },
  );
}

void _submitReceivingData() {
  // Allow null values but provide defaults where necessary
  List<Map<String, dynamic>> formattedRows = productRows.map((row) {
    return {
      'organization_id': selectedProviderId ?? 1, // Default provider ID if null
      'product_card_id': row['product_card_id'] ?? 0, // Default to 0 if null
      'unit_measurement': row['unit_measurement'] ?? 'шт', // Default unit if null
      'quantity': row['quantity'] ?? 0.0, // Default to 0 if null
      'price': row['price'] ?? 0.0, // Default to 0 if null
      'total_sum': row['total_sum'] ?? 0.0, // Default to 0 if null
      'date': selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(selectedDate!)
          : DateFormat('yyyy-MM-dd').format(DateTime.now()), // Use current date if null
    };
  }).toList();

  // Check if the formattedRows contains valid data
  if (formattedRows.isEmpty || formattedRows.every((row) => row['quantity'] == 0.0)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No valid rows to submit')),
    );
    return;
  }

  // Trigger the bulk submission event
  context.read<ProductReceivingBloc>().add(
        CreateBulkProductReceivingEvent(receivings: formattedRows),
      );

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Submitting data...')),
  );
}

}
