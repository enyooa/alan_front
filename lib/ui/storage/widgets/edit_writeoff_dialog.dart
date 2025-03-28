import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alan/constant.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/blocs/write_off_bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/events/write_off_event.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/write_off_state.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/blocs/storage_references_bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/storage_references_state.dart';

class EditWriteOffDialog extends StatefulWidget {
  final int docId;
  const EditWriteOffDialog({Key? key, required this.docId}) : super(key: key);

  @override
  State<EditWriteOffDialog> createState() => _EditWriteOffDialogState();
}

class _EditWriteOffDialogState extends State<EditWriteOffDialog> {
  // ADD THIS FIELD:
  int? _fromWarehouseId;

  // Header field: document date
  String _documentDate = '';

  // Document items (list of write-off items)
  List<Map<String, dynamic>> _itemRows = [];

  // References for dropdowns: only products and units
  List<dynamic> _products = [];
  List<dynamic> _units = [];

  // UI state
  bool _isSubmitting = false;
  String _feedbackMessage = '';

  @override
  void initState() {
    super.initState();
    // Request the single write-off document.
    context.read<WriteOffBloc>().add(FetchSingleWriteOffEvent(docId: widget.docId));
    // Load references from StorageReferencesBloc.
    final refState = context.read<StorageReferencesBloc>().state;
    if (refState is StorageReferencesLoaded) {
      _products = refState.productSubCards;
      _units = refState.unitMeasurements;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16.0),
      child: BlocConsumer<WriteOffBloc, WriteOffState>(
        listener: (context, state) {
          if (state is WriteOffLoading) {
            setState(() => _isSubmitting = true);
          }
          // When the single document is loaded, initialize local state.
          if (state is WriteOffSingleLoaded) {
            setState(() => _isSubmitting = false);
            _initializeFromState(state);
          }
          if (state is WriteOffUpdated) {
            setState(() {
              _isSubmitting = false;
              _feedbackMessage = state.message;
            });
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.of(context).pop();
            });
          }
          if (state is WriteOffError) {
            setState(() {
              _isSubmitting = false;
              _feedbackMessage = state.message;
            });
          }
        },
        builder: (context, state) {
          // Show a loading indicator only if we haven't loaded doc items yet
          if (state is WriteOffLoading && _itemRows.isEmpty) {
            return const SizedBox(
              width: 400,
              height: 400,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _buildContent();
        },
      ),
    );
  }

  Widget _buildContent() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Редактировать списание (ID: ${widget.docId})', style: headingStyle),
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
          ],
        ),
      ),
      bottomNavigationBar: _buildFooter(),
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
            SizedBox(
              width: 180,
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Дата',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: _documentDate),
                onChanged: (val) {
                  _documentDate = val;
                },
              ),
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
                Text('Позиции для списания', style: subheadingStyle),
                const Spacer(),
                ElevatedButton(
                  style: elevatedButtonStyle,
                  onPressed: _addItemRow,
                  child: const Text('➕ Добавить строку'),
                ),
              ],
            ),
            const SizedBox(height: verticalPadding),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(primaryColor),
                columns: const [
                  DataColumn(label: Text('Товар', style: tableHeaderStyle)),
                  DataColumn(label: Text('Кол-во', style: tableHeaderStyle)),
                  DataColumn(label: Text('Ед.изм', style: tableHeaderStyle)),
                  DataColumn(label: Text('Удалить', style: tableHeaderStyle)),
                ],
                rows: List.generate(_itemRows.length, (index) {
                  final row = _itemRows[index];
                  return DataRow(
                    cells: [
                      DataCell(
                        DropdownButton<int>(
  value: (_products.isNotEmpty &&
          row['selectedProductIndex'] != null &&
          row['selectedProductIndex'] < _products.length)
        ? row['selectedProductIndex']
        : null,
  hint: const Text('— Товар —'),
  items: List.generate(_products.length, (pIndex) {
    final product = _products[pIndex];
    return DropdownMenuItem<int>(
      value: pIndex,
      child: Text(product['name'].toString(), style: bodyTextStyle),
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
                      DataCell(
                        SizedBox(
                          width: 70,
                          child: TextFormField(
                            initialValue: row['quantity'].toString(),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) {
                              setState(() {
                                row['quantity'] = double.tryParse(val) ?? 0.0;
                              });
                            },
                          ),
                        ),
                      ),
                      DataCell(
                        DropdownButton<String>(
  value: _units.any((u) => u['name'] == row['unit_measurement'])
         ? row['unit_measurement']
         : null,
  hint: const Text('— Ед.изм —'),
  items: _units.map<DropdownMenuItem<String>>((u) {
    return DropdownMenuItem<String>(
      value: u['name'],
      child: Text(u['name'].toString(), style: bodyTextStyle),
    );
  }).toList(),
  onChanged: (val) {
    setState(() {
      row['unit_measurement'] = val;
    });
  },
),

),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.delete, color: errorColor),
                          onPressed: () => _removeItemRow(index),
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
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      height: 60,
      child: Row(
        children: [
          ElevatedButton(
            style: elevatedButtonStyle,
            onPressed: _isSubmitting ? null : _saveDocument,
            child: Text(
              _isSubmitting ? 'Сохранение...' : 'Сохранить',
              style: buttonTextStyle,
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: unselectednavbar),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена', style: buttonTextStyle),
          ),
          const Spacer(),
          if (_feedbackMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(_feedbackMessage, style: buttonTextStyle),
            ),
        ],
      ),
    );
  }

  void _initializeFromState(WriteOffSingleLoaded state) {
    final doc = state.document;

    // NOW WE CAN USE _fromWarehouseId WITHOUT ERROR:
    _fromWarehouseId = doc['from_warehouse_id'];

    if (doc['document_date'] != null && doc['document_date'].length >= 10) {
      _documentDate = doc['document_date'].substring(0, 10);
    }
    final items = doc['document_items'] as List<dynamic>? ?? [];
    _itemRows = items.map<Map<String, dynamic>>((item) {
      var row = {
        '_key': item['id'],
        'id': item['id'],
        'product_subcard_id': item['product_subcard_id'],
        'quantity': item['quantity'] ?? 0.0,
        'unit_measurement': item['unit_measurement'] ?? '',
      };
      if (row['product_subcard_id'] != null && _products.isNotEmpty) {
        final index = _products.indexWhere((p) => p['id'] == row['product_subcard_id']);
        if (index != -1) {
          row['selectedProductIndex'] = index;
        }
      }
      return row;
    }).toList();

    // If the state provides reference data, you can read them here:
    if (state.products != null) _products = state.products!;
    if (state.units != null) _units = state.units!;
  }

  void _addItemRow() {
    setState(() {
      _itemRows.add({
        '_key': DateTime.now().millisecondsSinceEpoch,
        'id': null,
        'product_subcard_id': null,
        'selectedProductIndex': null,
        'quantity': 0.0,
        'unit_measurement': '',
      });
    });
  }

  void _removeItemRow(int index) {
    setState(() {
      _itemRows.removeAt(index);
    });
  }

  void _saveDocument() {
    setState(() {
      _isSubmitting = true;
      _feedbackMessage = '';
    });
    final itemsPayload = _itemRows.map((row) {
      return {
        'id': row['id'],
        'product_subcard_id': row['product_subcard_id'],
        'quantity': row['quantity'],
        'unit_measurement': row['unit_measurement'],
      };
    }).toList();
    final payload = {
      'from_warehouse_id': _fromWarehouseId, // now valid
      'document_date': _documentDate,
      'document_items': itemsPayload,
        'document_type': 'writeOff', // <-- include this if your backend uses it

    };
    context.read<WriteOffBloc>().add(UpdateWriteOffEvent(docId: widget.docId, updatedData: payload));
  }
}
