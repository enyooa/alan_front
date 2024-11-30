import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/inventory_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/product_subcard_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/inventory_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_subcard_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/inventory_state.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/product_subcard_state.dart';
import 'package:cash_control/bloc/blocs/unit_bloc.dart';
import 'package:cash_control/bloc/events/unit_event.dart';
import 'package:cash_control/bloc/states/unit_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_control/bloc/events/auth_event.dart';
import 'package:cash_control/bloc/states/auth_state.dart';
import 'package:cash_control/bloc/blocs/auth_bloc.dart';
import 'package:cash_control/constant.dart';
import 'package:intl/intl.dart';

class ProductInventoryPage extends StatefulWidget {
  @override
  _ProductInventoryPageState createState() => _ProductInventoryPageState();
}

class _ProductInventoryPageState extends State<ProductInventoryPage> {
  String? selectedStorageUser; // Selected storage user
  List<Map<String, dynamic>> productRows = []; // Inventory data rows
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(FetchStorageUsersEvent()); // Fetch storage users
    context.read<ProductSubCardBloc>().add(FetchProductSubCardsEvent());
    context.read<UnitBloc>().add(FetchUnitsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InventoryBloc, InventoryState>(
      listener: (context, state) {
        if (state is InventorySubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            productRows.clear();
            selectedDate = null;
            selectedStorageUser = null;
          });
        } else if (state is InventoryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStorageUserDropdown(),
              const SizedBox(height: 20),
              _buildInventoryTable(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitInventoryData,
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

  Widget _buildStorageUserDropdown() {
    return Card(
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StorageUsersLoaded) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Выберите сотрудника склада", style: titleStyle),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              selectedDate != null
                                  ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                                  : 'Выберите дату',
                              style: bodyTextStyle,
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.calendar_today, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Table(
                  border: TableBorder.all(color: borderColor),
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(3),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: primaryColor),
                      children: const [
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
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedStorageUser = user['id'].toString();
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(user['name'], style: bodyTextStyle),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(user['address'], style: bodyTextStyle),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                if (selectedStorageUser != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Выбранный складовщик: $selectedStorageUser',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            );
          } else if (state is AuthError) {
            return Text(state.message, style: const TextStyle(color: Colors.red));
          }
          return const Text("Нет доступных сотрудников.", style: bodyTextStyle);
        },
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
                final units = unitState.message.split(','); // Unit options
                return Column(
                  children: [
                    Table(
                      border: TableBorder.all(color: borderColor),
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: primaryColor.withOpacity(0.2)),
                          children: const [
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
                        ...productRows.asMap().entries.map((entry) {
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
                                    row['amount'] = double.tryParse(value) ?? 0.0;
                                  });
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Кол-во',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                                ),
                                keyboardType: TextInputType.number,
                                style: bodyTextStyle,
                              ),
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
                            'amount': 0.0,
                          });
                        });
                      },
                    ),
                  ],
                );
              } else {
                return const Center(
                  child: Text('Ошибка при загрузке единиц измерения', style: bodyTextStyle),
                );
              }
            },
          );
        } else {
          return const Center(
            child: Text('Ошибка при загрузке подкарточек', style: bodyTextStyle),
          );
        }
      },
    );
  }

  void _submitInventoryData() {
    if (productRows.isEmpty || selectedStorageUser == null || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля, включая дату и кладовщика')),
      );
      return;
    }

    for (var row in productRows) {
      if (row['product_subcard_id'] == null || row['amount'] <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Заполните все поля для каждой строки')),
        );
        return;
      }
    }

    context.read<InventoryBloc>().add(
          SubmitInventoryEvent(
            storageUserId: int.parse(selectedStorageUser!),
            inventoryRows: productRows.map((row) {
              row['date'] = DateFormat('yyyy-MM-dd').format(selectedDate!);
              return row;
            }).toList(),
          ),
        );
  }

  void _pickDate() async {
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
  }
}
