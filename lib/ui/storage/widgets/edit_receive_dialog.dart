import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/blocs/storage_receiving_bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/events/storage_receiving_event.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/storage_receiving_state.dart';
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

  // Document items and expenses as List<Map>
  List<Map<String, dynamic>> _productRows = [];
  List<Map<String, dynamic>> _expenses = [];

  // References (loaded from the BLoC state)
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
    // Request the document and references for a single doc
    context.read<StorageReceivingBloc>().add(
      FetchSingleReceiptEvent(docId: widget.docId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // Give some padding so it's not full screen on large displays
      insetPadding: const EdgeInsets.all(16.0),
      child: BlocConsumer<StorageReceivingBloc, StorageReceivingState>(
        listener: (context, state) {
          if (state is StorageReceivingLoading) {
            setState(() => _isSubmitting = true);
          }
          if (state is StorageReceivingSingleLoaded) {
            // We have the doc + references => let user press "Сохранить"
            setState(() => _isSubmitting = false);
            _initializeFromState(state);
          }
          if (state is StorageReceivingUpdated) {
            setState(() {
              _isSubmitting = false;
              _feedbackMessage = state.message;
            });
            // Close the dialog after a short delay
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.of(context).pop();
            });
          }
          if (state is StorageReceivingError) {
            setState(() {
              _isSubmitting = false;
              _feedbackMessage = state.message;
            });
          }
        },
        builder: (context, state) {
          // If we haven't loaded anything yet, show a spinner
          if (state is StorageReceivingLoading && _productRows.isEmpty) {
            return const SizedBox(
              width: 400,
              height: 400,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          // Return a Scaffold that can grow/scroll
          return Scaffold(
            appBar: AppBar(
              backgroundColor: primaryColor,
              title: Text(
                'Редактировать «Приход» (ID: ${widget.docId})',
                style: headingStyle,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: pagePadding,
              child: Column(
                children: [
                  _buildHeaderSection(),
                  const SizedBox(height: verticalPadding),
                  _buildItemsSection(),
                  const SizedBox(height: verticalPadding),
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
            const SizedBox(height: verticalPadding),
            Wrap(
              spacing: horizontalPadding,
              runSpacing: verticalPadding,
              children: [
                // Provider dropdown
                SizedBox(
                  width: 250,
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Поставщик',
                      labelStyle: formLabelStyle,
                      border: OutlineInputBorder(),
                    ),
                    value: _providerId,
                    items: _providers.map<DropdownMenuItem<int>>((prov) {
                      return DropdownMenuItem<int>(
                        value: prov['id'],
                        child: Text(
                          prov['name'].toString(),
                          style: bodyTextStyle,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _providerId = val;
                      });
                    },
                  ),
                ),
                // Date field
                SizedBox(
                  width: 180,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Дата',
                      labelStyle: formLabelStyle,
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(text: _documentDate),
                    onChanged: (val) {
                      _documentDate = val;
                    },
                  ),
                ),
                // Warehouse dropdown
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
                        child: Text(
                          wh['name'].toString(),
                          style: bodyTextStyle,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _warehouseId = val;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
                  style: elevatedButtonStyle,
                  onPressed: _addProductRow,
                  child: const Text('➕ Добавить строку'),
                ),
              ],
            ),
            const SizedBox(height: verticalPadding),
            Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(primaryColor),
                  columns: const [
                    DataColumn(label: Text('Товар', style: tableHeaderStyle)),
                    DataColumn(label: Text('Кол-во тары', style: tableHeaderStyle)),
                    DataColumn(label: Text('Ед.изм', style: tableHeaderStyle)),
                    DataColumn(label: Text('Брутто', style: tableHeaderStyle)),
                    DataColumn(label: Text('Нетто', style: tableHeaderStyle)),
                    DataColumn(label: Text('Цена', style: tableHeaderStyle)),
                    DataColumn(label: Text('Сумма', style: tableHeaderStyle)),
                    DataColumn(label: Text('Доп. расход', style: tableHeaderStyle)),
                    DataColumn(label: Text('Себестоим.', style: tableHeaderStyle)),
                    DataColumn(label: Text('Удалить', style: tableHeaderStyle)),
                  ],
                  rows: List.generate(_productRows.length, (idx) {
                    final row = _productRows[idx];
                    final netto = _calculateNetto(row);
                    final total = _calculateTotal(row);
                    final additionalExp = _calculateAdditionalExpense(row);
                    final costPrice = _calculateCostPrice(row);

                    return DataRow(
                      cells: [
                        // Product
                        DataCell(
                          DropdownButton<int>(
                            value: row['selectedProductIndex'] as int?,
                            hint: const Text('— Товар —'),
                            items: List.generate(_products.length, (pIndex) {
                              final product = _products[pIndex];
                              return DropdownMenuItem<int>(
                                value: pIndex,
                                child: Text(
                                  product['name'].toString(),
                                  style: bodyTextStyle,
                                ),
                              );
                            }),
                            onChanged: (val) {
                              setState(() {
                                row['selectedProductIndex'] = val;
                                row['product_subcard_id'] =
                                    _products[val!]['id'];
                              });
                            },
                          ),
                        ),
                        // Quantity
                        DataCell(
                          SizedBox(
                            width: 70,
                            child: TextFormField(
                              style: bodyTextStyle,
                              initialValue: row['quantity'].toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  row['quantity'] = _parseNumber(val);
                                });
                              },
                            ),
                          ),
                        ),
                        // Unit
                        DataCell(
                          DropdownButton<int>(
                            value: row['selectedUnitIndex'] as int?,
                            hint: const Text('— Ед.изм —'),
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
                        // Brutto
                        DataCell(
                          SizedBox(
                            width: 70,
                            child: TextFormField(
                              style: bodyTextStyle,
                              initialValue: row['brutto'].toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  row['brutto'] = _parseNumber(val);
                                });
                              },
                            ),
                          ),
                        ),
                        // Netto (computed)
                        DataCell(Text(netto.toStringAsFixed(2),
                            style: bodyTextStyle)),
                        // Price
                        DataCell(
                          SizedBox(
                            width: 70,
                            child: TextFormField(
                              style: bodyTextStyle,
                              initialValue: row['price'].toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  row['price'] = _parseNumber(val);
                                });
                              },
                            ),
                          ),
                        ),
                        // Total
                        DataCell(Text(
                          total.toStringAsFixed(2),
                          style: bodyTextStyle,
                        )),
                        // Additional expense
                        DataCell(Text(
                          additionalExp.toStringAsFixed(2),
                          style: bodyTextStyle,
                        )),
                        // Cost Price
                        DataCell(Text(
                          costPrice.toStringAsFixed(2),
                          style: bodyTextStyle,
                        )),
                        // Remove row
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete, color: errorColor),
                            onPressed: () => _removeProductRow(idx),
                          ),
                        ),
                      ],
                    );
                  })
                    ..add(
                      // Summary row
                      DataRow(
                        cells: [
                          const DataCell(SizedBox()),
                          const DataCell(SizedBox()),
                          const DataCell(SizedBox()),
                          const DataCell(SizedBox()),
                          DataCell(Text(_totalNetto.toStringAsFixed(2),
                              style: bodyTextStyle)),
                          const DataCell(Text('-')),
                          DataCell(Text(_totalSum.toStringAsFixed(2),
                              style: bodyTextStyle)),
                          DataCell(Text(_totalExpenses.toStringAsFixed(2),
                              style: bodyTextStyle)),
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
                  style: elevatedButtonStyle,
                  onPressed: _addExpenseRow,
                  child: const Text('➕ Добавить'),
                ),
              ],
            ),
            const SizedBox(height: verticalPadding),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(primaryColor),
                columns: const [
                  DataColumn(label: Text('Название', style: tableHeaderStyle)),
                  DataColumn(label: Text('Сумма', style: tableHeaderStyle)),
                  DataColumn(label: Text('Удалить', style: tableHeaderStyle)),
                ],
                rows: List.generate(_expenses.length, (idx) {
                  final exp = _expenses[idx];
                  return DataRow(
                    cells: [
                      // Expense dropdown
                      DataCell(
                        DropdownButton<int>(
                          value: exp['selectedIndex'] as int?,
                          hint: const Text('— Расход —'),
                          items: List.generate(_allExpenses.length, (eIndex) {
                            final expense = _allExpenses[eIndex];
                            return DropdownMenuItem<int>(
                              value: eIndex,
                              child: Text(expense['name'].toString(),
                                  style: bodyTextStyle),
                            );
                          }),
                          onChanged: (val) {
                            setState(() {
                              exp['selectedIndex'] = val;
                              exp['selectedExpenseId'] =
                                  _allExpenses[val!]['id'];
                              exp['name'] = _allExpenses[val]['name'];
                            });
                          },
                        ),
                      ),
                      // Amount
                      DataCell(
                        SizedBox(
                          width: 70,
                          child: TextFormField(
                            style: bodyTextStyle,
                            initialValue: exp['amount'].toString(),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) {
                              setState(() {
                                exp['amount'] = _parseNumber(val);
                              });
                            },
                          ),
                        ),
                      ),
                      // Remove row
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.delete, color: errorColor),
                          onPressed: () => _removeExpenseRow(idx),
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

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      height: 60,
      child: Row(
        children: [
          ElevatedButton(
            style: elevatedButtonStyle,
            // If _isSubmitting is true, button is disabled (null)
            onPressed: _isSubmitting ? null : _saveDocument,
            child: Text(
              _isSubmitting ? "Сохранение..." : "Сохранить",
              style: buttonTextStyle,
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: unselectednavbar),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Отмена", style: buttonTextStyle),
          ),
          const Spacer(),
          if (_feedbackMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _feedbackMessage,
                style: buttonTextStyle,
              ),
            ),
        ],
      ),
    );
  }

  // ----------------- Helpers and Calculations -----------------

  void _initializeFromState(StorageReceivingSingleLoaded state) {
    // Save references
    _providers = state.providers;
    _warehouses = state.warehouses;
    _products = state.productSubCards;
    _units = state.unitMeasurements;
    _allExpenses = state.expenses;

    // Initialize header fields
    final doc = state.document;
    _providerId = doc['provider_id'] as int?;
    if (doc['document_date'] != null && doc['document_date'].length >= 10) {
      _documentDate = doc['document_date'].substring(0, 10);
    }
    _warehouseId = doc['to_warehouse_id'] as int?;

    // Prepare product rows
    final items = doc['document_items'] as List<dynamic>? ?? [];
    _productRows = items.map<Map<String, dynamic>>((item) {
      var row = {
        '_key': item['id'],
        'id': item['id'],
        'product_subcard_id': item['product_subcard_id'],
        'quantity': item['quantity'] ?? 0.0,
        'brutto': item['brutto'] ?? 0.0,
        'unit_measurement': item['unit_measurement'] ?? '',
        'price': item['price'] ?? 0.0,
        'additional_expenses': item['additional_expenses'] ?? 0.0,
      };
      // Figure out which product is selected
      if (row['product_subcard_id'] != null) {
        int index = _products
            .indexWhere((p) => p['id'] == row['product_subcard_id']);
        if (index != -1) {
          row['selectedProductIndex'] = index;
        } else if (_products.isNotEmpty) {
          row['selectedProductIndex'] = 0;
        }
      }
      // Figure out which unit is selected
      if (row['unit_measurement'] != null && row['unit_measurement'] != '') {
        int unitIndex = _units
            .indexWhere((u) => u['name'] == row['unit_measurement']);
        if (unitIndex != -1) {
          row['selectedUnitIndex'] = unitIndex;
        }
      }
      return row;
    }).toList();

    // Prepare expense rows
    final expList = doc['expenses'] as List<dynamic>? ?? [];
    _expenses = expList.map<Map<String, dynamic>>((e) {
      var expRow = {
        '_key': e['id'],
        'id': e['id'],
        'selectedExpenseId': e['expense_id'] ?? e['id'],
        'name': e['name'] ?? '',
        'amount': e['amount'] ?? 0.0,
      };
      int expIndex = _allExpenses.indexWhere((x) => x['id'] == expRow['selectedExpenseId']);
      if (expIndex != -1) {
        expRow['selectedIndex'] = expIndex;
      }
      return expRow;
    }).toList();
  }

  double _parseNumber(String? val) {
    if (val == null || val.isEmpty) return 0.0;
    return double.tryParse(val) ?? 0.0;
  }

  double _calculateNetto(Map<String, dynamic> row) {
    // find matching unit
    final unit = _units.firstWhere(
      (u) => u['name'] == row['unit_measurement'],
      orElse: () => {'tare': 0},
    );
    final tareGram = _parseNumber(unit['tare'].toString());
    final tareKg = tareGram / 1000.0; // convert grams to kg

    final brutto = _parseNumber(row['brutto'].toString());
    final qty = _parseNumber(row['quantity'].toString());
    return brutto - (qty * tareKg);
  }

  double _calculateTotal(Map<String, dynamic> row) {
    return _calculateNetto(row) * _parseNumber(row['price'].toString());
  }

  double get _totalNetto {
    return _productRows.fold(0.0, (acc, r) => acc + _calculateNetto(r));
  }

  double get _totalSum {
    return _productRows.fold(0.0, (acc, r) => acc + _calculateTotal(r));
  }

  double get _totalExpenses {
    return _expenses.fold(
      0.0,
      (acc, e) => acc + _parseNumber(e['amount'].toString()),
    );
  }

  double _calculateAdditionalExpense(Map<String, dynamic> row) {
    final totalQty = _productRows.fold<double>(
      0.0,
      (acc, r) => acc + _parseNumber(r['quantity'].toString()),
    );
    if (totalQty == 0) return 0.0;

    final itemQty = _parseNumber(row['quantity'].toString());
    return (_totalExpenses / totalQty) * itemQty;
  }

  double _calculateCostPrice(Map<String, dynamic> row) {
    final totalCost = _calculateTotal(row) + _calculateAdditionalExpense(row);
    final qty = _parseNumber(row['quantity'].toString());
    return qty > 0 ? (totalCost / qty) : 0.0;
  }

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

  void _removeProductRow(int idx) {
    setState(() {
      _productRows.removeAt(idx);
    });
  }

  void _addExpenseRow() {
    setState(() {
      _expenses.add({
        '_key': DateTime.now().millisecondsSinceEpoch,
        'id': null,
        'selectedExpenseId': null,
        'selectedIndex': null,
        'name': '',
        'amount': 0.0,
      });
    });
  }

  void _removeExpenseRow(int idx) {
    setState(() {
      _expenses.removeAt(idx);
    });
  }

  void _saveDocument() {
    setState(() {
      _isSubmitting = true;
      _feedbackMessage = '';
    });

    final productsPayload = _productRows.map((r) {
      return {
        'id': r['id'],
        'product_subcard_id': r['product_subcard_id'],
        'quantity': r['quantity'],
        'brutto': r['brutto'],
        'netto': _calculateNetto(r),
        'unit_measurement': r['unit_measurement'],
        'price': r['price'],
        'total_sum': _calculateTotal(r),
        'additional_expenses': _calculateAdditionalExpense(r),
        'cost_price': _calculateCostPrice(r),
      };
    }).toList();

    final expensesPayload = _expenses.map((ex) {
      return {
        'id': ex['id'],
        'expense_id': ex['selectedExpenseId'],
        'name': ex['name'],
        'amount': ex['amount'],
      };
    }).toList();

    final payload = {
      'provider_id': _providerId,
      'document_date': _documentDate,
      'assigned_warehouse_id': _warehouseId,
      'products': productsPayload,
      'expenses': expensesPayload,
    };

    // Dispatch the update event to the Bloc
    context
        .read<StorageReceivingBloc>()
        .add(UpdateIncomeEvent(docId: widget.docId, updatedData: payload));
  }
}
