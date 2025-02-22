import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// Bloc imports (adjust to your structure)
import 'package:alan/bloc/blocs/storage_page_blocs/blocs/storage_subcard_bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/events/storage_subcard_event.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/storage_subcard_state.dart';
import 'package:alan/bloc/blocs/common_blocs/blocs/unit_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/events/unit_event.dart';
import 'package:alan/bloc/blocs/common_blocs/states/unit_state.dart';
// import 'package:alan/bloc/blocs/storage_page_blocs/blocs/storage_writeoff_bloc.dart'; // Example
// import 'package:alan/bloc/blocs/storage_page_blocs/events/storage_writeoff_event.dart'; // Example
// import 'package:alan/bloc/blocs/storage_page_blocs/states/storage_writeoff_state.dart'; // Example

import 'package:alan/constant.dart';

class WriteOffPage extends StatefulWidget {
  const WriteOffPage({Key? key}) : super(key: key);

  @override
  State<WriteOffPage> createState() => _WriteOffPageState();
}

class _WriteOffPageState extends State<WriteOffPage> {
  // Each row: { 'subcard_id': int?, 'unit_id': int?, 'quantity': double, 'cost': double }
  final List<Map<String, dynamic>> writeOffRows = [];

  // Fetched data
  List<Map<String, dynamic>> subcards = [];
  List<Map<String, dynamic>> units = [];

  // Optional date selection
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

  /// Computes the total cost by summing the `cost` of each row.
  double get totalCost {
    return writeOffRows.fold(0.0, (acc, row) => acc + (row['cost'] ?? 0.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Списание ТМЗ'),
        backgroundColor: primaryColor,
      ),
      body: MultiBlocListener(
        listeners: [
          // Example: If you have a WriteOffBloc, you can add a listener for success/error
          // BlocListener<StorageWriteOffBloc, StorageWriteOffState>(
          //   listener: (context, state) {
          //     if (state is StorageWriteOffCreated) {
          //       ScaffoldMessenger.of(context).showSnackBar(
          //         SnackBar(content: Text(state.message)),
          //       );
          //       // Clear rows after successful submission
          //       setState(() {
          //         writeOffRows.clear();
          //         selectedDate = null;
          //       });
          //     } else if (state is StorageWriteOffError) {
          //       ScaffoldMessenger.of(context).showSnackBar(
          //         SnackBar(content: Text(state.message)),
          //       );
          //     }
          //   },
          // ),
          BlocListener<UnitBloc, UnitState>(
            listener: (context, state) {
              if (state is UnitFetchedSuccess) {
                setState(() {
                  // `units` is a List<Map<String, dynamic>>
                  units = state.units;
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
        children: [
          _buildDatePicker(),
          const SizedBox(height: 20),
          _buildWriteOffTable(),
          const SizedBox(height: 20),
          _buildTotalCostRow(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitWriteOffData,
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

  /// Simple date picker to choose a date for the write-off (optional).
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
      child: Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.grey[200],
        child: Text(
          selectedDate != null
              ? DateFormat('yyyy-MM-dd').format(selectedDate!)
              : 'Выберите дату',
          style: bodyTextStyle,
        ),
      ),
    );
  }

  /// Main table layout for writing off items.
  Widget _buildWriteOffTable() {
    return Column(
      children: [
        Table(
          border: TableBorder.all(color: borderColor),
          children: [
            // Header row
            TableRow(
              decoration: BoxDecoration(color: primaryColor),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Наименование товара', style: tableHeaderStyle),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Ед изм', style: tableHeaderStyle),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Кол-во', style: tableHeaderStyle),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Себестоймость', style: tableHeaderStyle),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Удалить', style: tableHeaderStyle),
                ),
              ],
            ),
            // Dynamic rows
            ...writeOffRows.asMap().entries.map((entry) {
              final index = entry.key;
              final row = entry.value;

              return TableRow(
                children: [
                  // Наименование товара
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: DropdownButton<int>(
                      value: row['subcard_id'],
                      items: subcards.map((subcard) {
                        return DropdownMenuItem<int>(
                          value: subcard['id'],
                          child: Text(subcard['name'] ?? '—'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          row['subcard_id'] = value;
                        });
                      },
                      hint: const Text('Товар'),
                    ),
                  ),

                  // Ед изм
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: DropdownButton<int>(
                      value: row['unit_id'],
                      items: units.map((unit) {
                        return DropdownMenuItem<int>(
                          value: unit['id'],
                          child: Text(unit['name'] ?? '—'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          row['unit_id'] = value;
                        });
                      },
                      hint: const Text('Ед изм'),
                    ),
                  ),

                  // Кол-во
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          row['quantity'] = double.tryParse(value) ?? 0.0;
                        });
                      },
                      decoration: const InputDecoration(hintText: 'Кол-во'),
                      keyboardType: TextInputType.number,
                    ),
                  ),

                  // Себестоймость
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          row['cost'] = double.tryParse(value) ?? 0.0;
                        });
                      },
                      decoration: const InputDecoration(hintText: 'Себестоймость'),
                      keyboardType: TextInputType.number,
                    ),
                  ),

                  // Удалить
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        writeOffRows.removeAt(index);
                      });
                    },
                  ),
                ],
              );
            }).toList(),
          ],
        ),
        // "Add row" button
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                writeOffRows.add({
                  'subcard_id': null,
                  'unit_id': null,
                  'quantity': 0.0,
                  'cost': 0.0,
                });
              });
            },
          ),
        ),
      ],
    );
  }

  /// A row to display the total себестоймость at the bottom.
  Widget _buildTotalCostRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text('Итого:', style: tableHeaderStyle),
        const SizedBox(width: 8),
        Text(
          totalCost.toStringAsFixed(2),
          style: tableHeaderStyle,
        ),
      ],
    );
  }

  /// Called when user presses "Сохранить".
  void _submitWriteOffData() {
    // Validate subcards
    if (writeOffRows.any((row) => row['subcard_id'] == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите все подкарточки товаров')),
      );
      return;
    }

    // Format the data
    final List<Map<String, dynamic>> formattedRows = writeOffRows.map((row) {
      return {
        'subcard_id': row['subcard_id'],
        'unit_id': row['unit_id'],
        'quantity': row['quantity'],
        'cost': row['cost'],
        'date': selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(selectedDate!)
            : DateFormat('yyyy-MM-dd').format(DateTime.now()),
      };
    }).toList();

    // Dispatch your event here, e.g.:
    // context.read<StorageWriteOffBloc>().add(
    //   CreateBulkWriteOffEvent(writeOffs: formattedRows),
    // );

    // For now, just show a SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Списание ТМЗ сохранено')),
    );

    // Optionally clear the form
    // setState(() {
    //   writeOffRows.clear();
    //   selectedDate = null;
    // });
  }
}
