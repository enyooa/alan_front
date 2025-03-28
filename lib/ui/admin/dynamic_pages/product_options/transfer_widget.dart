import 'package:alan/bloc/blocs/admin_page_blocs/blocs/transfer_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/product_subcard_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/transfer_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/warehouse_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/transfer_state.dart';

import 'package:alan/bloc/blocs/common_blocs/events/unit_event.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// BLoCs
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/product_subcard_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/warehouse_bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/blocs/unit_bloc.dart';



import 'package:alan/bloc/blocs/admin_page_blocs/states/product_subcard_state.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/warehouse_state.dart';
import 'package:alan/bloc/blocs/common_blocs/states/unit_state.dart';

// Styles
import 'package:alan/constant.dart';


class ProductTransferPage extends StatefulWidget {
  final VoidCallback? onClose;
  const ProductTransferPage({Key? key, this.onClose}) : super(key: key);

  @override
  State<ProductTransferPage> createState() => _ProductTransferPageState();
}

class _ProductTransferPageState extends State<ProductTransferPage> {
  // user picks "from warehouse" / "to warehouse" / date
  int? _sourceWhId;
  int? _destWhId;
  DateTime? _selectedDate;

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
    // fetch needed data
    context.read<WarehouseBloc>().add(FetchWarehousesEvent());
    context.read<UnitBloc>().add(FetchUnitsEvent());
    context.read<ProductSubCardBloc>().add(FetchProductSubCardsEvent());
    // ... no leftover logic here unless you want to do it
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Перемещение', style: headingStyle),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              // Child does the pop
              Navigator.of(context).pop();
            },
          )
        ],
      ),
      body: BlocListener<ProductTransferBloc, ProductTransferState>(
        listener: (context, state) {
          if (state is ProductTransferCreated) {
            // show success
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // pop the sheet
            Navigator.of(context).pop();
            widget.onClose?.call();
          } else if (state is ProductTransferError) {
            // show error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: pagePadding,
          child: Column(
            children: [
              _buildWarehouseSelectors(),
              const SizedBox(height: 16),
              _buildProductTable(),
              const SizedBox(height: 16),
              ElevatedButton(
                style: elevatedButtonStyle,
                onPressed: _saveTransfer,
                child: const Text('Сохранить перемещение', style: buttonTextStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarehouseSelectors() {
    return Row(
      children: [
        Expanded(child: _buildSourceWhDropdown()),
        const SizedBox(width: 8),
        Expanded(child: _buildDestWhDropdown()),
        const SizedBox(width: 8),
        Expanded(child: _buildDatePicker()),
      ],
    );
  }

  Widget _buildSourceWhDropdown() {
    return BlocBuilder<WarehouseBloc, WarehouseState>(
      builder: (context, state) {
        if (state is WarehouseLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is WarehouseError) {
          return Text('Ошибка: ${state.message}', style: bodyTextStyle);
        } else if (state is WarehouseLoaded) {
          final items = state.warehouses.map<DropdownMenuItem<int>>((w) {
            return DropdownMenuItem<int>(
              value: w['id'],
              child: Text(w['name'] ?? 'NoName', style: bodyTextStyle),
            );
          }).toList();

          return DropdownButtonFormField<int>(
            value: _sourceWhId,
            onChanged: (val) => setState(() => _sourceWhId = val),
            items: items,
            decoration: InputDecoration(
              labelText: 'Откуда (склад)',
              labelStyle: formLabelStyle,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
        return const Text('Загрузка складов...', style: bodyTextStyle);
      },
    );
  }

  Widget _buildDestWhDropdown() {
    return BlocBuilder<WarehouseBloc, WarehouseState>(
      builder: (context, state) {
        if (state is WarehouseLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is WarehouseError) {
          return Text('Ошибка: ${state.message}', style: bodyTextStyle);
        } else if (state is WarehouseLoaded) {
          final items = state.warehouses.map<DropdownMenuItem<int>>((w) {
            return DropdownMenuItem<int>(
              value: w['id'],
              child: Text(w['name'] ?? 'NoName', style: bodyTextStyle),
            );
          }).toList();

          return DropdownButtonFormField<int>(
            value: _destWhId,
            onChanged: (val) => setState(() => _destWhId = val),
            items: items,
            decoration: InputDecoration(
              labelText: 'Куда (склад)',
              labelStyle: formLabelStyle,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
        return const Text('Загрузка складов...', style: bodyTextStyle);
      },
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() => _selectedDate = picked);
        }
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal:8.0, vertical:10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedDate == null
                  ? 'Дата'
                  : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                style: bodyTextStyle,
              ),
              const Icon(Icons.calendar_today, size:16, color:Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductTable() {
    return BlocBuilder<ProductSubCardBloc, ProductSubCardState>(
      builder: (context, state) {
        if (state is ProductSubCardLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProductSubCardError) {
          return Text('Ошибка товаров: ${state.message}', style: bodyTextStyle);
        } else if (state is ProductSubCardsLoaded) {
          final subcards = state.productSubCards;

          return BlocBuilder<UnitBloc, UnitState>(
            builder: (context, unitState) {
              if (unitState is UnitLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (unitState is UnitFetchedSuccess) {
                final units = unitState.units;
                return _buildProductTableBody(subcards, units);
              }
              return const Text('Ошибка ед. изм', style: bodyTextStyle);
            },
          );
        }
        return const Text('Загрузка товаров...', style: bodyTextStyle);
      },
    );
  }

  Widget _buildProductTableBody(List<dynamic> subcards, List<dynamic> units) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color:borderColor),
      ),
      child: Padding(
        padding: elementPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment:MainAxisAlignment.spaceBetween, children:[
              Text('Товары для перемещения', style: subheadingStyle),
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
            ]),
            const SizedBox(height:8),

            SingleChildScrollView(
              scrollDirection:Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(primaryColor),
                columns: const [
                  DataColumn(label: Text('Товар', style: tableHeaderStyle)),
                  DataColumn(label: Text('Кол-во', style: tableHeaderStyle)),
                  DataColumn(label: Text('Ед. изм', style: tableHeaderStyle)),
                  DataColumn(label: Text('Удалить', style: tableHeaderStyle)),
                ],
                rows: List.generate(_productRows.length, (index){
                  final row = _productRows[index];
                  return DataRow(cells:[
                    // product_subcard_id
                    DataCell(
                      DropdownButton<int>(
                        value: row['product_subcard_id'],
                        underline: const SizedBox(),
                        isExpanded:true,
                        style: tableCellStyle,
                        items: subcards.map<DropdownMenuItem<int>>((sc){
                          return DropdownMenuItem<int>(
                            value:sc['id'],
                            child: Text(sc['name']??'NoName', style: tableCellStyle),
                          );
                        }).toList(),
                        onChanged:(val){
                          setState(()=> row['product_subcard_id']=val);
                        },
                      ),
                    ),
                    // quantity
                    DataCell(
                      SizedBox(
                        width:60,
                        child: TextField(
                          style:tableCellStyle,
                          keyboardType:TextInputType.number,
                          decoration: const InputDecoration(
                            border:InputBorder.none,
                            hintText:'0',
                          ),
                          onChanged:(val){
                            setState(()=> row['quantity']=double.tryParse(val)??0.0);
                          },
                        ),
                      ),
                    ),
                    // unit_measurement
                    DataCell(
                      DropdownButton<String>(
                        value: row['unit_measurement'],
                        underline:const SizedBox(),
                        isExpanded:true,
                        style:tableCellStyle,
                        items: units.map<DropdownMenuItem<String>>((u){
                          return DropdownMenuItem<String>(
                            value:u['name'],
                            child: Text(u['name'], style:tableCellStyle),
                          );
                        }).toList(),
                        onChanged:(val){
                          setState(()=> row['unit_measurement']=val);
                        },
                      ),
                    ),
                    // remove
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete, color:Colors.red),
                        onPressed:(){
                          setState(()=>_productRows.removeAt(index));
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

  void _saveTransfer() {
    // validations
    if (_sourceWhId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Укажите склад 'откуда'")),
      );
      return;
    }
    if (_destWhId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Укажите склад 'куда'")),
      );
      return;
    }
    if (_sourceWhId == _destWhId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Нельзя перемещать в тот же самый склад.")),
      );
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Укажите дату перемещения")),
      );
      return;
    }
    if (_productRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Нет строк для перемещения")),
      );
      return;
    }

    // build final payload
    final docDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final productList = _productRows.map((r){
      return {
        'product_subcard_id': r['product_subcard_id']??0,
        'quantity': r['quantity']??0.0,
        'unit_measurement': r['unit_measurement']??'',
      };
    }).toList();

    final payload = {
      'source_warehouse_id': _sourceWhId,
      'destination_warehouse_id': _destWhId,
      'document_date': docDate,
      'products': productList,
    };

    context.read<ProductTransferBloc>().add(
      CreateBulkProductTransferEvent(payload: payload),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Сохранение перемещения...')),
    );
  }
}
