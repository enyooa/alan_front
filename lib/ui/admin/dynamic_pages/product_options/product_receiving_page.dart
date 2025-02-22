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
  List<Map<String, dynamic>> expenses = [
    // {'name': 'Фрахт', 'amount': 800000.0},
    // {'name': 'Растаможка', 'amount': 1200000.0},
    // {'name': 'Прочие', 'amount': 100000.0},
  ];
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
      child: SingleChildScrollView( // Enable scrolling
        scrollDirection: Axis.vertical, // Allow scrolling down
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProviderAndDateRow(),
              const SizedBox(height: 20),
              _buildProductTable(),
              const SizedBox(height: 20),
              _buildExpenseTable(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitReceivingData,
                child: const Text('Сохранить', style: buttonTextStyle),
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              ),
            ],
          ),
        ),
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
            } else if (unitState is UnitFetchedSuccess) {
              final units = unitState.units;

              double totalQuantity = productRows.fold(0.0, (sum, row) => sum + (row['quantity'] ?? 0.0));
              double totalSum = productRows.fold(0.0, (sum, row) => sum + ((row['netto'] ?? 0.0) * (row['price'] ?? 0.0)));
              double totalExpenses = expenses.fold(0.0, (sum, expense) => sum + (expense['amount'] ?? 0.0));
              double expensePerQuantity = totalQuantity > 0 ? totalExpenses / totalQuantity : 0.0;

              return Column(
                children: [
                  // **Scrollable Product Table**
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        // **Table Header**
                        Container(
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          child: Row(
                            children: const [
                              SizedBox(width: 150, child: Text('Товар', style: tableHeaderStyle)),
                              SizedBox(width: 120, child: Text('Кол-во тары', style: tableHeaderStyle)),
                              SizedBox(width: 140, child: Text('Ед. изм / Тара', style: tableHeaderStyle)), // ✅ Unit column added
                              SizedBox(width: 100, child: Text('Брутто', style: tableHeaderStyle)),
                              SizedBox(width: 100, child: Text('Нетто', style: tableHeaderStyle)),
                              SizedBox(width: 100, child: Text('Цена', style: tableHeaderStyle)),
                              SizedBox(width: 100, child: Text('Сумма', style: tableHeaderStyle)),
                              SizedBox(width: 100, child: Text('Допрасход', style: tableHeaderStyle)),
                              SizedBox(width: 100, child: Text('Себестоимость', style: tableHeaderStyle)),
                              SizedBox(width: 50, child: SizedBox()), // Delete button
                            ],
                          ),
                        ),

                        // **Table Rows**
                        ...productRows.asMap().entries.map((entry) {
                          int index = entry.key;
                          Map<String, dynamic> row = entry.value;

                          // Find the selected unit
                          Map<String, dynamic> selectedUnit = units.firstWhere(
                            (u) => u['name'] == row['unit_measurement'],
                            orElse: () => {'tare': 0.0, 'name': ''},
                          );

                          double unitTare = (selectedUnit['tare'] ?? 0.0) / 1000;
                          double netWeightTare = (row['quantity'] ?? 0.0) * unitTare;
                          double netto = (row['brutto'] ?? 0.0) - netWeightTare;
                          row['netto'] = netto;

                          double totalSumRow = netto * (row['price'] ?? 0.0);
                          double additionalExpense = expensePerQuantity * (row['quantity'] ?? 0.0);
                          double costPrice = (row['quantity'] != null && row['quantity']! > 0)
                              ? (additionalExpense + totalSumRow) / row['quantity']!
                              : 0.0;

                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            decoration: BoxDecoration(
                              border: const Border(bottom: tableBorderSide),
                              color: index % 2 == 0 ? backgroundColor : Colors.white,
                            ),
                            child: Row(
                              children: [
                                // Product Dropdown
                                SizedBox(
                                  width: 150,
                                  child: DropdownButtonFormField<int>(
                                    value: row['product_subcard_id'],
                                    items: productSubCardState.productSubCards.map((subCard) {
                                      return DropdownMenuItem<int>(
                                        value: subCard['id'],
                                        child: Text(subCard['name'], style: bodyTextStyle),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        row['product_subcard_id'] = value;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Товар',
                                      hintStyle: captionStyle,
                                    ),
                                  ),
                                ),

                                // Quantity Input
                                SizedBox(
                                  width: 120,
                                  child: TextField(
                                    onChanged: (value) {
                                      setState(() {
                                        row['quantity'] = double.tryParse(value) ?? 0.0;
                                      });
                                    },
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Кол-во',
                                    ),
                                  ),
                                ),

                                // ✅ Unit Measurement (Ед. изм / Тара)
                                SizedBox(
                                  width: 140,
                                  child: DropdownButtonFormField<String>(
                                    value: row['unit_measurement'],
                                    items: units.map((unit) {
                                      return DropdownMenuItem<String>(
                                        value: unit['name'],
                                        child: Text(
                                          '${unit['name']} ${unit['tare'] != null ? '(${unit['tare']} г)' : ''}',
                                          style: bodyTextStyle,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        row['unit_measurement'] = value;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Ед. изм',
                                      hintStyle: captionStyle,
                                    ),
                                  ),
                                ),

                                // Brutto Input
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    onChanged: (value) {
                                      setState(() {
                                        row['brutto'] = double.tryParse(value) ?? 0.0;
                                      });
                                    },
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Брутто',
                                    ),
                                  ),
                                ),

                                // Netto Display
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    netto.toStringAsFixed(2),
                                    style: bodyTextStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                // Price Input
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    onChanged: (value) {
                                      setState(() {
                                        row['price'] = double.tryParse(value) ?? 0.0;
                                      });
                                    },
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Цена',
                                    ),
                                  ),
                                ),

                                // Total Sum
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    totalSumRow.toStringAsFixed(2),
                                    style: bodyTextStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                // Допрасход
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    additionalExpense.toStringAsFixed(2),
                                    style: bodyTextStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                // Себестоимость
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    costPrice.toStringAsFixed(2),
                                    style: bodyTextStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),

                  // **Add Row Button**
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        productRows.add({
                          'product_subcard_id': null,
                          'unit_measurement': null,
                          'tare': null,
                          'brutto': 0.0,
                          'quantity': 0.0,
                          'price': 0.0,
                        });
                      });
                    },
                    icon: const Icon(Icons.add, color: primaryColor),
                    label: const Text('Добавить строку', style: bodyTextStyle),
                  ),
                ],
              );
            }
            return const Center(child: Text('Ошибка загрузки единиц измерения.'));
          },
        );
      }
      return const Center(child: Text('Ошибка загрузки подкарточек товаров.'));
    },
  );
}

Widget _buildSummaryTable() {
  double totalQuantity = productRows.fold(0.0, (sum, row) => sum + (row['quantity'] ?? 0.0));
  double totalSum = productRows.fold(0.0, (sum, row) => sum + ((row['netto'] ?? 0.0) * (row['price'] ?? 0.0)));
  double totalExpenses = expenses.fold(0.0, (sum, expense) => sum + (expense['amount'] ?? 0.0)); // SUM expenses

  return Container(
    margin: const EdgeInsets.only(top: 20),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: primaryColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: borderColor),
    ),
    child: Column(
      children: [
        Text("ИТОГО", style: subheadingStyle),
        Text("Общее количество: ${totalQuantity.toStringAsFixed(2)}", style: bodyTextStyle),
        Text("Общая сумма: ${totalSum.toStringAsFixed(2)}", style: bodyTextStyle),
        Text("Доп расходы: ${totalExpenses.toStringAsFixed(2)}", style: bodyTextStyle), // ADDITIONAL EXPENSES
      ],
    ),
  );
}


Widget _buildExpenseTable() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Column(
      children: [
        // Table Header
        Container(
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Row(
            children: const [
              SizedBox(width: 250, child: Text('Наименование', style: tableHeaderStyle)),
              SizedBox(width: 150, child: Text('Сумма', style: tableHeaderStyle)),
              SizedBox(width: 50, child: SizedBox()), // For delete button
            ],
          ),
        ),
        // Expense Rows
        ...expenses.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> expense = entry.value;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: tableBorderSide,
              ),
            ),
            child: Row(
              children: [
                // Name Input
                SizedBox(
                  width: 250,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        expense['name'] = value;
                      });
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Наименование',
                    ),
                  ),
                ),
                // Amount Input
                SizedBox(
                  width: 150,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        expense['amount'] = double.tryParse(value) ?? 0.0;
                      });
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Сумма',
                    ),
                  ),
                ),
                // Delete Icon
                SizedBox(
                  width: 50,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: errorColor),
                    onPressed: () {
                      setState(() {
                        expenses.removeAt(index);
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        // Add New Expense Button
        TextButton.icon(
          onPressed: () {
            setState(() {
              expenses.add({'name': '', 'amount': 0.0});
            });
          },
          icon: const Icon(Icons.add, color: primaryColor),
          label: const Text('Добавить расход', style: bodyTextStyle),
        ),
      ],
    ),
  );
}
void _submitReceivingData() {
  // Calculate the total additional expenses
  double totalAdditionalExpenses = expenses.fold(0.0, (sum, expense) => sum + (expense['amount'] ?? 0.0));

  // Prepare the list of product receiving data
  List<Map<String, dynamic>> formattedRows = productRows.map((row) {
    double netto = row['netto'] ?? 0.0;
    double price = row['price'] ?? 0.0;
    double totalSumRow = netto * price;

    return {
      'organization_id': selectedProviderId ?? 1,
      'product_subcard_id': row['product_subcard_id'] ?? 0,
      'unit_measurement': row['unit_measurement'] ?? 'шт',
      'quantity': row['quantity'] ?? 0.0,
      'price': price,
      'total_sum': totalSumRow,
      'date': selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(selectedDate!)
          : DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'cost_price': row['cost_price'] ?? 0.0,
      'additional_expenses': totalAdditionalExpenses, // Assign total additional expenses here
    };
  }).toList();

  if (formattedRows.isEmpty || formattedRows.every((row) => row['quantity'] == 0.0)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Нет данных для отправки')),
    );
    return;
  }

  // Dispatch the event to create bulk product receiving
  context.read<ProductReceivingBloc>().add(
        CreateBulkProductReceivingEvent(receivings: formattedRows),
      );

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Отправка данных...')),
  );
}



}
