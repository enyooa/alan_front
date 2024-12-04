import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_subcard_event.dart';
import 'package:cash_control/bloc/events/unit_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/price_offer_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/price_offer_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/price_offer_state.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/product_subcard_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/product_subcard_state.dart';
import 'package:cash_control/bloc/blocs/unit_bloc.dart';
import 'package:cash_control/bloc/states/unit_state.dart';
import 'package:cash_control/bloc/blocs/auth_bloc.dart';
import 'package:cash_control/bloc/events/auth_event.dart';
import 'package:cash_control/bloc/states/auth_state.dart';
import 'package:cash_control/constant.dart';

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
        appBar: AppBar(
          title: const Text('Ценовое предложение', style: headingStyle),
          backgroundColor: primaryColor,
        ),
        body: Padding(
          padding: pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildClientTable(),
              const SizedBox(height: verticalPadding),
              _buildDatePickers(),
              const SizedBox(height: verticalPadding),
              Expanded(
                child: _buildProductTable(),
              ),
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
    );
  }

  Widget _buildClientTable() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ClientUsersLoaded) {
          return Table(
            border: TableBorder.all(color: borderColor),
            children: [
              const TableRow(
                decoration: BoxDecoration(color: primaryColor),
                children: [
                  Padding(padding: EdgeInsets.all(8.0), child: Text('Клиент', style: tableHeaderStyle)),
                  Padding(padding: EdgeInsets.all(8.0), child: Text('Адрес', style: tableHeaderStyle)),
                  Padding(padding: EdgeInsets.all(8.0), child: Text('Выбрать', style: tableHeaderStyle)),
                ],
              ),
              ...state.clientUsers.map((client) {
                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(client['name'], style: bodyTextStyle),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(client['address'] ?? 'N/A', style: bodyTextStyle),
                    ),
                    IconButton(
                      icon: Icon(
                        selectedClient == client['id'].toString()
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: selectedClient == client['id'].toString() ? Colors.green : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedClient = client['id'].toString();
                        });
                      },
                    ),
                  ],
                );
              }).toList(),
            ],
          );
        } else {
          return const Text('Ошибка загрузки клиентов', style: bodyTextStyle);
        }
      },
    );
  }

  Widget _buildDatePickers() {
    return Row(
      children: [
        Expanded(
          child: _buildDatePicker(
            label: 'Начальная дата',
            selectedDate: startDate,
            onDateSelected: (date) => setState(() => startDate = date),
          ),
        ),
        const SizedBox(width: horizontalPadding / 2),
        Expanded(
          child: _buildDatePicker(
            label: 'Конечная дата',
            selectedDate: endDate,
            onDateSelected: (date) => setState(() => endDate = date),
          ),
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
            } else if (unitState is UnitSuccess) {
              final units = unitState.message.split(',');

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Table(
                    border: TableBorder.all(color: borderColor),
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(color: primaryColor),
                        children: [
                          Padding(padding: EdgeInsets.all(8.0), child: Text('Подкарточка', style: tableHeaderStyle)),
                          Padding(padding: EdgeInsets.all(8.0), child: Text('Ед. изм.', style: tableHeaderStyle)),
                          Padding(padding: EdgeInsets.all(8.0), child: Text('Кол-во', style: tableHeaderStyle)),
                          Padding(padding: EdgeInsets.all(8.0), child: Text('Цена', style: tableHeaderStyle)),
                          Padding(padding: EdgeInsets.all(8.0), child: Text('Удалить', style: tableHeaderStyle)),
                        ],
                      ),
                      ...productRows.asMap().entries.map((entry) {
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
                              onChanged: (value) => setState(() => row['product_subcard_id'] = value),
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
                              onChanged: (value) => setState(() => row['unit_measurement'] = value),
                              decoration: const InputDecoration(border: InputBorder.none),
                            ),
                            TextField(
                              onChanged: (value) => setState(() => row['amount'] = int.tryParse(value)),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(border: InputBorder.none),
                            ),
                            TextField(
                              onChanged: (value) => setState(() => row['price'] = int.tryParse(value)),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(border: InputBorder.none),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => setState(() => productRows.removeAt(index)),
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
                            'amount': 0,
                            'price': 0,
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

    final rows = productRows.map((row) {
      return {
        'product_subcard_id': row['product_subcard_id'],
        'unit_measurement': row['unit_measurement'],
        'amount': row['amount'],
        'price': row['price'],
      };
    }).toList();

    context.read<PriceOfferBloc>().add(
          SubmitPriceOfferEvent(
            clientId: int.parse(selectedClient!),
            startDate: DateFormat('yyyy-MM-dd').format(startDate!),
            endDate: DateFormat('yyyy-MM-dd').format(endDate!),
            priceOfferRows: rows,
          ),
        );
  }
}
