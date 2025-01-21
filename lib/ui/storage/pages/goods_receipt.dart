
import 'package:alan/bloc/blocs/common_blocs/blocs/unit_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/events/unit_event.dart';
import 'package:alan/bloc/blocs/common_blocs/states/unit_state.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/blocs/storage_receiving_bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/blocs/storage_subcard_bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/events/storage_receiving_event.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/events/storage_subcard_event.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/storage_receiving_state.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/storage_subcard_state.dart';
import 'package:alan/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class GoodsReceiptPage extends StatefulWidget {
  const GoodsReceiptPage({Key? key}) : super(key: key);

  @override
  State<GoodsReceiptPage> createState() => _GoodsReceiptPageState();
}

class _GoodsReceiptPageState extends State<GoodsReceiptPage> {
  List<Map<String, dynamic>> goodsRows = [];
  List<Map<String, dynamic>> subcards = [];
  List<String> units = [];

  DateTime? selectedDate;
  @override
  void initState() {
    super.initState();
    _fetchSubCards();
    _fetchUnits();

  }
   void _fetchSubCards() {
    context.read<StorageSubCardBloc>().add(FetchProductSubCardsEvent());
  }
  void _fetchUnits() {
  context.read<UnitBloc>().add(FetchUnitsEvent());
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<StorageReceivingBloc, StorageReceivingState>(
            listener: (context, state) {
              if (state is StorageReceivingCreated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
                setState(() {
                  goodsRows.clear();
                  selectedDate = null;
                });
              } else if (state is StorageReceivingError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
          ),
          BlocListener<UnitBloc, UnitState>(
            listener: (context, state) {
              if (state is UnitSuccess) {
                setState(() {
                  units = state.message.split(','); // Parse comma-separated units
                });
              } else if (state is UnitError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error)),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<StorageSubCardBloc, ProductSubCardState>(
          builder: (context, state) {
            if (state is ProductSubCardsLoaded) {
              subcards = state.productSubCards;
            }
            return _buildPageContent();
          },
        ),
      ),
    );
  }

  
  Widget _buildPageContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDatePicker(),
          const SizedBox(height: 20),
          _buildGoodsTable(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitGoodsData,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.all(12.0),
            ),
            child: const Text('Сохранить', style: buttonTextStyle),
          ),
        ],
      ),
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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          selectedDate != null
              ? DateFormat('yyyy-MM-dd').format(selectedDate!)
              : 'Выберите дату',
          style: bodyTextStyle,
        ),
      ),
    );
  }

  Widget _buildGoodsTable() {
  return Column(
    children: [
      Table(
        border: TableBorder.all(color: borderColor),
        children: [
          TableRow(
            decoration: BoxDecoration(color: primaryColor),
            children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Товар', style: tableHeaderStyle),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Единица', style: tableHeaderStyle),
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
                child: Text('Сумма', style: tableHeaderStyle),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Удалить', style: tableHeaderStyle),
              ),
            ],
          ),
          ...goodsRows.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> row = entry.value;
            return TableRow(
              children: [
                DropdownButton<int>(
                  value: row['subcard_id'],
                  items: subcards.map((subcard) {
                    return DropdownMenuItem<int>(
                      value: subcard['id'],
                      child: Text(subcard['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      row['subcard_id'] = value;
                    });
                  },
                  hint: const Text('подкарточка'),
                ),
                DropdownButton<String>(
                  value: row['name'],
                  items: units.map((unit) {
                    return DropdownMenuItem<String>(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      row['name'] = value;
                    });
                  },
                  hint: const Text('ед.изм'),
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      row['quantity'] = double.tryParse(value) ?? 0.0;
                    });
                  },
                  decoration: const InputDecoration(hintText: 'Кол-во'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      row['price'] = double.tryParse(value) ?? 0.0;
                    });
                  },
                  decoration: const InputDecoration(hintText: 'Цена'),
                  keyboardType: TextInputType.number,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text((row['quantity'] * row['price']).toStringAsFixed(2)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      goodsRows.removeAt(index);
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
            goodsRows.add({
              'subcard_id': null,
              'unit_name': null,
              'quantity': 0.0,
              'price': 0.0,
            });
          });
        },
      ),
    ],
  );
}

  void _submitGoodsData() {
    if (goodsRows.any((row) => row['subcard_id'] == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите все подкарточки товаров')),
      );
      return;
    }

    List<Map<String, dynamic>> formattedRows = goodsRows.map((row) {
  return {
    'subcard_id': row['subcard_id'],
    'unit_name': row['name'], // Include unit name
    'quantity': row['quantity'],
    'price': row['price'],
    'date': selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(selectedDate!)
        : DateFormat('yyyy-MM-dd').format(DateTime.now()),
  };
}).toList();


    context.read<StorageReceivingBloc>().add(
          CreateBulkStorageReceivingEvent(receivings: formattedRows),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Поступление ТМЗ сохранено')),
    );
  }
}
