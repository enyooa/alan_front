import 'dart:convert';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/product_receiving_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/product_subcard_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/product_receiving_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/product_subcard_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/product_receiving_state.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/product_subcard_state.dart';
import 'package:alan/bloc/blocs/common_blocs/blocs/provider_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/blocs/unit_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/events/unit_event.dart';
import 'package:alan/bloc/blocs/common_blocs/states/provider_state.dart';
import 'package:alan/bloc/blocs/common_blocs/states/unit_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alan/constant.dart';
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
  context.read<ProductSubCardBloc>().add(FetchProductSubCardsEvent());
    context.read<UnitBloc>().add(FetchUnitsEvent());
    context.read<ProviderBloc>().add(FetchProvidersEvent());

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Поступление товара', style: headingStyle),
      //   backgroundColor: primaryColor,
      // ),
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
  children: [
    _buildProviderAndDateRow(),
    const SizedBox(height: 20),
    _buildProductTable(),
    const SizedBox(height: 20),
    ElevatedButton(
      onPressed: _submitReceivingData,
      child: const Text('Сохранить', style: buttonTextStyle),
      style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
    ),
  ],
)
),
      ),
    );
  }

Widget _buildStyledDropdown<T>({
  required String label,
  required T? value,
  required List<DropdownMenuItem<T>> items,
  required ValueChanged<T?> onChanged,
}) {
  return Card(
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0), // Reduced padding for compact size
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          items: items.isEmpty
              ? [
                  DropdownMenuItem<T>(
                    value: null,
                    child: Text(label, style: bodyTextStyle),
                  )
                ]
              : items,
          onChanged: onChanged,
          hint: Text(label, style: bodyTextStyle),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
        ),
      ),
    ),
  );
}


Widget _buildProviderAndDateRow() {
  return BlocBuilder<ProviderBloc, ProviderState>(
    builder: (context, state) {
      if (state is ProviderLoading) {
        return const Center(child: CircularProgressIndicator());
      } else if (state is ProvidersLoaded) {
        return Row(
          children: [
            // Provider Dropdown
            Expanded(
              flex: 1, // Control size distribution
              child: SizedBox(
                height: 40, // Fixed height for uniformity
                child: _buildStyledDropdown<int>(
                  label: 'Поставщик',
                  value: selectedProviderId,
                  items: state.providers.map((provider) {
                    return DropdownMenuItem<int>(
                      value: provider.id,
                      child: Text(provider.name, style: bodyTextStyle.copyWith(fontSize: 12)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedProviderId = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(width: 8.0), // Compact spacing between fields
            // Date Picker
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 40, // Match height with dropdown
                child: GestureDetector(
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
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5), // Small radius for compact look
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDate != null
                                ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                                : 'Дата',
                            style: bodyTextStyle.copyWith(fontSize: 12), // Smaller text
                          ),
                          const Icon(
                            Icons.calendar_today,
                            size: 16, // Compact icon size
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      } else {
        return const Center(
          child: Text('Ошибка при загрузке поставщиков', style: bodyTextStyle),
        );
      }
    },
  );
}
  
Widget _buildProductTable() {
  return BlocBuilder<ProductSubCardBloc, ProductSubCardState>(
    builder: (context, productSubCardState) {
      if (productSubCardState is ProductSubCardLoading) {
        return const Center(child: CircularProgressIndicator());
      } else if (productSubCardState is ProductSubCardsLoaded) {
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
                          Padding(padding: EdgeInsets.all(10.0), child: Text('Товар', style: tableHeaderStyle)),
                          Padding(padding: EdgeInsets.all(10.0), child: Text('Ед изм', style: tableHeaderStyle)),
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
                            // SubProduct dropdown
                            DropdownButtonFormField<int>(
                              value: row['product_subcard_id'],
                              items: productSubCardState.productSubCards.map((subCard) {
                                return DropdownMenuItem<int>(
                                  value: subCard['id'],
                                  child: Text(subCard['name']),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  row['product_subcard_id'] = value;
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
                          'product_subcard_id': null,
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
        return const Center(child: Text('Ошибка при загрузке подкарточек товаров.'));
      }
    },
  );
}


void _submitReceivingData() {
  List<Map<String, dynamic>> formattedRows = productRows.map((row) {
    return {
      'organization_id': selectedProviderId ?? 1,
      'product_subcard_id': row['product_subcard_id'] ?? 0,
      'unit_measurement': row['unit_measurement'] ?? 'шт',
      'quantity': row['quantity'] ?? 0.0,
      'price': row['price'] ?? 0.0,
      'total_sum': row['total_sum'] ?? 0.0,
      'date': selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(selectedDate!)
          : DateFormat('yyyy-MM-dd').format(DateTime.now()),
    };
  }).toList();

  if (formattedRows.isEmpty || formattedRows.every((row) => row['quantity'] == 0.0)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Нет данных для отправки')),
    );
    return;
  }

  context.read<ProductReceivingBloc>().add(
        CreateBulkProductReceivingEvent(receivings: formattedRows),
      );

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Отправка данных...')),
  );
}

}
