import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/inventory_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/inventory_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/storage_address_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/storage_address_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/storage_address_state.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/product_subcard_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_subcard_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/product_subcard_state.dart';
import 'package:cash_control/bloc/blocs/common_blocs/blocs/unit_bloc.dart';
import 'package:cash_control/bloc/blocs/common_blocs/events/unit_event.dart';
import 'package:cash_control/bloc/blocs/common_blocs/states/unit_state.dart';
import 'package:cash_control/constant.dart';

class InventoryPage extends StatefulWidget {
  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String? selectedStorager;
  Map<String, dynamic>? selectedAddress;
  DateTime? selectedDate;

  List<Map<String, dynamic>> inventoryRows = [];

  @override
  void initState() {
    super.initState();
    context.read<StorageAddressBloc>().add(FetchStorageAddressesEvent());
    context.read<ProductSubCardBloc>().add(FetchProductSubCardsEvent());
    context.read<UnitBloc>().add(FetchUnitsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Инвентаризация', style: headingStyle),
      //   backgroundColor: primaryColor,
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStoragerAndAddressTable(),
            const SizedBox(height: 20),
            _buildDatePicker(),
            const SizedBox(height: 20),
            Expanded(child: _buildInventoryTable()),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitInventory,
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

  Widget _buildStoragerAndAddressTable() {
    return BlocBuilder<StorageAddressBloc, StorageAddressState>(
      builder: (context, state) {
        if (state is StorageAddressLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is StorageAddressesFetched) {
          if (state.storageUsers.isEmpty) {
            return const Text("Нет данных по складовщикам", style: bodyTextStyle);
          }

          return Table(
            border: TableBorder.all(color: borderColor),
            children: [
              const TableRow(
                decoration: BoxDecoration(color: primaryColor),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Складовщик', style: tableHeaderStyle),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Адрес', style: tableHeaderStyle),
                  ),
                ],
              ),
              ...state.storageUsers.map((user) {
                return TableRow(
                  children: [
                    DropdownButton<String?>(
                      value: selectedStorager,
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Выберите складовщика', style: bodyTextStyle),
                        ),
                        DropdownMenuItem<String?>(
                          value: user['storage_user_id'].toString(),
                          child: Text(user['storage_user_name'], style: bodyTextStyle),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedStorager = value;
                          selectedAddress = null; // Reset address when storager changes
                        });
                      },
                      hint: const Text("Выберите складовщика", style: bodyTextStyle),
                    ),
                    if (selectedStorager == user['storage_user_id'].toString())
                      DropdownButton<Map<String, dynamic>?>(
                        value: selectedAddress,
                        items: [
                          const DropdownMenuItem<Map<String, dynamic>?>(
                            value: null,
                            child: Text('Выберите адрес', style: bodyTextStyle),
                          ),
                          ...user['addresses'].map<DropdownMenuItem<Map<String, dynamic>?>>((address) {
                            return DropdownMenuItem<Map<String, dynamic>?>(
                              value: address,
                              child: Text(address['name'], style: bodyTextStyle),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedAddress = value;
                          });
                        },
                        hint: const Text("Выберите адрес", style: bodyTextStyle),
                      )
                    else
                      const SizedBox(),
                  ],
                );
              }).toList(),
            ],
          );
        } else if (state is StorageAddressError) {
          return Text(state.error, style: const TextStyle(color: Colors.red));
        } else {
          return const Text("Нет данных по складовщикам", style: bodyTextStyle);
        }
      },
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedDate != null
                    ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                    : 'Выберите дату',
                style: bodyTextStyle,
              ),
              const Icon(Icons.calendar_today, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryTable() {
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
                final units = unitState.message.split(',');

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
                              child: Text('Наименование', style: tableHeaderStyle),
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
                              child: Text('Удалить', style: tableHeaderStyle),
                            ),
                          ],
                        ),
                        ...inventoryRows.asMap().entries.map((entry) {
                          final index = entry.key;
                          final row = entry.value;

                          return TableRow(
                            children: [
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
                                  });
                                },
                                decoration: const InputDecoration(border: InputBorder.none),
                              ),
                              DropdownButtonFormField<String>(
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
                                decoration: const InputDecoration(border: InputBorder.none),
                              ),
                              TextField(
                                onChanged: (value) {
                                  setState(() {
                                    row['amount'] = double.tryParse(value) ?? 0.0;
                                  });
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Кол-во',
                                  border: InputBorder.none,
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    inventoryRows.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        icon: const Icon(Icons.add, color: primaryColor),
                        label: const Text('Добавить строку', style: TextStyle(color: primaryColor)),
                        onPressed: () {
                          setState(() {
                            inventoryRows.add({
                              'product_subcard_id': null,
                              'unit_measurement': null,
                              'amount': 0.0,
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

  void _submitInventory() {
  // Validation checks are commented
  // if (selectedStorager == null ||
  //     selectedAddress == null ||
  //     selectedDate == null ||
  //     inventoryRows.isEmpty) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('Заполните все поля, включая дату, складовщика и адрес')),
  //   );
  //   return;
  // }

  // for (var row in inventoryRows) {
  //   if (row['product_subcard_id'] == null || row['amount'] <= 0) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Заполните все поля для каждой строки')),
  //     );
  //     return;
  //   }
  // }
final List<Map<String, dynamic>> formattedRows = inventoryRows.map((row) {
    return {
      'product_subcard_id': row['product_subcard_id'] ?? 0, // Default to 0 if null
      'unit_measurement': row['unit_measurement'] ?? 'шт', // Default unit if null
      'amount': row['amount'] ?? 0.0, // Default to 0.0 if null
    };
  }).toList();

  // Prepare event payload with default or provided values
  final event = SubmitInventoryEvent(
    storageUserId: selectedStorager != null ? int.parse(selectedStorager!) : 1, // Default to 1 if null
    addressId: selectedAddress?['id'] ?? 1, // Default address ID if null
    date: selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(selectedDate!)
        : DateFormat('yyyy-MM-dd').format(DateTime.now()), // Use current date if null
    inventoryRows: formattedRows,
  );

  context.read<InventoryBloc>().add(event);

  // Notify user of submission
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Инвентаризация отправлена...')),
  );
}

}
