// file: edit_income.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:alan/constant.dart';

/// A page (or screen) for editing an existing income doc
class EditIncomePage extends StatefulWidget {
  final Map<String, dynamic> incomeData; 
  // e.g. { 'id':..., 'provider_id':..., 'document_date':..., 'products':[], 'expenses':[] }
  
  final List<dynamic> providers;
  final List<dynamic> productSubCards;
  final List<dynamic> unitMeasurements;
  final List<dynamic> allExpenses;

  const EditIncomePage({
    Key? key,
    required this.incomeData,
    required this.providers,
    required this.productSubCards,
    required this.unitMeasurements,
    required this.allExpenses,
  }) : super(key: key);

  @override
  State<EditIncomePage> createState() => _EditIncomePageState();
}

class _EditIncomePageState extends State<EditIncomePage> {
  dynamic _selectedProviderId;
  DateTime? _selectedDate;

  List<Map<String, dynamic>> _productRows = [];
  List<Map<String, dynamic>> _expenseRows = [];

  double _totalNetto = 0.0;
  double _totalSum = 0.0;
  double _totalExpenses = 0.0;

  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData(widget.incomeData);
  }

  /// Load the existing doc data into local variables
  void _loadData(Map<String, dynamic> doc) {
    setState(() {
      _selectedProviderId = doc['provider_id'];
      final dateStr = doc['document_date'] as String?;
      if (dateStr != null) {
        _selectedDate = DateTime.tryParse(dateStr);
      }

      // Convert doc's "products" array to our table row format
      final products = doc['products'] ?? [];
      _productRows = products.map<Map<String, dynamic>>((p) {
        return {
          'product_subcard_id': p['product_subcard_id'],
          'unitId': null, // or convert if you store unit name
          'quantity': p['quantity'] ?? 0,
          'brutto': p['brutto'] ?? 0.0,
          'price': p['price'] ?? 0.0,
          'netto': p['netto'] ?? 0.0,
          'sum': p['total_sum'] ?? 0.0,
          'additionalExpense': p['additional_expenses'] ?? 0.0,
          'costPrice': p['cost_price'] ?? 0.0,
        };
      }).toList();

      final expenses = doc['expenses'] ?? [];
      _expenseRows = expenses.map<Map<String, dynamic>>((e) {
        return {
          'expenseId': e['expense_id'],
          'amount': e['amount'] ?? 0.0,
        };
      }).toList();

      _recalcAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Редактирование прихода", style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProviderDateRow(),
            const SizedBox(height: 16),
            _buildProductsTable(),
            const SizedBox(height: 16),
            _buildExpensesTable(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: elevatedButtonStyle,
                onPressed: _onUpdate,
                child: Text('Сохранить изменения', style: buttonTextStyle),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildProductsTable() {
    return Container(
      child: Text("Table of products (similar to goods_receipt_page but referencing _productRows)."),
    );
  }

  Widget _buildExpensesTable() {
    return Container(
      child: Text("Table of expenses referencing _expenseRows."),
    );
  }

  void _recalcAll() {
    double totalExp = 0.0;
    for (final e in _expenseRows) {
      totalExp += (e['amount'] as double?) ?? 0.0;
    }
    _totalExpenses = totalExp;

    int totalQty = 0;
    for (final p in _productRows) {
      totalQty += (p['quantity'] as int?) ?? 0;
    }

    for (final row in _productRows) {
      final brutto = (row['brutto'] as double?) ?? 0.0;
      final qty = (row['quantity'] as int?) ?? 0;
      // find the unit tare if needed
      // ...
      final tareKg = 0.04; // example

      double netto = brutto - (qty * tareKg);
      if (netto < 0) netto = 0;
      row['netto'] = netto;

      final price = (row['price'] as double?) ?? 0.0;
      final sum = netto * price;
      row['sum'] = sum;

      double addExp = 0.0;
      if (totalQty > 0 && qty > 0) {
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

  void _onUpdate() {
    final dateStr = _selectedDate == null
      ? null
      : DateFormat('yyyy-MM-dd').format(_selectedDate!);

    final updatedPayload = {
      'provider_id': _selectedProviderId,
      'document_date': dateStr,
      'products': _productRows.map((r) => {
        'product_subcard_id': r['product_subcard_id'],
        'quantity': r['quantity'],
        'brutto': r['brutto'],
        'netto': r['netto'],
        'price': r['price'],
        'total_sum': r['sum'],
        'additional_expenses': r['additionalExpense'],
        'cost_price': r['costPrice'],
      }).toList(),
      'expenses': _expenseRows.map((e) => {
        'expense_id': e['expenseId'],
        'amount': e['amount'],
      }).toList(),
    };

    Navigator.of(context).pop(updatedPayload);
  }
}
