import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// import your constants + styles
import 'package:alan/constant.dart';

class SaleWidget extends StatefulWidget {
  final List<dynamic> clients;
  final List<dynamic> productSubCards;
  final List<dynamic> unitMeasurements;

  const SaleWidget({
    Key? key,
    required this.clients,
    required this.productSubCards,
    required this.unitMeasurements,
  }) : super(key: key);

  @override
  State<SaleWidget> createState() => _SaleWidgetState();
}

class _SaleWidgetState extends State<SaleWidget> {
  dynamic _selectedClientId;
  DateTime? _selectedDate;

  final List<Map<String, dynamic>> _productRows = [
    {
      'product_subcard_id': null,
      'unitId': null,
      'quantity': 0,
      'brutto': 0.0,
      'netto': 0.0,
      'price': 0.0,
      'sum': 0.0,
    },
  ];

  final ScrollController _horizontalScrollController = ScrollController();
  double _totalNetto = 0.0;
  double _totalSum = 0.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Продажа', style: subheadingStyle),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),

          _buildClientDateRow(),
          const SizedBox(height: 16),

          _buildProductsTable(),
          const SizedBox(height: 24),

          // Save
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

  Widget _buildClientDateRow() {
    return Row(
      children: [
        // Client
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Клиент', style: formLabelStyle),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: DropdownButton(
                  value: _selectedClientId,
                  isExpanded: true,
                  underline: const SizedBox(),
                  hint: const Text('Выберите клиента'),
                  style: bodyTextStyle,
                  items: widget.clients.map<DropdownMenuItem>((c) {
                    // c is a Map<String,dynamic> with {id, first_name, last_name}, etc.
                    // If your client object is: {id, first_name, last_name, surname, ...}
                    // you might want to combine them in display:
                    final clientName = (c['first_name'] ?? '') + ' ' + (c['last_name'] ?? '');
                    final id = c['id'];
                    return DropdownMenuItem(
                      value: id,
                      child: Text(clientName.isNotEmpty ? clientName : 'NoName'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedClientId = val;
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
                onTap: _pickDate,
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

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
            // Title + Add Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('продажи', style: subheadingStyle),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Добавить строку'),
                  style: elevatedButtonStyle,
                  onPressed: () {
                    setState(() {
                      _productRows.add({
                        'product_subcard_id': null,
                        'unitId': null,
                        'quantity': 0,
                        'brutto': 0.0,
                        'netto': 0.0,
                        'price': 0.0,
                        'sum': 0.0,
                      });
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

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
                          _tableHeaderCell('Удалить', width: 60),
                        ],
                      ),
                    ),
                    // Rows
                    Column(
                      children: List.generate(_productRows.length, (index) {
                        final row = _productRows[index];
                        return Row(
                          children: [
                            // Product sub-card
                            _tableBodyCell(
                              width: 120,
                              child: DropdownButton(
                                value: row['product_subcard_id'],
                                isExpanded: true,
                                underline: const SizedBox(),
                                hint: const Text('Товар', style: tableCellStyle),
                                style: tableCellStyle,
                                items: widget.productSubCards.map<DropdownMenuItem>((psc) {
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

                            // quantity
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

                            // unit
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
                                    child: Text('${um['name']} (${um['tare'] ?? 0}г)', style: tableCellStyle),
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

                            // brutto
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

                            // netto (display only)
                            _tableBodyCell(
                              width: 60,
                              child: Text(
                                row['netto'].toStringAsFixed(2),
                                style: tableCellStyle,
                              ),
                            ),

                            // price
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

                            // sum (display only)
                            _tableBodyCell(
                              width: 60,
                              child: Text(
                                row['sum'].toStringAsFixed(2),
                                style: tableCellStyle,
                              ),
                            ),

                            // delete row
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
                        // Just a placeholder area
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
                        _summaryCell('-', width: 60),
                        _summaryCell(_totalNetto.toStringAsFixed(2), width: 60),
                        _summaryCell('-', width: 60),
                        _summaryCell(_totalSum.toStringAsFixed(2), width: 60),
                        _summaryCell('', width: 60),
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

  // Recalc brutto->netto, sum
  void _recalcAll() {
  double totalNet = 0.0;
  double totalSum = 0.0;

  for (final row in _productRows) {
    final quantity = (row['quantity'] as int?) ?? 0;
    final brutto = (row['brutto'] as double?) ?? 0.0;
    final price = (row['price'] as double?) ?? 0.0;

    // 1) Find the unit's tare in grams, then convert to kg
    final unitId = row['unitId'];
    final foundUnit = widget.unitMeasurements.firstWhere(
      (um) => um['id'] == unitId,
      orElse: () => {'tare': 0.0},
    );

    final tareGrams = (foundUnit['tare'] is num)
        ? foundUnit['tare'].toDouble()
        : 0.0;
    final tareKg = tareGrams / 1000.0; // convert grams → kilograms

    // 2) Netto = Brutto - (tareKg * quantity)
    double netto = brutto - (tareKg * quantity);
    if (netto < 0) {
      netto = 0;
    }
    // round to 2 decimals
    netto = double.parse(netto.toStringAsFixed(2));
    row['netto'] = netto;

    // 3) Row sum = Netto * price
    double rowSum = netto * price;
    rowSum = double.parse(rowSum.toStringAsFixed(2));
    row['sum'] = rowSum;

    // 4) Accumulate totals
    totalNet += netto;
    totalSum += rowSum;
  }

  setState(() {
    // Round these as well, if you want consistent display
    _totalNetto = double.parse(totalNet.toStringAsFixed(2));
    _totalSum = double.parse(totalSum.toStringAsFixed(2));
  });
}

  // On Save
  void _onSave() {
    final dateStr = _selectedDate == null
        ? null
        : DateFormat('yyyy-MM-dd').format(_selectedDate!);

    final payload = {
      'doc_type': 'sale', // so backend knows this is a sale
      'client_id': _selectedClientId,
      'document_date': dateStr,
      'items': _productRows.map((p) => {
        'product_subcard_id': p['product_subcard_id'],
        'unit_id': p['unitId'], // or if your backend wants 'unit_measurement' name, adapt
        'quantity': p['quantity'],
        'brutto': p['brutto'],
        'netto': p['netto'],
        'price': p['price'],
        'total_sum': p['sum'],
      }).toList(),
    };

    Navigator.of(context).pop(payload);
  }
}
