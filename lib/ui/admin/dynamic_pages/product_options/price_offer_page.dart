import 'package:alan/bloc/blocs/admin_page_blocs/blocs/address_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/address_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/product_subcard_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/address_state.dart';
import 'package:alan/bloc/blocs/common_blocs/events/unit_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:alan/bloc/blocs/admin_page_blocs/blocs/price_offer_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/price_offer_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/price_offer_state.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/product_subcard_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/product_subcard_state.dart';
import 'package:alan/bloc/blocs/common_blocs/blocs/unit_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/states/unit_state.dart';
import 'package:alan/bloc/blocs/common_blocs/blocs/auth_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/events/auth_event.dart';
import 'package:alan/bloc/blocs/common_blocs/states/auth_state.dart';
import 'package:alan/constant.dart';

class ProductOfferPage extends StatefulWidget {
  @override
  _ProductOfferPageState createState() => _ProductOfferPageState();
}

class _ProductOfferPageState extends State<ProductOfferPage> {
  String? selectedClient;
  DateTime? startDate;
  DateTime? endDate;

  List<Map<String, dynamic>> clientRows = [];
  List<Map<String, dynamic>> productRows = [];

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(FetchClientUsersEvent());
    context.read<ProductSubCardBloc>().add(FetchProductSubCardsEvent());
    context.read<UnitBloc>().add(FetchUnitsEvent());
    context.read<AddressBloc>().add(FetchAddressesEvent());

  }

  @override
Widget build(BuildContext context) {
  return BlocListener<PriceOfferBloc, PriceOfferState>(
    listener: (context, state) {
      if (state is PriceOfferSubmitted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message), backgroundColor: Colors.green),
        );
        setState(() {
          clientRows.clear();
          productRows.clear();
          startDate = null;
          endDate = null;
          selectedClient = null;
        });
      } else if (state is PriceOfferError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message), backgroundColor: Colors.red),
        );
      }
    },
    child: Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Padding(
            padding: pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildClientTable(),
                const SizedBox(height: verticalPadding),
                // _buildDatePickers(),
                // const SizedBox(height: verticalPadding),
                _buildProductTable(),
                const SizedBox(height: verticalPadding),
                ElevatedButton(
                  onPressed: _submitPriceOffer,
                  style: ElevatedButton.styleFrom(
                    padding: buttonPadding,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    backgroundColor: primaryColor,
                  ),
                  child: const Text('Сохранить', style: buttonTextStyle),
                ),
              ],
            ),
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
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5), // Smaller radius for a compact look
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0), // Reduced padding
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isDense: true, // Makes the dropdown more compact
          isExpanded: false, // Prevents it from taking full width
          value: value,
          items: items.isEmpty
              ? [
                  DropdownMenuItem<T>(
                    value: null,
                    child: Text(label, style: bodyTextStyle.copyWith(fontSize: 12)), // Smaller font size
                  )
                ]
              : items,
          onChanged: onChanged,
          hint: Text(label, style: bodyTextStyle.copyWith(fontSize: 12)), // Smaller font size
          icon: const Icon(
            Icons.arrow_drop_down,
            size: 16, // Smaller icon size
            color: Colors.grey,
          ),
          style: bodyTextStyle.copyWith(fontSize: 12), // Apply a smaller font size to items
          dropdownColor: Colors.white, // Optional: dropdown background color
          menuMaxHeight: 200, // Optional: max height of dropdown menu
        ),
      ),
    ),
  );
}

Widget _buildClientTable() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Client Dropdown
      Expanded(
        child: _buildStyledDropdown<String>(
          label: 'Клиент',
          value: selectedClient,
          items: context.read<AddressBloc>().state is AddressesFetched
              ? (context.read<AddressBloc>().state as AddressesFetched)
                  .addresses
                  .map<DropdownMenuItem<String>>((client) {
                  return DropdownMenuItem<String>(
                    value: client['client_id'].toString(),
                    child: Text(client['client_name'], style: bodyTextStyle),
                  );
                }).toList()
              : [],
          onChanged: (value) {
            setState(() {
              selectedClient = value;
            });
          },
        ),
      ),
      const SizedBox(width: 8.0),
      // Address Dropdown
      Expanded(
        child: _buildStyledDropdown<Map<String, dynamic>>(
          label: 'Адрес',
          value: context.read<AddressBloc>().state is AddressesFetched &&
                  selectedClient != null
              ? (context.read<AddressBloc>().state as AddressesFetched)
                  .addresses
                  .firstWhere(
                    (c) => c['client_id'].toString() == selectedClient,
                    orElse: () => {},
                  )['selectedAddress']
              : null,
          items: context.read<AddressBloc>().state is AddressesFetched &&
                  selectedClient != null
              ? (context.read<AddressBloc>().state as AddressesFetched)
                  .addresses
                  .firstWhere(
                    (c) => c['client_id'].toString() == selectedClient,
                    orElse: () => {},
                  )['addresses']
                  .map<DropdownMenuItem<Map<String, dynamic>>>((address) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: address,
                    child: Text(address['name'], style: bodyTextStyle),
                  );
                }).toList()
              : [],
          onChanged: (newValue) {
            setState(() {
              if (context.read<AddressBloc>().state is AddressesFetched) {
                final addressesFetched =
                    context.read<AddressBloc>().state as AddressesFetched;
                final client = addressesFetched.addresses.firstWhere(
                  (c) => c['client_id'].toString() == selectedClient,
                  orElse: () => {},
                );
                client['selectedAddress'] = newValue;
              }
            });
          },
        ),
      ),
      const SizedBox(width: 8.0),
      // Date Picker
      Expanded(
        child: GestureDetector(
          onTap: () async {
            final pickedRange = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              initialDateRange: startDate != null && endDate != null
                  ? DateTimeRange(start: startDate!, end: endDate!)
                  : null,
            );
            if (pickedRange != null) {
              setState(() {
                startDate = pickedRange.start;
                endDate = pickedRange.end;
              });
            }
          },
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    startDate != null && endDate != null
                        ? '${DateFormat('dd-MM').format(startDate!)} - ${DateFormat('dd-MM').format(endDate!)}'
                        : 'дата',
                    style: bodyTextStyle,
                  ),
                  const Icon(Icons.calendar_today, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}


  Widget _buildDatePickers() {
  return GestureDetector(
    onTap: () async {
      final pickedRange = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        initialDateRange: startDate != null && endDate != null
            ? DateTimeRange(start: startDate!, end: endDate!)
            : null,
      );
      if (pickedRange != null) {
        setState(() {
          startDate = pickedRange.start;
          endDate = pickedRange.end;
        });
      }
    },
    child: Card(
  elevation: 2, // Reduced elevation for a sleeker look
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(5), // Smaller radius for compactness
  ),
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0), // Reduced padding
    child: GestureDetector(
      onTap: () async {
        final pickedRange = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          initialDateRange: startDate != null && endDate != null
              ? DateTimeRange(start: startDate!, end: endDate!)
              : null,
        );
        if (pickedRange != null) {
          setState(() {
            startDate = pickedRange.start;
            endDate = pickedRange.end;
          });
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            startDate != null && endDate != null
                ? '${DateFormat('dd-MM').format(startDate!)} - ${DateFormat('dd-MM').format(endDate!)}'
                : 'Выберите даты',
            style: bodyTextStyle.copyWith(fontSize: 12), // Smaller font size
          ),
          const Icon(
            Icons.calendar_today,
            size: 16, // Smaller icon size for a compact look
            color: Colors.grey,
          ),
        ],
      ),
    ),
  ),
),
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
        if (pickedDate != null) onDateSelected(pickedDate);
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate) : label,
                style: bodyTextStyle,
              ),
              const Icon(Icons.calendar_today, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
 Widget _buildProductTable() {
  return BlocBuilder<ProductSubCardBloc, ProductSubCardState>(
    builder: (context, subcardState) {
      if (subcardState is ProductSubCardLoading) {
        return const Center(child: CircularProgressIndicator());
      } else if (subcardState is ProductSubCardsLoaded) {
        return BlocBuilder<UnitBloc, UnitState>(
          builder: (context, unitState) {
            if (unitState is UnitLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (unitState is UnitFetchedSuccess) {
              final units = unitState.units; // `units` is now a List<Map<String, dynamic>>.

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Table(
                    border: TableBorder.all(color: borderColor),
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(color: primaryColor),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Подкарточка', style: tableHeaderStyle),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Остаток и ед. изм.', style: tableHeaderStyle),
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
                      ...productRows.asMap().entries.map((entry) {
                        final index = entry.key;
                        final row = entry.value;

                        return TableRow(
                          children: [
                            // Product Subcard Dropdown
                            DropdownButtonFormField<int>(
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
                                  row['amount'] = 0.0; // Reset amount when product changes
                                });
                              },
                              decoration: const InputDecoration(border: InputBorder.none),
                            ),
                            // Display Remaining Quantity and Unit Measurement
                            Text(
                              row['product_subcard_id'] != null
                                  ? '${subcardState.productSubCards.firstWhere((subcard) => subcard['id'] == row['product_subcard_id'])['remaining_quantity']} ${subcardState.productSubCards.firstWhere((subcard) => subcard['id'] == row['product_subcard_id'])['unit_measurement'] ?? ''}'
                                  : '-',
                              style: bodyTextStyle,
                            ),
                            // Unit Measurement Dropdown
                            DropdownButtonFormField<String>(
                              value: row['unit_measurement'],
                              items: units.map((unit) {
                                return DropdownMenuItem<String>(
                                  value: unit['name'],
                                  child: Text(unit['name'], style: bodyTextStyle),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  row['unit_measurement'] = value;
                                });
                              },
                              decoration: const InputDecoration(border: InputBorder.none),
                            ),
                            // Amount TextField
                            TextField(
                              onChanged: (value) {
                                setState(() {
                                  final amount = double.tryParse(value) ?? 0.0;
                                  final productSubcardId = row['product_subcard_id'];

                                  if (productSubcardId != null) {
                                    final subcard = subcardState.productSubCards.firstWhere(
                                      (subcard) => subcard['id'] == productSubcardId,
                                      orElse: () => <String, dynamic>{},
                                    );

                                    if (subcard.isNotEmpty && amount > subcard['remaining_quantity']) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Количество для "${subcard['name']}" не может превышать остаток (${subcard['remaining_quantity']}).',
                                          ),
                                        ),
                                      );
                                    } else {
                                      row['amount'] = amount;
                                    }
                                  }
                                });
                              },
                              decoration: const InputDecoration(
                                hintText: 'Кол-во',
                                border: InputBorder.none,
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            // Price TextField
                            TextField(
                              onChanged: (value) {
                                setState(() {
                                  row['price'] = double.tryParse(value) ?? 0.0;
                                });
                              },
                              decoration: const InputDecoration(
                                hintText: 'Цена',
                                border: InputBorder.none,
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            // Delete Button
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
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: const Icon(Icons.add, color: primaryColor),
                      label: const Text('Добавить строку', style: TextStyle(color: primaryColor)),
                      onPressed: () {
                        setState(() {
                          productRows.add({
                            'product_subcard_id': null,
                            'unit_measurement': null,
                            'amount': 0.0,
                            'price': 0.0,
                          });
                        });
                      },
                    ),
                  ),
                ],
              );
            } else {
              return const Text('Ошибка при загрузке единиц измерения', style: bodyTextStyle);
            }
          },
        );
      } else {
        return const Text('Ошибка при загрузке подкарточек', style: bodyTextStyle);
      }
    },
  );
}

void _submitPriceOffer() {
  if (selectedClient == null || startDate == null || endDate == null || productRows.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Заполните все поля')),
    );
    return;
  }

  final client = context.read<AddressBloc>().state is AddressesFetched
    ? (context.read<AddressBloc>().state as AddressesFetched)
        .addresses
        .firstWhere(
          (c) => c['client_id'].toString() == selectedClient,
          orElse: () => <String, dynamic>{}, // Return an empty map instead of null
        )
    : null;


  if (client == null || client['selectedAddress'] == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Выберите клиента и адрес')),
    );
    return;
  }

  // Calculate total sum for all products
  final double totalSum = productRows.fold<double>(
    0.0,
    (sum, row) => sum + ((row['amount'] ?? 0.0) * (row['price'] ?? 0.0)),
  );

  // Map rows into the required format
  final List<Map<String, dynamic>> rows = productRows.map((row) {
    return {
      'product_subcard_id': row['product_subcard_id'],
      'unit_measurement': row['unit_measurement'],
      'amount': row['amount'],
      'price': row['price'],
      'address_id': client['selectedAddress']['id'], // Use the selected address ID
    };
  }).toList();

  // Dispatch the event with total sum
  context.read<PriceOfferBloc>().add(
        SubmitPriceOfferEvent(
          clientId: int.parse(selectedClient!),
          startDate: DateFormat('yyyy-MM-dd').format(startDate!),
          endDate: DateFormat('yyyy-MM-dd').format(endDate!),
          priceOfferRows: rows,
          totalSum: totalSum,
        ),
      );

  // Show success message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Итоговая сумма: ${totalSum.toStringAsFixed(2)} отправлена!')),
  );
}

}