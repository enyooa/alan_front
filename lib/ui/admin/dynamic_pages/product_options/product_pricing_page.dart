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
  List<Map<String, dynamic>> priceOfferRows = [];
  DateTime? startDate;
  DateTime? endDate;

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
            priceOfferRows.clear();
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildClientDropdown(),
              const SizedBox(height: 20),
              _buildDatePickers(),
              const SizedBox(height: 20),
              _buildPriceOfferTable(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitPriceOffer,
                child: const Text('Сохранить', style: buttonTextStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClientDropdown() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ClientUsersLoaded) {
          return DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Клиент'),
            items: state.clientUsers.map((client) {
              return DropdownMenuItem(
                value: client['id'].toString(),
                child: Text(client['name']),
              );
            }).toList(),
            onChanged: (value) => setState(() => selectedClient = value),
            value: selectedClient,
          );
        } else {
          return const Text('Ошибка загрузки клиентов');
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
        const SizedBox(width: 10),
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
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(
          selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate) : 'Выберите дату',
        ),
      ),
    );
  }

  Widget _buildPriceOfferTable() {
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
                    ...priceOfferRows.asMap().entries.map((entry) {
                      final index = entry.key;
                      final row = entry.value;
                      return _buildPriceOfferRow(row, subcardState.productSubCards, units, index);
                    }),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          priceOfferRows.add({
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
                return const Text('Ошибка при загрузке единиц измерения');
              }
            },
          );
        } else {
          return const Text('Ошибка при загрузке подкарточек');
        }
      },
    );
  }

  Widget _buildPriceOfferRow(
    Map<String, dynamic> row,
    List<Map<String, dynamic>> productSubcards,
    List<String> units,
    int index,
  ) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'Подкарточка'),
            value: row['product_subcard_id'],
            items: productSubcards.map((subcard) {
              return DropdownMenuItem<int>(
                value: subcard['id'],
                child: Text(subcard['name']),
              );
            }).toList(),
            onChanged: (value) => setState(() => row['product_subcard_id'] = value),
          ),
        ),
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Ед. изм.'),
            value: row['unit_measurement'],
            items: units.map((unit) {
              return DropdownMenuItem<String>(
                value: unit,
                child: Text(unit),
              );
            }).toList(),
            onChanged: (value) => setState(() => row['unit_measurement'] = value),
          ),
        ),
        Expanded(
          child: TextField(
            decoration: const InputDecoration(labelText: 'Кол-во'),
            keyboardType: TextInputType.number,
            onChanged: (value) => setState(() => row['amount'] = int.tryParse(value)),
          ),
        ),
        Expanded(
          child: TextField(
            decoration: const InputDecoration(labelText: 'Цена'),
            keyboardType: TextInputType.number,
            onChanged: (value) => setState(() => row['price'] = int.tryParse(value)),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => setState(() => priceOfferRows.removeAt(index)),
        ),
      ],
    );
  }

  void _submitPriceOffer() {
    if (selectedClient == null || startDate == null || endDate == null || priceOfferRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля')),
      );
      return;
    }

    final rows = priceOfferRows.map((row) {
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
