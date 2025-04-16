import 'package:alan/ui/admin/widgets/filter_transfer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// BLoCs
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/transfer_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/transfer_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/transfer_state.dart';

import 'package:alan/bloc/blocs/admin_page_blocs/blocs/product_subcard_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/product_subcard_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/product_subcard_state.dart';

import 'package:alan/bloc/blocs/admin_page_blocs/blocs/warehouse_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/warehouse_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/warehouse_state.dart';

import 'package:alan/bloc/blocs/common_blocs/blocs/unit_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/events/unit_event.dart';
import 'package:alan/bloc/blocs/common_blocs/states/unit_state.dart';

// Styles: #0ABCD7 -> #6CC6DA
import 'package:alan/constant_new_version.dart';

class ProductTransferPage extends StatefulWidget {
  final VoidCallback? onClose;

  const ProductTransferPage({Key? key, this.onClose}) : super(key: key);

  @override
  State<ProductTransferPage> createState() => _ProductTransferPageState();
}

class _ProductTransferPageState extends State<ProductTransferPage> {
  // --------------------------------------------------------------------------
  // Filter fields (source/dest warehouse, date), chosen via FilterTransferPage
  // --------------------------------------------------------------------------
  int? _sourceWhId;
  int? _destWhId;
  DateTime? _selectedDate;

  // --------------------------------------------------------------------------
  // Product rows => each row: product_subcard_id, quantity, unit
  // --------------------------------------------------------------------------
  final List<Map<String, dynamic>> _productRows = [
    {
      'product_subcard_id': null,
      'quantity': 0.0,
      'unit_measurement': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Kick off the data fetch
    context.read<WarehouseBloc>().add(FetchWarehousesEvent());
    context.read<UnitBloc>().add(FetchUnitsEvent());
    context.read<ProductSubCardBloc>().add(FetchProductSubCardsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient AppBar (#0ABCD7 -> #6CC6DA)
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Text('Перемещение', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, accentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          // Фильтр button => open FilterTransferPage
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            tooltip: 'Фильтр',
            onPressed: _openFilterScreen,
          ),
          // Close
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              widget.onClose?.call();
              Navigator.pop(context);
            },
          ),
        ],
      ),

      // Listen for "transfer created" or "error"
      body: BlocListener<ProductTransferBloc, ProductTransferState>(
        listener: (context, state) {
          if (state is ProductTransferCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // Reset or pop
            setState(() {
              _sourceWhId = null;
              _destWhId   = null;
              _selectedDate = null;
              _productRows.clear();
              _productRows.add({
                'product_subcard_id': null,
                'quantity': 0.0,
                'unit_measurement': null,
              });
            });
            widget.onClose?.call();
          } else if (state is ProductTransferError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Show the chosen filter at top
              _buildChosenFilterSummary(),
              const SizedBox(height: 16),

              // Product table
              _buildProductTable(),
              const SizedBox(height: 16),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: _onSave,
                child: const Text('Сохранить перемещение', style: buttonTextStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Show the chosen filter at top
  // --------------------------------------------------------------------------
  Widget _buildChosenFilterSummary() {
    final srcStr = _sourceWhId?.toString() ?? 'нет';
    final dstStr = _destWhId?.toString() ?? 'нет';
    final dateStr = (_selectedDate == null)
        ? 'Не выбрана'
        : DateFormat('yyyy-MM-dd').format(_selectedDate!);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: ListTile(
        title: Text(
          'Текущий фильтр:',
          style: bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Откуда: $srcStr\n'
          'Куда: $dstStr\n'
          'Дата: $dateStr',
          style: bodyTextStyle,
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Open filter page => store results
  // --------------------------------------------------------------------------
  Future<void> _openFilterScreen() async {
    final initFilter = TransferFilterData(
      sourceWhId: _sourceWhId,
      destWhId:   _destWhId,
      date:       _selectedDate,
    );

    final result = await Navigator.push<TransferFilterData>(
      context,
      MaterialPageRoute(
        builder: (_) => FilterTransferPage(initialFilter: initFilter),
      ),
    );

    // If user picks filter => update
    if (result != null) {
      setState(() {
        _sourceWhId = result.sourceWhId;
        _destWhId   = result.destWhId;
        _selectedDate = result.date;
      });
    }
  }

  // --------------------------------------------------------------------------
  // Product table
  // --------------------------------------------------------------------------
  Widget _buildProductTable() {
    return BlocBuilder<ProductSubCardBloc, ProductSubCardState>(
      builder: (context, subcardState) {
        if (subcardState is ProductSubCardLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (subcardState is ProductSubCardError) {
          return Text('Ошибка товаров: ${subcardState.message}', style: bodyTextStyle);
        } else if (subcardState is ProductSubCardsLoaded) {
          final subcards = subcardState.productSubCards;
          return BlocBuilder<UnitBloc, UnitState>(
            builder: (context, unitState) {
              if (unitState is UnitLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (unitState is UnitFetchedSuccess) {
                final units = unitState.units;
                return _buildTableBody(subcards, units);
              }
              return const Text('Ошибка ед. изм', style: bodyTextStyle);
            },
          );
        }
        return const Text('Загрузка товаров...', style: bodyTextStyle);
      },
    );
  }

  Widget _buildTableBody(List<dynamic> subcards, List<dynamic> units) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: accentColor, width: 1.2),
      ),
      child: Padding(
        padding: elementPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title bar
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryColor, accentColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Товары для перемещения',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: () {
                          setState(() => _productRows.clear());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _productRows.add({
                              'product_subcard_id': null,
                              'quantity': 0.0,
                              'unit_measurement': null,
                            });
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Table header
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, accentColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                children: [
                  _tableHeaderCell('Товар', width:120),
                  _tableHeaderCell('Кол-во', width:60),
                  _tableHeaderCell('Ед. изм', width:60),
                  _tableHeaderCell('', width:50), // Delete icon
                ],
              ),
            ),

            // Table body
            Column(
              children: List.generate(_productRows.length, (i) {
                final row = _productRows[i];
                return Row(
                  children: [
                    _tableBodyCell(
                      width: 120,
                      child: DropdownButton<int>(
                        value: row['product_subcard_id'],
                        isExpanded: true,
                        underline: const SizedBox(),
                        style: tableCellStyle,
                        items: subcards.map<DropdownMenuItem<int>>((sc) {
                          return DropdownMenuItem<int>(
                            value: sc['id'],
                            child: Text(sc['name'] ?? 'NoName', style: tableCellStyle),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => row['product_subcard_id'] = val);
                        },
                      ),
                    ),
                    _tableBodyCell(
                      width: 60,
                      child: TextField(
                        style: tableCellStyle,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                        ),
                        onChanged: (val) {
                          setState(() => row['quantity'] = double.tryParse(val) ?? 0.0);
                        },
                      ),
                    ),
                    _tableBodyCell(
                      width: 60,
                      child: DropdownButton<String>(
                        value: row['unit_measurement'],
                        isExpanded: true,
                        underline: const SizedBox(),
                        style: tableCellStyle,
                        items: units.map<DropdownMenuItem<String>>((u) {
                          final unitName = (u['name'] ?? '').toString();
                          return DropdownMenuItem<String>(
                            value: unitName,
                            child: Text(unitName, style: tableCellStyle),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => row['unit_measurement'] = val);
                        },
                      ),
                    ),
                    _tableBodyCell(
                      width: 50,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() => _productRows.removeAt(i));
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableHeaderCell(String label, {double width=100}) {
    return Container(
      width: width,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(right: tableBorderSide),
      ),
      child: Text(label, style: tableHeaderStyle, textAlign: TextAlign.center),
    );
  }

  Widget _tableBodyCell({required Widget child, double width=100}) {
    return Container(
      width: width,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        border: Border(
          right: tableBorderSide,
          bottom: tableBorderSide,
        ),
      ),
      child: child,
    );
  }

  // --------------------------------------------------------------------------
  // On Save => dispatch to create
  // --------------------------------------------------------------------------
  void _onSave() {
    // Basic validation
    if (_sourceWhId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Укажите склад 'Откуда'")),
      );
      return;
    }
    if (_destWhId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Укажите склад 'Куда'")),
      );
      return;
    }
    if (_sourceWhId == _destWhId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Нельзя перемещать в тот же склад.")),
      );
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Укажите дату перемещения.")),
      );
      return;
    }
    if (_productRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Нет данных для перемещения.")),
      );
      return;
    }

    final docDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    final productList = _productRows.map((row) {
      return {
        'product_subcard_id': row['product_subcard_id'] ?? 0,
        'quantity': row['quantity'] ?? 0.0,
        'unit_measurement': row['unit_measurement'] ?? '',
      };
    }).toList();

    final payload = {
      'source_warehouse_id': _sourceWhId,
      'destination_warehouse_id': _destWhId,
      'document_date': docDate,
      'products': productList,
    };

    context.read<ProductTransferBloc>().add(
      CreateBulkProductTransferEvent(payload: payload),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Сохранение перемещения...')),
    );
  }
}
