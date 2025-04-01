import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Import your constants file if needed
import 'package:alan/constant.dart';

class ReceiptWidget extends StatefulWidget {
  /// Real data fetched from StorageReferencesBloc
  final List<dynamic> providers;
  final List<dynamic> productSubCards;
  final List<dynamic> unitMeasurements;
  final List<dynamic> allExpenses;

  const ReceiptWidget({
    Key? key,
    required this.providers,
    required this.productSubCards,
    required this.unitMeasurements,
    required this.allExpenses,
  }) : super(key: key);

  @override
  State<ReceiptWidget> createState() => _ReceiptWidgetState();
}

class _ReceiptWidgetState extends State<ReceiptWidget> {
  dynamic _selectedProviderId;
  DateTime? _selectedDate;

  /// Table of products
  final List<Map<String, dynamic>> _productRows = [
    {
      'product_subcard_id': null,
      'unitId': null,
      'quantity': 0,
      'brutto': 0.0,
      'price': 0.0,
      'netto': 0.0,
      'sum': 0.0,
      'additionalExpense': 0.0,
      'costPrice': 0.0,
    },
  ];

  /// Table of expenses
  final List<Map<String, dynamic>> _expenseRows = [
    {
      'expenseId': null,
      'amount': 0.0,
    },
  ];

  /// Calculated totals
  double _totalNetto = 0.0;
  double _totalSum = 0.0;
  double _totalExpenses = 0.0;

  final ScrollController _horizontalScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600, // fixed width for the dialog content
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row: Title + close
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Поступление Товара', style: subheadingStyle),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row with Provider + Date
          _buildProviderDateRow(),
          const SizedBox(height: 16),

          // Products Table
          _buildProductsTable(),
          const SizedBox(height: 16),

          // Expenses Table
          _buildExpensesTable(),
          const SizedBox(height: 24),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: elevatedButtonStyle,
              onPressed: _onSave,
              child: Text('Сохранить', style: buttonTextStyle),
            ),
          ),
        ],
      ),
    );
  }

  /// Build provider dropdown + date picker side by side
  Widget _buildProviderDateRow() {
    return Row(
      children: [
        // Provider
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Поставщик', style: formLabelStyle),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: DropdownButton(
                  value: _selectedProviderId,
                  isExpanded: true,
                  underline: const SizedBox(),
                  hint: const Text('Выберите поставщика'),
                  style: bodyTextStyle,
                  items: widget.providers.map<DropdownMenuItem>((p) {
                    // p is a Map<String,dynamic> with {id, name, ...}
                    return DropdownMenuItem(
                      value: p['id'],
                      child: Text(p['name'] ?? 'NoName'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedProviderId = val;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Date
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Дата', style: formLabelStyle),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate == null
                              ? 'Выберите дату'
                              : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                          style: bodyTextStyle,
                        ),
                        const Icon(Icons.calendar_today, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Table for products
  Widget _buildProductsTable() {
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
            // Header row: Title + "Add row"
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
                        'unitId': null,
                        'quantity': 0,
                        'brutto': 0.0,
                        'price': 0.0,
                        'netto': 0.0,
                        'sum': 0.0,
                        'additionalExpense': 0.0,
                        'costPrice': 0.0,
                      });
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Scrollable horizontal
            Scrollbar(
              controller: _horizontalScrollController,
              thumbVisibility: true,
              trackVisibility: true,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _horizontalScrollController,
                child: Column(
                  children: [
                    // Table Header
                    Container(
                      color: primaryColor,
                      child: Row(
                        children: [
                          _tableHeaderCell('Товар', width: 120),
                          _tableHeaderCell('Кол-во тары', width: 80),
                          _tableHeaderCell('Ед. изм / Тара', width: 110),
                          _tableHeaderCell('Брутто', width: 60),
                          _tableHeaderCell('Нетто', width: 60),
                          _tableHeaderCell('Цена', width: 60),
                          _tableHeaderCell('Сумма', width: 60),
                          _tableHeaderCell('Доп. расход', width: 80),
                          _tableHeaderCell('Себестоимость', width: 80),
                          _tableHeaderCell('Удалить', width: 60),
                        ],
                      ),
                    ),
                    // Table Rows
                    Column(
                      children: List.generate(_productRows.length, (index) {
                        final row = _productRows[index];
                        return Row(
                          children: [
                            // Product
                            _tableBodyCell(
                              width: 120,
                              child: DropdownButton(
                                value: row['product_subcard_id'],
                                isExpanded: true,
                                underline: const SizedBox(),
                                hint: const Text('Товар', style: tableCellStyle),
                                style: tableCellStyle,
                                items: widget.productSubCards.map<DropdownMenuItem>((psc) {
                                  // psc is a Map with {id, name, ...}
                                  return DropdownMenuItem(
                                    value: psc['id'],
                                    child: Text(psc['name'], style: tableCellStyle),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    row['product_subcard_id'] = val;
                                  });
                                  _recalcAll();
                                },
                              ),
                            ),

                            // Qty
                            _tableBodyCell(
                              width: 80,
                              child: TextField(
                                style: tableCellStyle,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '0',
                                ),
                                onChanged: (val) {
                                  row['quantity'] = int.tryParse(val) ?? 0;
                                  _recalcAll();
                                },
                              ),
                            ),

                            // Unit
                            _tableBodyCell(
                              width: 110,
                              child: DropdownButton(
                                value: row['unitId'],
                                isExpanded: true,
                                underline: const SizedBox(),
                                hint: const Text('ед.', style: tableCellStyle),
                                style: tableCellStyle,
                                items: widget.unitMeasurements.map<DropdownMenuItem>((um) {
                                  return DropdownMenuItem(
                                    value: um['id'],
                                    child: Text(
                                      '${um['name']} (${um['tare'] ?? 0}г)',
                                      style: tableCellStyle,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    row['unitId'] = val;
                                  });
                                  _recalcAll();
                                },
                              ),
                            ),

                            // Brutto
                            _tableBodyCell(
                              width: 60,
                              child: TextField(
                                style: tableCellStyle,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '0.0',
                                ),
                                onChanged: (val) {
                                  row['brutto'] = double.tryParse(val) ?? 0.0;
                                  _recalcAll();
                                },
                              ),
                            ),
                            // Netto (display only)
                            _tableBodyCell(
                              width: 60,
                              child: Text(
                                row['netto'].toStringAsFixed(2),
                                style: tableCellStyle,
                              ),
                            ),
                            // Price
                            _tableBodyCell(
                              width: 60,
                              child: TextField(
                                style: tableCellStyle,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '0.0',
                                ),
                                onChanged: (val) {
                                  row['price'] = double.tryParse(val) ?? 0.0;
                                  _recalcAll();
                                },
                              ),
                            ),
                            // Sum (display only)
                            _tableBodyCell(
                              width: 60,
                              child: Text(
                                row['sum'].toStringAsFixed(2),
                                style: tableCellStyle,
                              ),
                            ),
                            // Additional expense (display only)
                            _tableBodyCell(
                              width: 80,
                              child: Text(
                                row['additionalExpense'].toStringAsFixed(2),
                                style: tableCellStyle,
                              ),
                            ),
                            // Cost Price (display only)
                            _tableBodyCell(
                              width: 80,
                              child: Text(
                                row['costPrice'].toStringAsFixed(2),
                                style: tableCellStyle,
                              ),
                            ),
                            // Delete row button
                            _tableBodyCell(
                              width: 60,
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _productRows.removeAt(index);
                                  });
                                  _recalcAll();
                                },
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                    // Summary row
                    Row(
                      children: [
                        Container(
                          width: 120 + 80 + 110,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.centerRight,
                          decoration: const BoxDecoration(
                            border: Border(
                              right: tableBorderSide,
                              bottom: tableBorderSide,
                            ),
                          ),
                          child: const Text(
                            'ИТОГО',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        _summaryCell('-', width: 60), // brutto not summarized
                        _summaryCell(_totalNetto.toStringAsFixed(2), width: 60),
                        _summaryCell('-', width: 60), // price col
                        _summaryCell(_totalSum.toStringAsFixed(2), width: 60),
                        _summaryCell(_totalExpenses.toStringAsFixed(2), width: 80),
                        _summaryCell('-', width: 80), // costPrice total?
                        _summaryCell('-', width: 60), // delete col
                      ],
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

  /// Expenses Table
  Widget _buildExpensesTable() {
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
                  onPressed: () {
                    setState(() {
                      _expenseRows.add({'expenseId': null, 'amount': 0.0});
                    });
                    _recalcAll();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Table header
            Container(
              color: primaryColor,
              child: Row(
                children: [
                  _tableHeaderCell('Наименование', width: 120),
                  _tableHeaderCell('Сумма', width: 80),
                  _tableHeaderCell('Удалить', width: 60),
                ],
              ),
            ),
            // Table rows
            Column(
              children: List.generate(_expenseRows.length, (index) {
                final row = _expenseRows[index];
                return Row(
                  children: [
                    // expense name
                    _tableBodyCell(
                      width: 120,
                      child: DropdownButton(
                        value: row['expenseId'],
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text('Выберите', style: tableCellStyle),
                        style: tableCellStyle,
                        items: widget.allExpenses.map<DropdownMenuItem>((ex) {
                          return DropdownMenuItem(
                            value: ex['id'],
                            child: Text(ex['name'] ?? 'NoName', style: tableCellStyle),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            row['expenseId'] = val;
                          });
                          _recalcAll();
                        },
                      ),
                    ),
                    // expense amount
                    _tableBodyCell(
                      width: 80,
                      child: TextField(
                        style: tableCellStyle,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0.0',
                        ),
                        onChanged: (val) {
                          row['amount'] = double.tryParse(val) ?? 0.0;
                          _recalcAll();
                        },
                      ),
                    ),
                    // delete button
                    _tableBodyCell(
                      width: 60,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _expenseRows.removeAt(index);
                          });
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

  /// Table header cell
  Widget _tableHeaderCell(String label, {double width = 100}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        border: Border(right: tableBorderSide),
      ),
      child: Text(label, style: tableHeaderStyle),
    );
  }

  /// Table body cell
  Widget _tableBodyCell({required Widget child, double width = 100}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 6),
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

  /// Summary cell in the last row
  Widget _summaryCell(String label, {double width = 60}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        border: Border(
          right: tableBorderSide,
          bottom: tableBorderSide,
        ),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  /// Recalculate logic
  void _recalcAll() {
    // Summation of all additional expenses
    double totalExp = 0.0;
    for (final e in _expenseRows) {
      totalExp += (e['amount'] as double?) ?? 0.0;
    }
    _totalExpenses = totalExp;

    // Summation of all product row quantities
    int totalQty = 0;
    for (final p in _productRows) {
      totalQty += (p['quantity'] as int?) ?? 0;
    }

    // For each product row, recalc brutto->netto, sum, cost, etc.
    for (final row in _productRows) {
      final unitId = row['unitId'];
      // find the unit from the reference list
      final foundUnit = widget.unitMeasurements.firstWhere(
        (um) => um['id'] == unitId,
        orElse: () => {'tare': 0},
      );

      double tareGrams = 0.0;
      final dynamic tv = foundUnit['tare'];
      if (tv is int) tareGrams = tv.toDouble();
      if (tv is double) tareGrams = tv;

      final tareKg = tareGrams / 1000.0;

      final brutto = (row['brutto'] as double?) ?? 0.0;
      final qty = (row['quantity'] as int?) ?? 0;

      // Netto = brutto - (qty * tareKg)
      double netto = brutto - (qty * tareKg);
      if (netto < 0) netto = 0;
      row['netto'] = netto;

      final price = (row['price'] as double?) ?? 0.0;
      final sum = netto * price;
      row['sum'] = sum;

      double addExp = 0.0;
      if (totalQty > 0 && qty > 0) {
        // distribute the totalExp proportionally by quantity
        addExp = (qty / totalQty) * totalExp;
      }
      row['additionalExpense'] = addExp;

      double costP = 0.0;
      if (qty > 0) {
        costP = (sum + addExp) / qty;
      }
      row['costPrice'] = costP;
    }

    double netSum = 0.0;
    double sumSum = 0.0;
    for (final r in _productRows) {
      netSum += (r['netto'] as double?) ?? 0.0;
      sumSum += (r['sum'] as double?) ?? 0.0;
    }
    _totalNetto = netSum;
    _totalSum = sumSum;

    setState(() {});
  }

  /// On Save: returns a payload with the final data
  void _onSave() {
  final dateStr = _selectedDate == null
      ? null
      : DateFormat('yyyy-MM-dd').format(_selectedDate!);

  // Filter out expense rows where 'expenseId' is null.
  final filteredExpenses = _expenseRows.where((e) => e['expenseId'] != null).toList();

  final payload = {
    'provider_id': _selectedProviderId,
    'document_date': dateStr,
    'products': _productRows.map((p) => {
      'product_subcard_id': p['product_subcard_id'],
      'unit_measurement': _findUnitName(p['unitId']),
      'quantity': p['quantity'],
      'brutto': p['brutto'],
      'netto': p['netto'],
      'price': p['price'],
      'total_sum': p['sum'],
      'additional_expenses': p['additionalExpense'],
      'cost_price': p['costPrice'],
    }).toList(),
    'expenses': filteredExpenses.map((e) => {
      'expense_id': e['expenseId'],
      'amount': e['amount'],
    }).toList(),
  };

  Navigator.of(context).pop(payload);
}

  /// If the backend wants a unit measurement string instead of an ID
  String _findUnitName(dynamic unitId) {
    final found = widget.unitMeasurements.firstWhere(
      (u) => u['id'] == unitId,
      orElse: () => {'name': ''},
    );
    return found['name'] ?? '';
  }
}
