// file: write_off_widget.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:alan/constant.dart';

/// A widget that creates a "Write-Off" document:
///  - Picks a date
///  - Shows a horizontally scrollable table of rows
///    where each row has { product_id, unit_id, quantity }
///  - No "price" column
///  - On "Сохранить," returns a final payload to the parent.
class WriteOffWidget extends StatefulWidget {
  final List<dynamic> productSubCards;    // e.g. [{id, name}, ...]
  final List<dynamic> unitMeasurements;   // e.g. [{id, name, tare}, ...]

  const WriteOffWidget({
    Key? key,
    required this.productSubCards,
    required this.unitMeasurements,
  }) : super(key: key);

  @override
  State<WriteOffWidget> createState() => _WriteOffWidgetState();
}

class _WriteOffWidgetState extends State<WriteOffWidget> {
  // Date chosen by user
  DateTime? _selectedDate;

  // Each table row => { product_id, unit_id, quantity }
  final List<Map<String, dynamic>> _items = [
    {
      'product_id': null,
      'unit_id': null,
      'quantity': 0,
    },
  ];

  // Horizontal scroll controller to enable manual scrolling
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600, // a fixed width for the dialog
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1) Header: Title + Close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Создать Списание', style: subheadingStyle),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 2) Date picker
          _buildDatePicker(),
          const SizedBox(height: 16),

          // 3) Items table
          _buildItemsTable(),
          const SizedBox(height: 24),

          // 4) Save button
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

  /// Builds a GestureDetector for picking the date
  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          setState(() {
            _selectedDate = pickedDate;
          });
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
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
    );
  }

  /// Builds the horizontally scrollable table for the write-off rows
  Widget _buildItemsTable() {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: borderColor),
    ),
    child: Padding(
      // You could reduce the outer padding too, if needed
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Списания', style: subheadingStyle),
              ElevatedButton.icon(
                style: elevatedButtonStyle,
                icon: const Icon(Icons.add),
                label: const Text(''),
                onPressed: _addRow,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Wrap SingleChildScrollView in Scrollbar
          Scrollbar(
            controller: _horizontalScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _horizontalScrollController,
              // Remove or reduce this constraint if you want a narrower table
              // child: ConstrainedBox(
              //   constraints: const BoxConstraints(minWidth: 800),
              //   ...
              // ),
              child: DataTable(
                // Control row/heading height and spacing:
                dataRowHeight: 40.0,
                headingRowHeight: 40.0,
                columnSpacing: 10.0,
                headingRowColor: MaterialStateProperty.all(primaryColor),
                columns: [
                  DataColumn(label: Text('Товар', style: tableHeaderStyle)),
                  DataColumn(label: Text('Ед. изм', style: tableHeaderStyle)),
                  DataColumn(label: Text('Кол-во', style: tableHeaderStyle)),
                  DataColumn(label: Text('Удалить', style: tableHeaderStyle)),
                ],
                rows: List.generate(_items.length, (index) {
                  final row = _items[index];
                  return DataRow(
                    cells: [
                      DataCell(_buildProductDropdown(row)),
                      DataCell(_buildUnitDropdown(row)),
                      DataCell(_buildQuantityCell(row)),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          splashRadius: 18, // Make the icon button smaller
                          onPressed: () => _removeRow(index),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  /// Product dropdown cell
  Widget _buildProductDropdown(Map<String, dynamic> row) {
    return DropdownButton(
      value: row['product_id'],
      hint: const Text('Товар'),
      underline: const SizedBox(),
      items: widget.productSubCards.map<DropdownMenuItem>((prod) {
        final prodId = prod['id'];
        final prodName = prod['name'] ?? 'NoName';
        return DropdownMenuItem(
          value: prodId,
          child: Text(prodName),
        );
      }).toList(),
      onChanged: (val) {
        setState(() {
          row['product_id'] = val;
        });
      },
    );
  }

  /// Unit dropdown cell
  Widget _buildUnitDropdown(Map<String, dynamic> row) {
    return DropdownButton(
      value: row['unit_id'],
      hint: const Text('ед.'),
      underline: const SizedBox(),
      items: widget.unitMeasurements.map<DropdownMenuItem>((u) {
        final unitId = u['id'];
        final name = u['name'] ?? 'Unit';
        final tare = u['tare'] ?? 0;
        return DropdownMenuItem(
          value: unitId,
          child: Text('$name ($tare г)'),
        );
      }).toList(),
      onChanged: (val) {
        setState(() {
          row['unit_id'] = val;
        });
      },
    );
  }

  /// Quantity text field cell
  Widget _buildQuantityCell(Map<String, dynamic> row) {
  return SizedBox(
    width: 60, // fix a narrower width if you want
    child: TextField(
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 14), // smaller font
      decoration: const InputDecoration(
        hintText: '0',
        isDense: true, // make it dense
        contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        border: UnderlineInputBorder(
          borderSide: BorderSide(width: 0.5),
        ),
      ),
      onChanged: (val) {
        row['quantity'] = int.tryParse(val) ?? 0;
        setState(() {});
      },
    ),
  );
}


  // Add row to table
  void _addRow() {
    setState(() {
      _items.add({
        'product_id': null,
        'unit_id': null,
        'quantity': 0,
      });
    });
  }

  // Remove row
  void _removeRow(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  /// On save => build payload and pop
  void _onSave() {
    final dateStr = _selectedDate == null
        ? null
        : DateFormat('yyyy-MM-dd').format(_selectedDate!);

    final payload = {
      'document_date': dateStr,
      'doc_type': 'write_off',
      'items': _items,
    };

    Navigator.of(context).pop(payload);
  }
}
