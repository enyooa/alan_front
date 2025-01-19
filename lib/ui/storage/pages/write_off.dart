import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_control/bloc/blocs/storage_page_blocs/blocs/general_warehouse_bloc.dart';
import 'package:cash_control/bloc/blocs/storage_page_blocs/events/general_warehouse_event.dart';
import 'package:cash_control/bloc/blocs/storage_page_blocs/states/general_warehouse_state.dart';
import 'package:cash_control/constant.dart';

class WriteOffPage extends StatefulWidget {
  const WriteOffPage({Key? key}) : super(key: key);

  @override
  State<WriteOffPage> createState() => _WriteOffPageState();
}

class _WriteOffPageState extends State<WriteOffPage> {
  List<Map<String, dynamic>> writeOffRows = [];
  List<Map<String, dynamic>> generalWarehouses = [];

  @override
  void initState() {
    super.initState();
    _fetchGeneralWarehouses();
  }

  void _fetchGeneralWarehouses() {
    context.read<GeneralWarehouseBloc>().add(FetchGeneralWarehouseEvent());
  }

  void _submitWriteOffData() {
    if (writeOffRows.any((row) =>
        row['product_subcard_id'] == null ||
        row['quantity'] <= 0 ||
        row['quantity'] > row['remaining_quantity'])) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ensure valid quantities are entered for all items.')),
      );
      return;
    }

    final payload = writeOffRows.map((row) {
      return {
        'product_subcard_id': row['product_subcard_id'],
        'quantity': row['quantity'],
      };
    }).toList();

    context.read<GeneralWarehouseBloc>().add(WriteOffGeneralWarehouseEvent(writeOffs: payload));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Write-off submitted successfully.')),
    );

    setState(() {
      writeOffRows.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Списание ТМЗ', style: headingStyle),
      ),
      body: BlocBuilder<GeneralWarehouseBloc, GeneralWarehouseState>(
        builder: (context, state) {
          if (state is GeneralWarehouseLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GeneralWarehouseLoaded) {
            generalWarehouses = state.warehouseData;
            return _buildPageContent();
          } else if (state is GeneralWarehouseError) {
            return Center(child: Text(state.error, style: bodyTextStyle));
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }

  Widget _buildPageContent() {
    return Padding(
      padding: pagePadding,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: writeOffRows.length,
              itemBuilder: (context, index) {
                final row = writeOffRows[index];
                return Card(
                  margin: elementPadding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: borderColor),
                  ),
                  child: Padding(
                    padding: elementPadding,
                    child: Column(
                      children: [
                        DropdownButtonFormField<int>(
                          value: row['product_subcard_id'],
                          items: generalWarehouses.map((warehouse) {
                            return DropdownMenuItem<int>(
                              value: warehouse['product_subcard_id'],
                              child: Text(
                                '${warehouse['product_name']} (Остаток: ${warehouse['quantity']} ${warehouse['unit_measurement']})',
                                style: bodyTextStyle,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              final selectedWarehouse = generalWarehouses
                                  .firstWhere((w) => w['product_subcard_id'] == value);
                              row['product_subcard_id'] = value;
                              row['remaining_quantity'] = selectedWarehouse['quantity'];
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Выберите товар',
                            labelStyle: formLabelStyle,
                            border: OutlineInputBorder(borderSide: tableBorderSide),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        TextFormField(
                          initialValue: row['quantity']?.toString(),
                          onChanged: (value) {
                            setState(() {
                              row['quantity'] = double.tryParse(value) ?? 0.0;
                            });
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Количество',
                            labelStyle: formLabelStyle,
                            border: OutlineInputBorder(borderSide: tableBorderSide),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Остаток: ${row['remaining_quantity'] ?? 'на нуле'}',
                          style: captionStyle,
                        ),
                        const SizedBox(height: 8.0),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: errorColor),
                            onPressed: () {
                              setState(() {
                                writeOffRows.removeAt(index);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                writeOffRows.add({
                  'product_subcard_id': null,
                  'quantity': 0.0,
                  'remaining_quantity': 0.0,
                });
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Добавить товар', style: buttonTextStyle),
            style: elevatedButtonStyle,
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _submitWriteOffData,
            child: const Text('Сохранить', style: buttonTextStyle),
            style: elevatedButtonStyle,
          ),
        ],
      ),
    );
  }
}
