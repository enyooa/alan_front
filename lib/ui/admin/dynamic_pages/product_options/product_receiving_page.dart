import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// BLoCs
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/product_receiving_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/product_subcard_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/warehouse_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/expenses_bloc.dart';

import 'package:alan/bloc/blocs/common_blocs/blocs/provider_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/blocs/unit_bloc.dart';

// States & events
import 'package:alan/bloc/blocs/admin_page_blocs/states/product_receiving_state.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/product_receiving_event.dart';

import 'package:alan/bloc/blocs/admin_page_blocs/states/product_subcard_state.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/product_subcard_event.dart';

import 'package:alan/bloc/blocs/admin_page_blocs/states/warehouse_state.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/warehouse_event.dart';

import 'package:alan/bloc/blocs/admin_page_blocs/states/expenses_state.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/expenses_event.dart';

import 'package:alan/bloc/blocs/common_blocs/states/provider_state.dart';
import 'package:alan/bloc/blocs/common_blocs/events/provider_event.dart';

import 'package:alan/bloc/blocs/common_blocs/states/unit_state.dart';
import 'package:alan/bloc/blocs/common_blocs/events/unit_event.dart';

import 'package:alan/constant.dart';

class ProductReceivingPage extends StatefulWidget {
  final VoidCallback? onClose;

  const ProductReceivingPage({Key? key, this.onClose}) : super(key: key);

  @override
  State<ProductReceivingPage> createState() => _ProductReceivingPageState();
}

class _ProductReceivingPageState extends State<ProductReceivingPage> {
  DateTime? _selectedDate;
  int? _selectedProviderId;
  int? _selectedWarehouseId;

  /// Table of product rows: each row has {product_subcard_id, unit_measurement, quantity, brutto, netto, price, sum, additional_expense, cost_price}
  final List<Map<String, dynamic>> _productRows = [
    {
      'product_subcard_id': null,
      'unit_measurement': null,
      'quantity': 0.0,
      'brutto': 0.0,
      'netto': 0.0,
      'price': 0.0,
      'sum': 0.0,
      'additional_expense': 0.0,
      'cost_price': 0.0,
    },
  ];

  /// Local table for expenses: each row has {expenseId, amount}, referencing the “allExpenses” from ExpenseBloc
  final List<Map<String, dynamic>> _expenseRows = [
    {
      'expenseId': null,
      'amount': 0.0,
    }
  ];

  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Kick off the necessary fetches
    context.read<ProductSubCardBloc>().add(FetchProductSubCardsEvent());
    context.read<UnitBloc>().add(FetchUnitsEvent());
    context.read<ProviderBloc>().add(FetchProvidersEvent());
    context.read<WarehouseBloc>().add(FetchWarehousesEvent());
    context.read<ExpenseBloc>().add(FetchExpensesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Админ: Поступление Товара', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              widget.onClose?.call();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: BlocListener<ProductReceivingBloc, ProductReceivingState>(
        listener: (context, state) {
          if (state is ProductReceivingCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // Clear all form data
            setState(() {
              _productRows.clear();
              _productRows.add({
                'product_subcard_id': null,
                'unit_measurement': null,
                'quantity': 0.0,
                'brutto': 0.0,
                'netto': 0.0,
                'price': 0.0,
                'sum': 0.0,
                'additional_expense': 0.0,
                'cost_price': 0.0,
              });
              _expenseRows.clear();
              _expenseRows.add({'expenseId': null, 'amount': 0.0});

              _selectedDate = null;
              _selectedProviderId = null;
              _selectedWarehouseId = null;
            });
            widget.onClose?.call();
          } else if (state is ProductReceivingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProviderWarehouseDateRow(),
              const SizedBox(height: 16),
              _buildProductTable(),
              const SizedBox(height: 16),
              _buildExpensesTable(),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                onPressed: _onSave,
                child: const Text('Сохранить', style: buttonTextStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Row with provider + warehouse + date
  Widget _buildProviderWarehouseDateRow() {
    return Row(
      children: [
        // Provider
        Expanded(child: _buildProviderDropdown()),
        const SizedBox(width: 8),
        // Warehouse
        Expanded(child: _buildWarehouseDropdown()),
        const SizedBox(width: 8),
        // Date
        Expanded(child: _buildDatePickerCard()),
      ],
    );
  }

  Widget _buildProviderDropdown() {
    return BlocBuilder<ProviderBloc, ProviderState>(
      builder: (context, state) {
        if (state is ProviderLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProvidersLoaded) {
          final items = state.providers.map<DropdownMenuItem<int>>((p) {
            return DropdownMenuItem<int>(
              value: p.id,
              child: Text(p.name, style: bodyTextStyle.copyWith(fontSize: 12)),
            );
          }).toList();

          return _buildStyledDropdown<int>(
            label: 'Поставщик',
            value: _selectedProviderId,
            items: items,
            onChanged: (val) => setState(() => _selectedProviderId = val),
          );
        }
        return const Text('Ошибка провайдеров', style: bodyTextStyle);
      },
    );
  }

  Widget _buildWarehouseDropdown() {
    return BlocBuilder<WarehouseBloc, WarehouseState>(
      builder: (context, whState) {
        if (whState is WarehouseLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (whState is WarehouseError) {
          return Text('Ошибка: ${whState.message}', style: bodyTextStyle);
        } else if (whState is WarehouseLoaded) {
          final items = whState.warehouses.map<DropdownMenuItem<int>>((w) {
            return DropdownMenuItem<int>(
              value: w['id'],
              child: Text(w['name'] ?? 'NoName', style: bodyTextStyle.copyWith(fontSize: 12)),
            );
          }).toList();

          return _buildStyledDropdown<int>(
            label: 'Склад',
            value: _selectedWarehouseId,
            items: items,
            onChanged: (val) => setState(() => _selectedWarehouseId = val),
          );
        }
        return const Text('Загрузка складов...', style: bodyTextStyle);
      },
    );
  }

  Widget _buildDatePickerCard() {
    return GestureDetector(
      onTap: _pickDate,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedDate == null
                  ? 'Дата'
                  : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                style: bodyTextStyle.copyWith(fontSize: 12),
              ),
              const Icon(Icons.calendar_today, color: Colors.grey, size: 16),
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

  /// The storager-like product table
  Widget _buildProductTable() {
    return BlocBuilder<ProductSubCardBloc, ProductSubCardState>(
      builder: (context, subCardState) {
        if (subCardState is ProductSubCardLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (subCardState is ProductSubCardsLoaded) {
          final subcards = subCardState.productSubCards;

          return BlocBuilder<UnitBloc, UnitState>(
            builder: (context, unitState) {
              if (unitState is UnitLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (unitState is UnitFetchedSuccess) {
                final units = unitState.units;

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
                        // Header: title + add row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Таблица товаров', style: subheadingStyle),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text(''),
                              style: elevatedButtonStyle,
                              onPressed: () {
                                setState(() {
                                  _productRows.add({
                                    'product_subcard_id': null,
                                    'unit_measurement': null,
                                    'quantity': 0.0,
                                    'brutto': 0.0,
                                    'netto': 0.0,
                                    'price': 0.0,
                                    'sum': 0.0,
                                    'additional_expense': 0.0,
                                    'cost_price': 0.0,
                                  });
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height:8),

                        Scrollbar(
                          controller: _horizontalScrollController,
                          thumbVisibility:true,
                          trackVisibility:true,
                          child: SingleChildScrollView(
                            scrollDirection:Axis.horizontal,
                            controller:_horizontalScrollController,
                            child: Column(
                              children:[
                                // Table header
                                Container(
                                  color: primaryColor,
                                  child: Row(
                                    children:[
                                      _tableHeaderCell('Товар', width:120),
                                      _tableHeaderCell('Кол-во тары', width:80),
                                      _tableHeaderCell('Ед. изм / Тара', width:110),
                                      _tableHeaderCell('Брутто', width:60),
                                      _tableHeaderCell('Нетто', width:60),
                                      _tableHeaderCell('Цена', width:60),
                                      _tableHeaderCell('Сумма', width:60),
                                      _tableHeaderCell('Доп. расход', width:80),
                                      _tableHeaderCell('Себестоимость', width:80),
                                      _tableHeaderCell('Удалить', width:60),
                                    ],
                                  ),
                                ),

                                // Rows
                                Column(
                                  children: List.generate(_productRows.length, (i) {
                                    final row = _productRows[i];
                                    // We'll recalc in _recalcAll, but also do some basic logic here if needed
                                    final unitObj = units.firstWhere(
                                      (u) => u['name'] == row['unit_measurement'],
                                      orElse:()=>{'tare': 0},
                                    );
                                    double tareKg = ((unitObj['tare']??0)*1.0)/1000.0;
                                    final bruttoVal = row['brutto']??0.0;
                                    final qtyVal = row['quantity']??0.0;
                                    double nettoVal = bruttoVal - (qtyVal * tareKg);
                                    if (nettoVal<0) nettoVal=0;
                                    row['netto'] = nettoVal;
                                    
                                    double sumVal = nettoVal*(row['price']??0.0);
                                    row['sum']=sumVal;

                                    return Row(
                                      children:[
                                        // Product
                                        _tableBodyCell(
                                          width:120,
                                          child: DropdownButton(
                                            value: row['product_subcard_id'],
                                            isExpanded:true,
                                            underline:const SizedBox(),
                                            hint: const Text('Товар', style: tableCellStyle),
                                            style: tableCellStyle,
                                            items: subcards.map<DropdownMenuItem<int>>((sc){
                                              return DropdownMenuItem<int>(
                                                value: sc['id'],
                                                child: Text(sc['name']??'NoName', style: tableCellStyle),
                                              );
                                            }).toList(),
                                            onChanged:(val){
                                              setState(()=> row['product_subcard_id']=val);
                                              _recalcAll();
                                            },
                                          ),
                                        ),
                                        // Qty
                                        _tableBodyCell(
                                          width:80,
                                          child: TextField(
                                            style:tableCellStyle,
                                            keyboardType:TextInputType.number,
                                            decoration: const InputDecoration(
                                              border:InputBorder.none,
                                              hintText:'0',
                                            ),
                                            onChanged:(val){
                                              setState(()=> row['quantity']=double.tryParse(val)??0.0);
                                              _recalcAll();
                                            },
                                          ),
                                        ),
                                        // Unit
                                        _tableBodyCell(
                                          width:110,
                                          child: DropdownButton(
                                            value: row['unit_measurement'],
                                            isExpanded:true,
                                            underline:const SizedBox(),
                                            hint: const Text('ед.', style: tableCellStyle),
                                            style: tableCellStyle,
                                            items: units.map<DropdownMenuItem<String>>((u){
                                              return DropdownMenuItem<String>(
                                                value: u['name'],
                                                child: Text('${u['name']} (${u['tare']}г)', style: tableCellStyle),
                                              );
                                            }).toList(),
                                            onChanged:(val){
                                              setState(()=> row['unit_measurement']=val);
                                              _recalcAll();
                                            },
                                          ),
                                        ),
                                        // brutto
                                        _tableBodyCell(
                                          width:60,
                                          child: TextField(
                                            style:tableCellStyle,
                                            keyboardType:TextInputType.number,
                                            decoration:const InputDecoration(
                                              border:InputBorder.none,
                                              hintText:'0.0',
                                            ),
                                            onChanged:(val){
                                              setState(()=> row['brutto'] = double.tryParse(val)??0.0);
                                              _recalcAll();
                                            },
                                          ),
                                        ),
                                        // netto
                                        _tableBodyCell(
                                          width:60,
                                          child: Text(
                                            row['netto'].toStringAsFixed(2),
                                            style:tableCellStyle,
                                          ),
                                        ),
                                        // price
                                        _tableBodyCell(
                                          width:60,
                                          child: TextField(
                                            style:tableCellStyle,
                                            keyboardType:TextInputType.number,
                                            decoration: const InputDecoration(
                                              border:InputBorder.none,
                                              hintText:'0.0',
                                            ),
                                            onChanged:(val){
                                              setState(()=>row['price'] = double.tryParse(val)??0.0);
                                              _recalcAll();
                                            },
                                          ),
                                        ),
                                        // sum
                                        _tableBodyCell(
                                          width:60,
                                          child: Text(
                                            row['sum'].toStringAsFixed(2),
                                            style: tableCellStyle,
                                          ),
                                        ),
                                        // additional_expense
                                        _tableBodyCell(
                                          width:80,
                                          child: Text(
                                            (row['additional_expense']??0.0).toStringAsFixed(2),
                                            style: tableCellStyle,
                                          ),
                                        ),
                                        // cost_price
                                        _tableBodyCell(
                                          width:80,
                                          child: Text(
                                            (row['cost_price']??0.0).toStringAsFixed(2),
                                            style: tableCellStyle,
                                          ),
                                        ),
                                        // delete button
                                        _tableBodyCell(
                                          width:60,
                                          child: IconButton(
                                            icon: const Icon(Icons.delete, color:Colors.red),
                                            onPressed: (){
                                              setState(()=> _productRows.removeAt(i));
                                              _recalcAll();
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
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const Text('Ошибка при загрузке единиц', style: bodyTextStyle);
            },
          );
        }
        return const Text('Ошибка при загрузке карточек товаров', style: bodyTextStyle);
      },
    );
  }

  /// The storager-like expenses table
  Widget _buildExpensesTable() {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        if (state is ExpenseLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ExpenseError) {
          return Text('Ошибка расходов: ${state.message}', style: bodyTextStyle);
        } else if (state is ExpenseLoaded) {
          // allExpenses = [{'name':'Расход','amount':5000}, ...]
          final allExpenses = state.expenses;

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
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Доп. расходы', style: subheadingStyle),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text(''),
                        style: elevatedButtonStyle,
                        onPressed: (){
                          setState(() {
                            _expenseRows.add({'expenseId': null, 'amount':0.0});
                          });
                          _recalcAll();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height:8),

                  // Table Header
                  Container(
                    color: primaryColor,
                    child: Row(
                      children:[
                        _tableHeaderCell('Наименование', width:120),
                        _tableHeaderCell('Сумма', width:80),
                        _tableHeaderCell('Удалить', width:60),
                      ],
                    ),
                  ),
                  // Rows
                  Column(
                    children: List.generate(_expenseRows.length, (i){
                      final row = _expenseRows[i];
                      return Row(
                        children:[
                          // expense name
                          _tableBodyCell(
                            width:120,
                            child: DropdownButton(
                              value: row['expenseId'],
                              isExpanded:true,
                              underline:const SizedBox(),
                              hint: const Text('Выберите', style:tableCellStyle),
                              style: tableCellStyle,
                              items: allExpenses.map<DropdownMenuItem>((ex){
                                // if ex has no 'id', you might store ex['name'] as the ID
                                return DropdownMenuItem(
                                  value: ex['name'],
                                  child: Text(ex['name']??'NoName', style:tableCellStyle),
                                );
                              }).toList(),
                              onChanged:(val){
                                setState(()=> row['expenseId']=val);
                                _recalcAll();
                              },
                            ),
                          ),
                          // amount
                          _tableBodyCell(
                            width:80,
                            child: TextField(
                              style:tableCellStyle,
                              keyboardType:TextInputType.number,
                              decoration: const InputDecoration(
                                border:InputBorder.none,
                                hintText:'0.0',
                              ),
                              onChanged:(val){
                                row['amount'] = double.tryParse(val)??0.0;
                                _recalcAll();
                              },
                            ),
                          ),
                          // delete
                          _tableBodyCell(
                            width:60,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color:Colors.red),
                              onPressed: (){
                                setState(()=>_expenseRows.removeAt(i));
                                _recalcAll();
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
        return const SizedBox();
      },
    );
  }

  /// Called after any user input change. We replicate storager logic:
  /// 1) Sum all additional expense (from _expenseRows) -> totalExp
  /// 2) Sum all product row quantities
  /// 3) For each product row: 
  ///    - recalc netto = brutto - (tareKg * quantity)
  ///    - sum = netto * price
  ///    - additional_expense = proportion of totalExp
  ///    - cost_price = (row sum + row addExp) / quantity
  
  void _recalcAll() {
    // 1) totalExp
    double totalExp = 0.0;
    for (final er in _expenseRows) {
      totalExp += er['amount']??0.0;
    }
    // 2) totalQty
    double totalQty=0.0;
    for (final row in _productRows) {
      totalQty += (row['quantity']??0.0);
    }

    // We'll need access to the unit tare for each row again, so let's do that after we read the UnitBloc state, or store them in the row directly
    // For now, we do a 2-pass approach: if you need to fetch from a local 'units' array, do so. For a simpler approach, we'll do "tare" from the row or keep re-locating the unit.

    // We'll have to do a setState at the end
    // Let's read the UnitBloc for the tare data:
    final unitState = context.read<UnitBloc>().state;
    List<dynamic> units = [];
    if (unitState is UnitFetchedSuccess) {
      units = unitState.units;
    }

    // 3) for each product row, recalc
    for (final row in _productRows) {
      // find the unit
      final unitName = row['unit_measurement'];
      final foundUnit = units.firstWhere(
        (u) => u['name'] == unitName,
        orElse: () => {'tare':0},
      );

      double tareGrams = (foundUnit['tare']??0)*1.0;
      double tareKg = tareGrams/1000.0;

      double brutto = row['brutto']??0.0;
      double qty = row['quantity']??0.0;
      double nett = brutto - (qty*tareKg);
      if (nett<0) nett=0;
      row['netto']=nett;

      double price = row['price']??0.0;
      double rowSum = nett*price;
      row['sum']=rowSum;

      double rowAdd=0.0;
      if (totalQty>0 && qty>0) {
        rowAdd = (qty/totalQty)*totalExp;
      }
      row['additional_expense']=rowAdd;

      double costP=0.0;
      if (qty>0) {
        costP = (rowSum + rowAdd)/qty;
      }
      row['cost_price']=costP;
    }

    setState(() {});
  }

  /// On Save -> build payload
  void _onSave() {
    // 1) Build final products from _productRows
    // 2) Build final expenses from _expenseRows
    // 3) Merge with date, provider, warehouse
    // 4) Dispatch CreateBulkProductReceivingEvent

    // sum the local expense rows to distribute among products? Already done in _recalcAll, so each row has 'additional_expense'.

    final docDate = _selectedDate==null
      ? DateFormat('yyyy-MM-dd').format(DateTime.now())
      : DateFormat('yyyy-MM-dd').format(_selectedDate!);

    final productList = _productRows.map((row){
      return {
        'product_subcard_id': row['product_subcard_id'] ?? 0,
        'unit_measurement': row['unit_measurement'] ?? 'шт',
        'quantity': row['quantity'] ?? 0.0,
        'brutto': row['brutto'] ?? 0.0,
        'netto': row['netto'] ?? 0.0,
        'price': row['price'] ?? 0.0,
        'total_sum': row['sum'] ?? 0.0,
        'cost_price': row['cost_price'] ?? 0.0,
        'additional_expenses': row['additional_expense']??0.0,
      };
    }).toList();

    final expenseList = _expenseRows.map((er){
      // We'll treat "expenseId" as a "name" or "id" from the server
      return {
        'name': er['expenseId']??'NoName',
        'amount': er['amount']??0.0,
      };
    }).toList();

    final payload = {
      'provider_id': _selectedProviderId??0,
      'warehouse_id': _selectedWarehouseId??0,
      'document_date': docDate,
      'products': productList,
      'expenses': expenseList,
    };

    // If no data, show a message
    if (productList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет данных для отправки')),
      );
      return;
    }

    context.read<ProductReceivingBloc>().add(
      CreateBulkProductReceivingEvent(receivings: [payload]),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Отправка данных...')),
    );
  }

  // Reusable table header cell
  Widget _tableHeaderCell(String label, {double width=100}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical:8),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        border: Border(right: tableBorderSide),
      ),
      child: Text(label, style: tableHeaderStyle),
    );
  }

  // Reusable table body cell
  Widget _tableBodyCell({required Widget child, double width=100}) {
    return Container(
      width:width,
      padding: const EdgeInsets.symmetric(vertical:6),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        border: Border(
          right: tableBorderSide,
          bottom: tableBorderSide,
        ),
      ),
      child: child,
    );
  }

  // Reusable styled dropdown
  Widget _buildStyledDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal:12.0, vertical:6.0),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            isExpanded:true,
            value:value,
            items:items,
            onChanged:onChanged,
            hint: Text(label, style: bodyTextStyle.copyWith(fontSize:12)),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
