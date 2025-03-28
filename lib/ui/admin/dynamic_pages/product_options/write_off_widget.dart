import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// BLoCs & Events/States
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

// Styles / constants
import 'package:alan/constant.dart';

/// A simple page to do a "write-off" from a warehouse
/// with only product, quantity, unit, no brutto/netto/price/expenses.
class ProductWriteOffPage extends StatefulWidget {
  final VoidCallback? onClose;

  const ProductWriteOffPage({Key? key, this.onClose}) : super(key: key);

  @override
  State<ProductWriteOffPage> createState() => _ProductWriteOffPageState();
}

class _ProductWriteOffPageState extends State<ProductWriteOffPage> {
  DateTime? _selectedDate;
  int? _selectedWarehouseId;

  /// Just product, quantity, unit
  final List<Map<String, dynamic>> _productRows = [
    {
      'product_subcard_id': null,
      'quantity': 0.0,
      'unit_measurement': null,
    }
  ];

  @override
  void initState() {
    super.initState();
    // Fetch needed references
    context.read<ProductSubCardBloc>().add(FetchProductSubCardsEvent());
    context.read<WarehouseBloc>().add(FetchWarehousesEvent());
    context.read<UnitBloc>().add(FetchUnitsEvent());
    // No ExpenseBloc if we don't handle expenses
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Списание со склада', style: headingStyle),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              // Let child handle the pop
              widget.onClose?.call(); 
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: BlocListener<ProductWriteOffBloc, ProductWriteOffState>(
        listener: (context, state) {
          if (state is ProductWriteOffCreated) {
            // success
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // reset form
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
          padding: pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWarehouseDateRow(),
              const SizedBox(height: 16),
              _buildProductTable(),
              const SizedBox(height: 24),
              ElevatedButton(
                style: elevatedButtonStyle,
                onPressed: _onSave,
                child: const Text('Списать', style: buttonTextStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarehouseDateRow() {
    return Row(
      children: [
        Expanded(child: _buildWarehouseDropdown()),
        const SizedBox(width: 12),
        Expanded(child: _buildDatePicker()),
      ],
    );
  }

  Widget _buildWarehouseDropdown() {
    return BlocBuilder<WarehouseBloc, WarehouseState>(
      builder: (context, state) {
        if (state is WarehouseLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is WarehouseError) {
          return Text('Ошибка склада: ${state.message}', style: bodyTextStyle);
        } else if (state is WarehouseLoaded) {
          final items = state.warehouses.map<DropdownMenuItem<int>>((wh) {
            return DropdownMenuItem<int>(
              value: wh['id'],
              child: Text(wh['name'] ?? 'NoName', style: bodyTextStyle),
            );
          }).toList();

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal:8, vertical:6),
              child: DropdownButtonFormField<int>(
                value: _selectedWarehouseId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Склад (откуда списываем)',
                  labelStyle: formLabelStyle,
                  border: InputBorder.none,
                ),
                style: bodyTextStyle,
                items: items,
                onChanged: (val) => setState(() => _selectedWarehouseId = val),
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal:8, vertical:10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedDate == null
                  ? 'Дата'
                  : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                style: bodyTextStyle,
              ),
              const Icon(Icons.calendar_today, color:Colors.grey, size:16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Widget _buildProductTable() {
    // We only need a product subcard list & units
    return BlocBuilder<ProductSubCardBloc, ProductSubCardState>(
      builder: (context, subState) {
        if (subState is ProductSubCardLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (subState is ProductSubCardError) {
          return Text('Ошибка товаров: ${subState.message}', style: bodyTextStyle);
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
              return const Text('Ошибка единиц', style: bodyTextStyle);
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
        side: const BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: elementPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row + add button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Товары для Списания', style: subheadingStyle),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text(''),
                  style: elevatedButtonStyle,
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
            const SizedBox(height:8),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(primaryColor),
                columns: const [
                  DataColumn(label: Text('Товар', style: tableHeaderStyle)),
                  DataColumn(label: Text('Кол-во', style: tableHeaderStyle)),
                  DataColumn(label: Text('Ед. изм', style: tableHeaderStyle)),
                  DataColumn(label: Text('Удалить', style: tableHeaderStyle)),
                ],
                rows: List.generate(_productRows.length, (i) {
                  final row = _productRows[i];
                  return DataRow(cells: [
                    // Product subcard
                    DataCell(
                      DropdownButton<int>(
                        value: row['product_subcard_id'],
                        underline: const SizedBox(),
                        isExpanded:true,
                        style: tableCellStyle,
                        items: subcards.map<DropdownMenuItem<int>>((sc){
                          return DropdownMenuItem<int>(
                            value: sc['id'],
                            child: Text(sc['name']??'NoName', style:tableCellStyle),
                          );
                        }).toList(),
                        onChanged:(val){
                          setState(()=>row['product_subcard_id']=val);
                        },
                      ),
                    ),

                    // quantity
                    DataCell(SizedBox(
                      width:60,
                      child: TextField(
                        style:tableCellStyle,
                        keyboardType:TextInputType.number,
                        decoration:const InputDecoration(
                          border:InputBorder.none,
                          hintText:'0',
                        ),
                        onChanged:(val){
                          setState(()=> row['quantity'] = double.tryParse(val)??0.0);
                        },
                      ),
                    )),

                    // unit_measurement
                    DataCell(
                      DropdownButton<String>(
                        value: row['unit_measurement'],
                        underline: const SizedBox(),
                        isExpanded:true,
                        style: tableCellStyle,
                        items: units.map<DropdownMenuItem<String>>((u){
                          return DropdownMenuItem<String>(
                            value: u['name'],
                            child: Text(u['name'], style:tableCellStyle),
                          );
                        }).toList(),
                        onChanged:(val){
                          setState(()=> row['unit_measurement'] = val);
                        },
                      ),
                    ),

                    // Delete row
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete, color:Colors.red),
                        onPressed:(){
                          setState(()=>_productRows.removeAt(i));
                        },
                      ),
                    ),
                  ]);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Called on pressing “Списать”
  void _onSave() {
    // If no date => use today
    final docDate = _selectedDate==null 
      ? DateFormat('yyyy-MM-dd').format(DateTime.now())
      : DateFormat('yyyy-MM-dd').format(_selectedDate!);

    final products = _productRows.map((row){
      return {
        'product_subcard_id': row['product_subcard_id'] ?? 0,
        'quantity': row['quantity'] ?? 0.0,
        'unit_measurement': row['unit_measurement'] ?? 'шт',
      };
    }).toList();

    final payload = {
      'warehouse_id': _selectedWarehouseId ?? 0,
      'document_date': docDate,
      'items': products,
      // you might pass 'comments' if needed
    };

    // Dispatch event
    context.read<ProductWriteOffBloc>().add(
      CreateBulkProductWriteOffEvent(writeOffs: [payload]),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Отправка на сервер...')),
    );
  }
}
