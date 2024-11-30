import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/product_subcard_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_subcard_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/product_subcard_state.dart';
import 'package:cash_control/bloc/blocs/auth_bloc.dart';
import 'package:cash_control/bloc/events/auth_event.dart';
import 'package:cash_control/bloc/states/auth_state.dart';
import 'package:cash_control/constant.dart';

class ProductPricingPage extends StatefulWidget {
  @override
  _ProductPricingPageState createState() => _ProductPricingPageState();
}

class _ProductPricingPageState extends State<ProductPricingPage> {
  String? selectedClient; // Selected client
  List<Map<String, dynamic>> pricingRows = []; // Product pricing rows
  DateTime? startDate; // Start date
  DateTime? endDate; // End date

  @override
  void initState() {
    super.initState();
    // Fetch clients and products
    context.read<AuthBloc>().add(FetchClientUsersEvent());
    context.read<ProductSubCardBloc>().add(FetchProductSubCardsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Цены на продукты',
          style: headingStyle,
        ),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildClientDropdown(),
            const SizedBox(height: 20),
            _buildDatePickers(),
            const SizedBox(height: 20),
            _buildPricingTable(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitPricingData,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.all(12.0),
              ),
              child: const Text('Сохранить', style: buttonTextStyle),
            ),
          ],
        ),
      ),
    );
  }

  /// Dropdown for selecting a client
  Widget _buildClientDropdown() {
    return Card(
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ClientUsersLoaded) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("Выберите клиента", style: titleStyle),
                const SizedBox(height: 10),
                Table(
                  border: TableBorder.all(color: borderColor),
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(3),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: primaryColor.withOpacity(0.1)),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Клиент', style: tableHeaderStyle),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Адрес', style: tableHeaderStyle),
                        ),
                      ],
                    ),
                    ...state.clientUsers.map((client) {
                      return TableRow(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedClient = client['id'].toString();
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(client['name'], style: bodyTextStyle),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(client['address'] ?? '-', style: bodyTextStyle),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                if (selectedClient != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Выбранный клиент: $selectedClient',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            );
          } else if (state is AuthError) {
            return Text(state.message, style: const TextStyle(color: Colors.red));
          }
          return const Text("Нет доступных клиентов.", style: bodyTextStyle);
        },
      ),
    );
  }

  /// Date pickers for start and end date
  Widget _buildDatePickers() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDatePicker(
          label: "Начальная дата",
          selectedDate: startDate,
          onDateSelected: (date) {
            setState(() {
              startDate = date;
            });
          },
        ),
        _buildDatePicker(
          label: "Конечная дата",
          selectedDate: endDate,
          onDateSelected: (date) {
            setState(() {
              endDate = date;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required ValueChanged<DateTime?> onDateSelected,
  }) {
    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          onDateSelected(pickedDate);
        }
      },
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.grey[700]),
              const SizedBox(width: 10),
              Text(
                selectedDate != null
                    ? DateFormat('yyyy-MM-dd').format(selectedDate)
                    : label,
                style: bodyTextStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Table for displaying and managing product pricing rows
  Widget _buildPricingTable() {
  return BlocBuilder<ProductSubCardBloc, ProductSubCardState>(
    builder: (context, subcardState) {
      if (subcardState is ProductSubCardLoading) {
        return const Center(child: CircularProgressIndicator());
      } else if (subcardState is ProductSubCardsLoaded) {
        return Expanded(
          child: SingleChildScrollView(
            child: Column(
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
                          child: Text('Количество', style: tableHeaderStyle),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Цена', style: tableHeaderStyle),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Сумма', style: tableHeaderStyle),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Удалить', style: tableHeaderStyle),
                        ),
                      ],
                    ),
                    ...pricingRows.asMap().entries.map((entry) {
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
                                child: Text(subcard['name'], style: bodyTextStyle),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                row['product_subcard_id'] = value;
                              });
                            },
                          ),
                          TextField(
                            onChanged: (value) {
                              setState(() {
                                row['quantity'] = double.tryParse(value) ?? 0.0;
                                row['total'] = row['quantity'] * row['price'];
                              });
                            },
                            decoration: const InputDecoration(hintText: 'Количество'),
                            keyboardType: TextInputType.number,
                            style: bodyTextStyle,
                          ),
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              (row['quantity'] * row['price']).toStringAsFixed(2),
                              style: bodyTextStyle,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                pricingRows.removeAt(index);
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
                      pricingRows.add({
                        'product_subcard_id': null,
                        'quantity': 0.0,
                        'price': 0.0,
                        'total': 0.0,
                      });
                    });
                  },
                ),
              ],
            ),
          ),
        );
      } else {
        return const Center(
          child: Text('Ошибка при загрузке подкарточек', style: bodyTextStyle),
        );
      }
    },
  );
}

  void _submitPricingData() {
    if (selectedClient == null || startDate == null || endDate == null || pricingRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля перед отправкой')),
      );
      return;
    }

    // Validate each row
    for (var row in pricingRows) {
      if (row['product_subcard_id'] == null || row['quantity'] <= 0 || row['price'] <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Заполните все поля для каждой строки')),
        );
        return;
      }
    }

    // Map rows to request format
    final List<Map<String, dynamic>> products = pricingRows.map((row) {
      return {
        'product_subcard_id': row['product_subcard_id'],
        'quantity': row['quantity'],
        'price': row['price'],
      };
    }).toList();

    final Map<String, dynamic> requestData = {
      'client_id': int.parse(selectedClient!),
      'start_date': DateFormat('yyyy-MM-dd').format(startDate!),
      'end_date': DateFormat('yyyy-MM-dd').format(endDate!),
      'products': products,
    };

    print('Request Data: $requestData');
    // Perform submission logic here (e.g., API call).
  }
}
