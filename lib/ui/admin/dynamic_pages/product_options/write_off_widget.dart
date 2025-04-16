import 'package:alan/ui/admin/widgets/filter_write_off_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// BLoCs
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/write_off_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/write_off_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/write_off_state.dart';

import 'package:alan/bloc/blocs/admin_page_blocs/blocs/product_subcard_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/product_subcard_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/product_subcard_state.dart';

import 'package:alan/bloc/blocs/admin_page_blocs/blocs/warehouse_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/warehouse_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/warehouse_state.dart';

import 'package:alan/bloc/blocs/common_blocs/blocs/unit_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/events/unit_event.dart';
import 'package:alan/bloc/blocs/common_blocs/states/unit_state.dart';

// Constants / Styles
import 'package:alan/constant_new_version.dart';

// Filter page (below)

class ProductWriteOffPage extends StatefulWidget {
  final VoidCallback? onClose;

  const ProductWriteOffPage({Key? key, this.onClose}) : super(key: key);

  @override
  State<ProductWriteOffPage> createState() => _ProductWriteOffPageState();
}

class _ProductWriteOffPageState extends State<ProductWriteOffPage> {
  // ------------------------------------
  // Filter fields
  // ------------------------------------
  int? _selectedWarehouseId;
  DateTime? _selectedDate;

  /// The product rows (just product, quantity, unit)
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
    // Pre-fetch references
    context.read<ProductSubCardBloc>().add(FetchProductSubCardsEvent());
    context.read<UnitBloc>().add(FetchUnitsEvent());
    context.read<WarehouseBloc>().add(FetchWarehousesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient app bar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Text(
          'Админ: Списание Товара',
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, accentColor], // e.g. #0ABCD7->#6CC6DA
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          // Filter button
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Фильтр',
            onPressed: _openFilterScreen,
          ),
          // Close button
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              widget.onClose?.call();
              Navigator.pop(context);
            },
          ),
        ],
      ),

      // Listen for "write off" success/failure
      body: BlocListener<ProductWriteOffBloc, ProductWriteOffState>(
        listener: (context, state) {
          if (state is ProductWriteOffCreated) {
            // success
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // reset
            setState(() {
              _selectedDate = null;
              _selectedWarehouseId = null;
              _productRows.clear();
              _productRows.add({
                'product_subcard_id': null,
                'quantity': 0.0,
                'unit_measurement': null,
              });
            });
            widget.onClose?.call();
          } else if (state is ProductWriteOffError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Filter summary card
              _buildChosenFilterSummary(),
              const SizedBox(height: 16),

              // The product table
              _buildProductTable(),
              const SizedBox(height: 24),

              // "Списать" button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: _onSave,
                child: const Text('Списать', style: buttonTextStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Filter summary
  // --------------------------------------------------------------------------
  Widget _buildChosenFilterSummary() {
    final dateStr = _selectedDate == null
        ? 'Не выбрана'
        : DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final warehouseStr = _selectedWarehouseId?.toString() ?? 'нет';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: ListTile(
        title: Text(
          'Текущий фильтр:',
          style: bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Склад: $warehouseStr\n'
          'Дата: $dateStr',
          style: bodyTextStyle,
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Open filter page
  // --------------------------------------------------------------------------
  Future<void> _openFilterScreen() async {
    final initialFilter = WriteOffFilterData(
      warehouseId: _selectedWarehouseId,
      selectedDate: _selectedDate,
    );

    final result = await Navigator.push<WriteOffFilterData>(
      context,
      MaterialPageRoute(
        builder: (_) => FilterProductWriteOffPage(initialFilter: initialFilter),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedWarehouseId = result.warehouseId;
        _selectedDate = result.selectedDate;
      });

      // If you need to re-fetch or filter products in your BLoC, do so here
      // e.g. context.read<ProductSubCardBloc>().add(FetchProductSubCardsEvent(...));
    }
  }

  // --------------------------------------------------------------------------
  // Build the product table
  // --------------------------------------------------------------------------
  Widget _buildProductTable() {
    return BlocBuilder<ProductSubCardBloc, ProductSubCardState>(
      builder: (context, subState) {
        if (subState is ProductSubCardLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (subState is ProductSubCardError) {
          return Text('Ошибка: ${subState.message}', style: bodyTextStyle);
        } else if (subState is ProductSubCardsLoaded) {
          final subcards = subState.productSubCards;
          return BlocBuilder<UnitBloc, UnitState>(
            builder: (context, unitState) {
              if (unitState is UnitLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (unitState is UnitFetchedSuccess) {
                final units = unitState.units;
                return _buildProductTableBody(subcards, units);
              }
              return const Text('Ошибка загрузки единиц', style: bodyTextStyle);
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildProductTableBody(List<dynamic> subcards, List<dynamic> units) {
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
            // Table Title Row
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
                    'Таблица Списания',
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
                        tooltip: 'Удалить все строки',
                        onPressed: () {
                          setState(() => _productRows.clear());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        tooltip: 'Добавить строку',
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

            // The table rows
            Column(
              children: List.generate(_productRows.length, (i) {
                final row = _productRows[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      // Product dropdown
                      _tableCell(
                        label: 'Товар',
                        flex: 3,
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

                      // Quantity
                      _tableCell(
                        label: 'Кол-во',
                        flex: 2,
                        child: TextField(
                          style: tableCellStyle,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                          ),
                          onChanged: (val) {
                            final qty = double.tryParse(val) ?? 0.0;
                            setState(() => row['quantity'] = qty);
                          },
                        ),
                      ),

                      // Unit
                      _tableCell(
                        label: 'Ед. изм',
                        flex: 2,
                        child: DropdownButton<String>(
                          value: row['unit_measurement'],
                          isExpanded: true,
                          underline: const SizedBox(),
                          style: tableCellStyle,
                          items: units.map<DropdownMenuItem<String>>((u) {
                            final name = u['name'] ?? 'шт';
                            return DropdownMenuItem<String>(
                              value: name,
                              child: Text(name, style: tableCellStyle),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => row['unit_measurement'] = val);
                          },
                        ),
                      ),

                      // Delete button
                      Container(
                        decoration: BoxDecoration(
                          border: Border(left: tableBorderSide),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() => _productRows.removeAt(i));
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableCell({
    required String label,
    required Widget child,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: tableCellStyle),
            const SizedBox(height: 4),
            child,
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // "Списать" => dispatch event
  // --------------------------------------------------------------------------
  void _onSave() {
    final docDate = _selectedDate == null
        ? DateFormat('yyyy-MM-dd').format(DateTime.now())
        : DateFormat('yyyy-MM-dd').format(_selectedDate!);

    if (_productRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет данных для списания')),
      );
      return;
    }

    final items = _productRows.map((row) {
      return {
        'product_subcard_id': row['product_subcard_id'] ?? 0,
        'quantity': row['quantity'] ?? 0.0,
        'unit_measurement': row['unit_measurement'] ?? 'шт',
      };
    }).toList();

    final payload = {
      'warehouse_id': _selectedWarehouseId ?? 0,
      'document_date': docDate,
      'items': items,
    };

    context.read<ProductWriteOffBloc>().add(
      CreateBulkProductWriteOffEvent(writeOffs: [payload]),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Отправка на сервер...')),
    );
  }
}
