import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alan/bloc/blocs/storage_page_blocs/blocs/storage_sales_bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/events/storage_sales_event.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/storage_sales_state.dart';

// Import your constants
import 'package:alan/constant.dart';

class StoragerSalePage extends StatefulWidget {
  const StoragerSalePage({Key? key}) : super(key: key);

  @override
  State<StoragerSalePage> createState() => _StoragerSalePageState();
}

class _StoragerSalePageState extends State<StoragerSalePage> {
  String? selectedClientId;
  String? selectedAddressId;
  DateTime? selectedDate;

  /// Rows for the product table
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    context.read<SalesStorageBloc>().add(FetchSalesStorageData());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SalesStorageBloc, SalesStorageState>(
      listener: (context, state) {
        if (state is SalesStorageSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message, style: bodyTextStyle)),
          );
          // Clear
          setState(() {
            products.clear();
            selectedClientId = null;
            selectedAddressId = null;
            selectedDate = null;
          });
        } else if (state is SalesStorageError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${state.error}", style: bodyTextStyle)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text("Продажа", style: headingStyle),
          backgroundColor: primaryColor,
          elevation: 2,
        ),
        body: BlocBuilder<SalesStorageBloc, SalesStorageState>(
          builder: (context, state) {
            if (state is SalesStorageLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SalesStorageLoaded) {
              return _buildMainContent(state);
            } else if (state is SalesStorageError) {
              return Center(child: Text("Ошибка: ${state.error}", style: bodyTextStyle));
            } else {
              // initial or empty
              return const Center(child: Text("Waiting for data...", style: bodyTextStyle));
            }
          },
        ),
      ),
    );
  }

  Widget _buildMainContent(SalesStorageLoaded state) {
    final clients = state.clients; 
    final subCards = state.productSubCards;
    final units = state.unitMeasurements;

    return SingleChildScrollView(
      padding: pagePadding,
      child: Column(
        children: [
          // Card for client/address/date
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 2,
            child: Padding(
              padding: elementPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Данные клиента", style: subheadingStyle),
                  const SizedBox(height: 8),
                  _buildClientDropdown(clients),
                  const SizedBox(height: 12),
                  _buildAddressDropdown(clients),
                  const SizedBox(height: 12),
                  _buildDatePicker(),
                ],
              ),
            ),
          ),

          const SizedBox(height: verticalPadding),

          // Product table card
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 2,
            child: Padding(
              padding: elementPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Таблица продуктов", style: subheadingStyle),
                  const SizedBox(height: 8),
                  _buildProductTable(subCards, units),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: const Icon(Icons.add, color: primaryColor),
                      label: Text("Добавить строку", style: bodyTextStyle.copyWith(color: primaryColor)),
                      onPressed: _addProductRow,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: verticalPadding),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: elevatedButtonStyle,
              onPressed: _submitData,
              child: const Text("Сохранить", style: buttonTextStyle),
            ),
          ),
        ],
      ),
    );
  }

  // Build client dropdown
  Widget _buildClientDropdown(List<dynamic> clients) {
    return DropdownButtonFormField<String>(
      value: selectedClientId,
      decoration: InputDecoration(
        labelText: "Клиент",
        labelStyle: formLabelStyle,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: clients.map<DropdownMenuItem<String>>((client) {
        final clientName = "${client['first_name']} ${client['last_name']}";
        return DropdownMenuItem(
          value: client['id'].toString(),
          child: Text(clientName, style: bodyTextStyle),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedClientId = value;
          selectedAddressId = null; // reset address
        });
      },
    );
  }

  // Build address dropdown
  Widget _buildAddressDropdown(List<dynamic> clients) {
    if (selectedClientId == null) {
      return const Text("Сначала выберите клиента", style: bodyTextStyle);
    }

    final client = clients.firstWhere(
      (c) => c['id'].toString() == selectedClientId,
      orElse: () => null,
    );
    if (client == null) {
      return const Text("Не найден клиент", style: bodyTextStyle);
    }

    final addresses = client['addresses'] as List<dynamic>? ?? [];
    if (addresses.isEmpty) {
      return const Text("У клиента нет сохраненных адресов", style: bodyTextStyle);
    }

    return DropdownButtonFormField<String>(
      value: selectedAddressId,
      decoration: InputDecoration(
        labelText: "Адрес",
        labelStyle: formLabelStyle,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: addresses.map<DropdownMenuItem<String>>((addr) {
        return DropdownMenuItem(
          value: addr['id'].toString(),
          child: Text(addr['name'], style: bodyTextStyle),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedAddressId = value;
        });
      },
    );
  }

  // Build date picker
  Widget _buildDatePicker() {
    return InkWell(
      onTap: _pickDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: "Дата",
          labelStyle: formLabelStyle,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          selectedDate == null
              ? "Выберите дату"
              : "${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year}",
          style: bodyTextStyle,
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Build the product table using DataTable
  Widget _buildProductTable(List<dynamic> subCards, List<dynamic> units) {
    if (products.isEmpty) {
      return const Text(
        "Нет товаров. Нажмите 'Добавить строку' чтобы добавить товары.",
        style: bodyTextStyle,
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: <DataColumn>[
          DataColumn(label: Text("Подкарточка", style: tableHeaderStyle)),
          DataColumn(label: Text("Ед.изм.", style: tableHeaderStyle)),
          DataColumn(label: Text("Кол-во", style: tableHeaderStyle)),
          DataColumn(label: Text("Цена", style: tableHeaderStyle)),
          DataColumn(label: Text("Сумма", style: tableHeaderStyle)),
          DataColumn(label: Text("Удалить", style: tableHeaderStyle)),
        ],
        // optional stylings
        columnSpacing: 20.0,
        horizontalMargin: 10.0,
        dataRowColor: MaterialStateProperty.all(Colors.white),
        headingRowColor: MaterialStateProperty.all(primaryColor),
        border: TableBorder.all(color: borderColor),
        rows: List<DataRow>.generate(products.length, (index) {
          final row = products[index];
          final subcardId = row['product_subcard_id'];
          final unit = row['unit_measurement'];
          final quantity = row['quantity'] ?? 0;
          final price = row['price'] ?? 0;
          final sum = quantity * price;

          return DataRow(
            cells: [
              DataCell(_buildSubcardDropdown(subCards, subcardId, (val) {
                setState(() {
                  row['product_subcard_id'] = val;
                });
              })),
              DataCell(_buildUnitDropdown(units, unit, (val) {
                setState(() {
                  row['unit_measurement'] = val;
                });
              })),
              DataCell(_buildNumberCell(quantity.toString(), (val) {
                setState(() {
                  row['quantity'] = int.tryParse(val) ?? 0;
                });
              })),
              DataCell(_buildNumberCell(price.toString(), (val) {
                setState(() {
                  row['price'] = int.tryParse(val) ?? 0;
                });
              })),
              DataCell(Text("$sum", style: tableCellStyle)),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.delete, color: errorColor),
                  onPressed: () {
                    setState(() {
                      products.removeAt(index);
                    });
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// Helper to add a new product row
  void _addProductRow() {
    setState(() {
      products.add({
        'product_subcard_id': null,
        'unit_measurement': null,
        'quantity': 0,
        'price': 0,
      });
    });
  }

  /// Subcard dropdown cell
  Widget _buildSubcardDropdown(
    List<dynamic> subCards, 
    dynamic currentValue, 
    ValueChanged<dynamic> onChanged,
  ) {
    return DropdownButton<dynamic>(
      value: currentValue,
      hint: const Text("Выберите товар", style: tableCellStyle),
      underline: const SizedBox(),
      items: subCards.map((sc) {
        return DropdownMenuItem(
          value: sc['id'],
          child: Text(sc['name'] ?? "NoName", style: tableCellStyle),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  /// Unit dropdown cell
  Widget _buildUnitDropdown(
    List<dynamic> units,
    dynamic currentValue,
    ValueChanged<dynamic> onChanged,
  ) {
    return DropdownButton<dynamic>(
      value: currentValue,
      hint: const Text("Ед.изм.", style: tableCellStyle),
      underline: const SizedBox(),
      items: units.map((u) {
        return DropdownMenuItem(
          // If you store unit by "id", use u['id']. Otherwise, use u['name']
          value: u['name'],
          child: Text(u['name'] ?? "NoUnit", style: tableCellStyle),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  /// Numeric cell for quantity/price
  Widget _buildNumberCell(String initialValue, ValueChanged<String> onChanged) {
    final controller = TextEditingController(text: initialValue);
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: tableCellStyle,
      decoration: const InputDecoration(border: InputBorder.none),
      onChanged: onChanged,
    );
  }

  /// Submits data
  void _submitData() {
    if (selectedClientId == null || selectedAddressId == null || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Заполните клиента, адрес и дату", style: bodyTextStyle)),
      );
      return;
    }

    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Добавьте хотя бы один товар", style: bodyTextStyle)),
      );
      return;
    }

    final clientId = int.parse(selectedClientId!);
    final addressId = int.parse(selectedAddressId!);

    context.read<SalesStorageBloc>().add(
      SubmitSalesStorageData(
        clientId: clientId,
        addressId: addressId,
        date: selectedDate!,
        products: products,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Отправлено на сервер...", style: bodyTextStyle)),
    );
  }
}
