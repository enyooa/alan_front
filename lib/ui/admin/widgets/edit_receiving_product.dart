import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Admin BLoC for “Приход” docs
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/product_receiving_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/product_receiving_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/product_receiving_state.dart';

// Your constants / styles
import 'package:alan/constant.dart';

class EditReceiptDialog extends StatefulWidget {
  final int docId;
  const EditReceiptDialog({Key? key, required this.docId}) : super(key: key);

  @override
  State<EditReceiptDialog> createState() => _EditReceiptDialogState();
}

class _EditReceiptDialogState extends State<EditReceiptDialog> {
  // Header fields
  int? _providerId;
  String _documentDate = '';
  int? _warehouseId;

  // The product rows & expenses
  List<Map<String, dynamic>> _productRows = [];
  List<Map<String, dynamic>> _expenseRows = [];

  // The references from the BLoC
  List<dynamic> _providers = [];
  List<dynamic> _warehouses = [];
  List<dynamic> _products = [];
  List<dynamic> _units = [];
  List<dynamic> _allExpenses = [];

  // UI state
  bool _isSubmitting = false;
  String _feedbackMessage = '';

  @override
  void initState() {
    super.initState();
    // Dispatch event to fetch single doc + references
    context.read<ProductReceivingBloc>().add(
      FetchSingleProductReceivingEvent(widget.docId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: BlocConsumer<ProductReceivingBloc, ProductReceivingState>(
        listener: (ctx, state) {
          // While loading...
          if (state is ProductReceivingLoading && _productRows.isEmpty) {
            setState(() => _isSubmitting = true);
          }
          // Doc loaded successfully
          if (state is ProductReceivingSingleLoaded) {
            setState(() {
              _isSubmitting = false;
              _initializeFromState(state);
            });
          }
          // Updated
          if (state is ProductReceivingUpdated) {
            setState(() {
              _isSubmitting = false;
              _feedbackMessage = state.message;
            });
            // Close after short delay
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.of(context).pop();
            });
          }
          // Error
          if (state is ProductReceivingError) {
            setState(() {
              _isSubmitting = false;
              _feedbackMessage = state.message;
            });
          }
        },
        builder: (ctx, state) {
          // If we have no local data & it's still loading => spinner
          if (state is ProductReceivingLoading && _productRows.isEmpty) {
            return const SizedBox(
              width: 400,
              height: 400,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          // Otherwise show the form-based UI
          return Scaffold(
            appBar: AppBar(
              backgroundColor: primaryColor,
              title: Text(
                'Редактировать Приход (ID: ${widget.docId})',
                style: headingStyle,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: pagePadding,
              child: Column(
                children: [
                  _buildHeaderSection(),
                  const SizedBox(height: 16),
                  _buildItemsSection(),
                  const SizedBox(height: 16),
                  _buildExpensesSection(),
                ],
              ),
            ),
            bottomNavigationBar: _buildFooter(),
          );
        },
      ),
    );
  }

  // ----------------------------------------------------------------
  //  PART A: HEADER (Provider, Date, Warehouse)
  // ----------------------------------------------------------------
  Widget _buildHeaderSection() {
    return Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: elementPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Основная информация', style: subheadingStyle),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                // Provider
                SizedBox(
                  width: 250,
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Поставщик',
                      labelStyle: formLabelStyle,
                      border: OutlineInputBorder(),
                    ),
                    value: _providerId,
                    items: _providers.map<DropdownMenuItem<int>>((p) {
                      return DropdownMenuItem<int>(
                        value: p['id'],
                        child: Text(p['name'] ?? 'NoName', style: bodyTextStyle),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _providerId = val),
                  ),
                ),
                // Date
                SizedBox(
                  width: 180,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Дата',
                      labelStyle: formLabelStyle,
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(text: _documentDate),
                    onChanged: (val) => _documentDate = val,
                  ),
                ),
                // Warehouse
                SizedBox(
                  width: 250,
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Склад',
                      labelStyle: formLabelStyle,
                      border: OutlineInputBorder(),
                    ),
                    value: _warehouseId,
                    items: _warehouses.map<DropdownMenuItem<int>>((wh) {
                      return DropdownMenuItem<int>(
                        value: wh['id'],
                        child: Text(wh['name'] ?? 'NoName', style: bodyTextStyle),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _warehouseId = val),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  //  PART B: PRODUCT ITEMS
  // ----------------------------------------------------------------
  Widget _buildItemsSection() {
    return Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: elementPadding,
        child: Column(
          children: [
            Row(
              children: [
                Text('Товары (items)', style: subheadingStyle),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  onPressed: _addProductRow,
                  child: const Text('➕ Добавить', style: buttonTextStyle),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(primaryColor),
                  columns: const [
                    DataColumn(label: Text('Товар', style: tableHeaderStyle)),
                    DataColumn(label: Text('Кол-во', style: tableHeaderStyle)),
                    DataColumn(label: Text('Ед. изм', style: tableHeaderStyle)),
                    DataColumn(label: Text('Брутто', style: tableHeaderStyle)),
                    DataColumn(label: Text('Нетто', style: tableHeaderStyle)),
                    DataColumn(label: Text('Цена', style: tableHeaderStyle)),
                    DataColumn(label: Text('Сумма', style: tableHeaderStyle)),
                    DataColumn(label: Text('Доп. расход', style: tableHeaderStyle)),
                    DataColumn(label: Text('Себестоим.', style: tableHeaderStyle)),
                    DataColumn(label: Text('Удалить', style: tableHeaderStyle)),
                  ],
                  rows: List.generate(_productRows.length, (index) {
                    final row = _productRows[index];
                    final nettVal = _calcNetto(row);
                    final sumVal = _calcTotal(row);
                    final addExp = _calcAdditionalExpense(row);
                    final costPr = _calcCostPrice(row);

                    return DataRow(
                      cells: [
                        // Product
                        DataCell(
                          DropdownButton<int>(
                            value: row['selectedProductIndex'] as int?,
                            hint: const Text('— товар —'),
                            items: List.generate(_products.length, (pIndex) {
                              final product = _products[pIndex];
                              return DropdownMenuItem<int>(
                                value: pIndex,
                                child: Text(
                                  product['name']?.toString() ?? 'NoName',
                                  style: bodyTextStyle,
                                ),
                              );
                            }),
                            onChanged: (val) {
                              setState(() {
                                row['selectedProductIndex'] = val;
                                row['product_subcard_id'] = _products[val!]['id'];
                              });
                            },
                          ),
                        ),
                        // qty
                        DataCell(
                          SizedBox(
                            width: 70,
                            child: TextFormField(
                              style: bodyTextStyle,
                              initialValue: row['quantity'].toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(border: OutlineInputBorder()),
                              onChanged: (val) {
                                setState(() => row['quantity'] = _parseNumber(val));
                              },
                            ),
                          ),
                        ),
                        // unit
                        DataCell(
                          DropdownButton<int>(
                            value: row['selectedUnitIndex'] as int?,
                            hint: const Text('— ед.изм —'),
                            items: List.generate(_units.length, (uIndex) {
                              final unit = _units[uIndex];
                              return DropdownMenuItem<int>(
                                value: uIndex,
                                child: Text(
                                  '${unit['name']} (${unit['tare']}г)',
                                  style: bodyTextStyle,
                                ),
                              );
                            }),
                            onChanged: (val) {
                              setState(() {
                                row['selectedUnitIndex'] = val;
                                row['unit_measurement'] = _units[val!]['name'];
                              });
                            },
                          ),
                        ),
                        // brutto
                        DataCell(
                          SizedBox(
                            width: 70,
                            child: TextFormField(
                              style: bodyTextStyle,
                              initialValue: row['brutto'].toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(border: OutlineInputBorder()),
                              onChanged: (val) {
                                setState(() => row['brutto'] = _parseNumber(val));
                              },
                            ),
                          ),
                        ),
                        // netto (computed)
                        DataCell(Text(nettVal.toStringAsFixed(2), style: bodyTextStyle)),
                        // price
                        DataCell(
                          SizedBox(
                            width: 70,
                            child: TextFormField(
                              style: bodyTextStyle,
                              initialValue: row['price'].toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(border: OutlineInputBorder()),
                              onChanged: (val) {
                                setState(() => row['price'] = _parseNumber(val));
                              },
                            ),
                          ),
                        ),
                        // sum
                        DataCell(Text(sumVal.toStringAsFixed(2), style: bodyTextStyle)),
                        // additional
                        DataCell(Text(addExp.toStringAsFixed(2), style: bodyTextStyle)),
                        // cost price
                        DataCell(Text(costPr.toStringAsFixed(2), style: bodyTextStyle)),
                        // remove
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete, color: errorColor),
                            onPressed: () => setState(() => _productRows.removeAt(index)),
                          ),
                        ),
                      ],
                    );
                  })
                    ..add(
                      // summary row
                      DataRow(
                        cells: [
                          const DataCell(SizedBox()),
                          const DataCell(SizedBox()),
                          const DataCell(SizedBox()),
                          const DataCell(SizedBox()),
                          DataCell(Text(_totalNetto.toStringAsFixed(2), style: bodyTextStyle)),
                          const DataCell(Text('-')),
                          DataCell(Text(_totalSum.toStringAsFixed(2), style: bodyTextStyle)),
                          DataCell(Text(_totalExp.toStringAsFixed(2), style: bodyTextStyle)),
                          const DataCell(Text('-')),
                          const DataCell(SizedBox()),
                        ],
                      ),
                    ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  //  PART C: EXPENSES
  // ----------------------------------------------------------------
  Widget _buildExpensesSection() {
    return Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: elementPadding,
        child: Column(
          children: [
            Row(
              children: [
                Text('Доп. Расходы', style: subheadingStyle),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  onPressed: _addExpenseRow,
                  child: const Text('➕ Добавить', style: buttonTextStyle),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(primaryColor),
                columns: const [
                  DataColumn(label: Text('Название', style: tableHeaderStyle)),
                  DataColumn(label: Text('Сумма', style: tableHeaderStyle)),
                  DataColumn(label: Text('Удалить', style: tableHeaderStyle)),
                ],
                rows: List.generate(_expenseRows.length, (idx) {
                  final er = _expenseRows[idx];
                  return DataRow(
                    cells: [
                      // expense name
                      DataCell(
                        DropdownButton<int>(
                          value: er['selectedIndex'] as int?,
                          hint: const Text('— расход —'),
                          items: List.generate(_allExpenses.length, (eIndex) {
                            final eObj = _allExpenses[eIndex];
                            return DropdownMenuItem<int>(
                              value: eIndex,
                              child: Text(
                                eObj['name']?.toString() ?? '???',
                                style: bodyTextStyle,
                              ),
                            );
                          }),
                          onChanged: (val) {
                            setState(() {
                              er['selectedIndex'] = val;
                              er['selectedExpenseId'] = _allExpenses[val!]['id'];
                              er['name'] = _allExpenses[val]['name'];
                            });
                          },
                        ),
                      ),
                      // amount
                      DataCell(
                        SizedBox(
                          width: 70,
                          child: TextFormField(
                            style: bodyTextStyle,
                            initialValue: er['amount'].toString(),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(border: OutlineInputBorder()),
                            onChanged: (val) => setState(() => er['amount'] = _parseNumber(val)),
                          ),
                        ),
                      ),
                      // remove
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.delete, color: errorColor),
                          onPressed: () => setState(() => _expenseRows.removeAt(idx)),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  //  PART D: Footer: “Save” & “Cancel”
  // ----------------------------------------------------------------
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 60,
      child: Row(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: _isSubmitting ? null : _onSave,
            child: Text(_isSubmitting ? 'Сохранение...' : 'Сохранить', style: buttonTextStyle),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: unselectednavbar),
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена', style: buttonTextStyle),
          ),
          const Spacer(),
          if (_feedbackMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(4)),
              child: Text(_feedbackMessage, style: buttonTextStyle),
            ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------
  //  PART E: Initialize from state
  // ----------------------------------------------------------------
  void _initializeFromState(ProductReceivingSingleLoaded loaded) {
    // references
    _providers = loaded.providers;
    _warehouses = loaded.warehouses;
    _products = loaded.productSubCards;
    _units = loaded.unitMeasurements;
    _allExpenses = loaded.expenses;

    final doc = loaded.document;
    _providerId = doc['provider_id'] as int?;
    if (doc['document_date'] != null && doc['document_date'].length >= 10) {
      _documentDate = doc['document_date'].substring(0, 10);
    }
    _warehouseId = doc['to_warehouse_id'] as int?;

    // Build productRows from doc['document_items']
    final items = doc['document_items'] as List<dynamic>? ?? [];
    _productRows = items.map<Map<String, dynamic>>((itm) {
      final row = {
        '_key': itm['id'],
        'id': itm['id'],
        'product_subcard_id': itm['product_subcard_id'],
        'quantity': (itm['quantity'] ?? 0).toDouble(),
        'brutto': (itm['brutto'] ?? 0).toDouble(),
        'unit_measurement': itm['unit_measurement'] ?? '',
        'price': (itm['price'] ?? 0).toDouble(),
        'additional_expenses': (itm['additional_expenses'] ?? 0).toDouble(),
      };
      // figure out product index
      if (row['product_subcard_id'] != null) {
        final pIndex = _products.indexWhere((p) => p['id'] == row['product_subcard_id']);
        if (pIndex != -1) {
          row['selectedProductIndex'] = pIndex;
        }
      }
      // figure out unit index
      final uName = row['unit_measurement'] as String;
      if (uName.isNotEmpty) {
        final uIndex = _units.indexWhere((u) => u['name'] == uName);
        if (uIndex != -1) {
          row['selectedUnitIndex'] = uIndex;
        }
      }
      return row;
    }).toList();

    // Build expenseRows from doc['expenses']
    final exps = doc['expenses'] as List<dynamic>? ?? [];
    _expenseRows = exps.map<Map<String, dynamic>>((ex) {
      final eRow = {
        '_key': ex['id'],
        'id': ex['id'],
        'selectedExpenseId': ex['expense_id'] ?? ex['id'],
        'name': ex['name'] ?? '',
        'amount': (ex['amount'] ?? 0).toDouble(),
      };
      final eIndex = _allExpenses.indexWhere((x) => x['id'] == eRow['selectedExpenseId']);
      if (eIndex != -1) {
        eRow['selectedIndex'] = eIndex;
      }
      return eRow;
    }).toList();
  }

  // ----------------------------------------------------------------
  //  PART F: On Save => Update
  // ----------------------------------------------------------------
  void _onSave() {
    setState(() {
      _isSubmitting = true;
      _feedbackMessage = '';
    });

    // 1) Build "products" array
    final productsPayload = _productRows.map((row) {
      return {
        'id': row['id'],
        'product_subcard_id': row['product_subcard_id'],
        'quantity': row['quantity'],
        'brutto': row['brutto'],
        'netto': _calcNetto(row),
        'unit_measurement': row['unit_measurement'],
        'price': row['price'],
        'total_sum': _calcTotal(row),
        'additional_expenses': _calcAdditionalExpense(row),
        'cost_price': _calcCostPrice(row),
      };
    }).toList();

    // 2) Build "expenses" array
    final expensePayload = _expenseRows.map((ex) {
      return {
        'id': ex['id'],
        'expense_id': ex['selectedExpenseId'],
        'name': ex['name'],
        'amount': ex['amount'],
      };
    }).toList();

    // 3) Combined
    final payload = {
      'provider_id': _providerId,
      'document_date': _documentDate,
      'assigned_warehouse_id': _warehouseId,
      'products': productsPayload,
      'expenses': expensePayload,
    };

    // 4) Dispatch => UpdateProductReceivingEvent
    context.read<ProductReceivingBloc>().add(
      UpdateProductReceivingEvent(docId: widget.docId, updatedData: payload),
    );
  }

  // ----------------------------------------------------------------
  //  PART G: Calculations
  // ----------------------------------------------------------------
  double _parseNumber(dynamic val) {
    if (val == null) return 0.0;
    if (val is String) {
      return double.tryParse(val) ?? 0.0;
    }
    if (val is num) {
      return val.toDouble();
    }
    return 0.0;
  }

  double _calcNetto(Map<String, dynamic> row) {
    final chosenUnit = row['unit_measurement'] ?? '';
    final foundUnit = _units.firstWhere(
      (u) => u['name'] == chosenUnit,
      orElse: () => {'tare': 0},
    );
    final tareGram = _parseNumber(foundUnit['tare']);
    final tareKg = tareGram / 1000.0;

    final brutto = _parseNumber(row['brutto']);
    final qty = _parseNumber(row['quantity']);
    double netto = brutto - (qty * tareKg);
    return netto < 0 ? 0 : netto;
  }

  double _calcTotal(Map<String, dynamic> row) {
    return _calcNetto(row) * _parseNumber(row['price']);
  }

  double get _totalNetto {
    double sum = 0;
    for (var r in _productRows) {
      sum += _calcNetto(r);
    }
    return sum;
  }

  double get _totalSum {
    double sum = 0;
    for (var r in _productRows) {
      sum += _calcTotal(r);
    }
    return sum;
  }

  double get _totalExp {
    double ex = 0;
    for (var e in _expenseRows) {
      ex += _parseNumber(e['amount']);
    }
    return ex;
  }

  double _calcAdditionalExpense(Map<String, dynamic> row) {
    final totalQty = _productRows.fold<double>(0, (acc, r) => acc + _parseNumber(r['quantity']));
    if (totalQty == 0) return 0.0;
    final itemQty = _parseNumber(row['quantity']);
    return (_totalExp / totalQty) * itemQty;
  }

  double _calcCostPrice(Map<String, dynamic> row) {
    final sumVal = _calcTotal(row);
    final addExp = _calcAdditionalExpense(row);
    final qty = _parseNumber(row['quantity']);
    if (qty <= 0) return 0.0;
    return (sumVal + addExp) / qty;
  }

  // Row additions
  void _addProductRow() {
    setState(() {
      _productRows.add({
        '_key': DateTime.now().millisecondsSinceEpoch,
        'id': null,
        'product_subcard_id': null,
        'selectedProductIndex': null,
        'quantity': 0.0,
        'brutto': 0.0,
        'unit_measurement': null,
        'selectedUnitIndex': null,
        'price': 0.0,
      });
    });
  }

  void _addExpenseRow() {
    setState(() {
      _expenseRows.add({
        '_key': DateTime.now().millisecondsSinceEpoch,
        'id': null,
        'selectedExpenseId': null,
        'selectedIndex': null,
        'name': '',
        'amount': 0.0,
      });
    });
  }
}
