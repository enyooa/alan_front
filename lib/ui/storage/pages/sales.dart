import 'package:alan/constant.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SalesStoragePage extends StatefulWidget {
  const SalesStoragePage({Key? key}) : super(key: key);

  @override
  State<SalesStoragePage> createState() => _SalesStoragePageState();
}

class _SalesStoragePageState extends State<SalesStoragePage> {
  String? selectedClient;
  String? selectedAddress;
  DateTime? selectedDate;
  List<Map<String, dynamic>> products = [];
  List<dynamic> clients = [];
  List<dynamic> unitMeasurements = [];
  List<dynamic> productSubCards = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }

    final url = Uri.parse(baseUrl + 'getAllInstances');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          clients = data['clients'];
          unitMeasurements = data['unit_measurements'];
          productSubCards = data['product_sub_cards'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch data: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Накладная', style: headingStyle),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: pagePadding,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopTable(),
              const SizedBox(height: verticalPadding),
              _buildEditableTable(
                title: 'Основные Товары',
                rows: products,
                onAddRow: () {
                  setState(() {
                    products.add({
                      'name': null,
                      'unit': null,
                      'quantity': 0,
                      'price': 0,
                    });
                  });
                },
              ),
              const SizedBox(height: verticalPadding),
              _buildFooterButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16.0,
        headingRowColor: MaterialStateProperty.all(primaryColor),
        headingTextStyle: tableHeaderStyle,
        border: TableBorder.all(color: borderColor),
        columns: const [
          DataColumn(label: Text('Название', style: tableHeaderStyle)),
          DataColumn(label: Text('Значение', style: tableHeaderStyle)),
        ],
        rows: [
          _buildEditableRowAsDataTable('Наименование клиента', _buildClientDropdown()),
          _buildEditableRowAsDataTable('Адрес доставки', _buildAddressDropdown()),
          _buildEditableRowAsDataTable('Дата', _buildDatePicker()),
        ],
      ),
    );
  }

  DataRow _buildEditableRowAsDataTable(String label, Widget child) {
    return DataRow(
      cells: [
        DataCell(Text(label, style: bodyTextStyle)),
        DataCell(child),
      ],
    );
  }

  Widget _buildClientDropdown() {
    return DropdownButton<String>(
      value: selectedClient,
      items: clients.map<DropdownMenuItem<String>>((client) {
        return DropdownMenuItem<String>(
          value: client['id'].toString(),
          child: Text(
            "${client['first_name']} ${client['last_name']}",
            style: bodyTextStyle,
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedClient = value;
          selectedAddress = null; // Reset address when client changes
        });
      },
      hint: const Text("Выберите клиента", style: bodyTextStyle),
    );
  }

  Widget _buildAddressDropdown() {
    if (selectedClient == null) return const Text("Сначала выберите клиента", style: bodyTextStyle);

    final client = clients.firstWhere((c) => c['id'].toString() == selectedClient);
    final addresses = client['addresses'] as List;

    return DropdownButton<String>(
      value: selectedAddress,
      items: addresses.map<DropdownMenuItem<String>>((address) {
        return DropdownMenuItem<String>(
          value: address['id'].toString(),
          child: Text(address['name'], style: bodyTextStyle),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedAddress = value;
        });
      },
      hint: const Text("Выберите адрес", style: bodyTextStyle),
    );
  }

  Widget _buildDatePicker() {
    return TextButton(
      onPressed: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          setState(() {
            selectedDate = pickedDate;
          });
        }
      },
      child: Text(
        selectedDate != null
            ? "${selectedDate!.day.toString().padLeft(2, '0')}.${selectedDate!.month.toString().padLeft(2, '0')}.${selectedDate!.year}"
            : 'Выберите дату',
        style: bodyTextStyle,
      ),
    );
  }

  Widget _buildEditableTable({
    required String title,
    required List<Map<String, dynamic>> rows,
    required VoidCallback onAddRow,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: subheadingStyle),
        const SizedBox(height: verticalPadding),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 16.0,
            headingRowColor: MaterialStateProperty.all(primaryColor),
            headingTextStyle: tableHeaderStyle,
            border: TableBorder.all(color: borderColor),
            columns: const [
              DataColumn(label: Text('Наименование товара', style: tableHeaderStyle)),
              DataColumn(label: Text('Ед. изм', style: tableHeaderStyle)),
              DataColumn(label: Text('Кол-во', style: tableHeaderStyle)),
              DataColumn(label: Text('брутто', style: tableHeaderStyle)),
              DataColumn(label: Text('нетто', style: tableHeaderStyle)),

              DataColumn(label: Text('Цена', style: tableHeaderStyle)),
              DataColumn(label: Text('Сумма', style: tableHeaderStyle)),
              DataColumn(label: Text('Удалить', style: tableHeaderStyle)),
            ],
            rows: _buildEditableProductRows(rows),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.add, color: primaryColor),
            label: const Text('Добавить строку', style: TextStyle(color: primaryColor)),
            onPressed: onAddRow,
          ),
        ),
      ],
    );
  }

  List<DataRow> _buildEditableProductRows(List<Map<String, dynamic>> rows) {
    return rows.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, dynamic> row = entry.value;

      return DataRow(
        cells: [
          _buildEditableDropdownCell(row, 'name', productSubCards, 'name'),
          _buildEditableDropdownCell(row, 'unit', unitMeasurements, 'name'),
          _buildEditableTextCell(row, 'quantity'),
          _buildEditableTextCell(row, 'brutto'),
          _buildEditableTextCell(row, 'netto'),
          
          _buildEditableTextCell(row, 'price'),
          DataCell(Text((row['quantity'] * row['price']).toString(), style: bodyTextStyle)),
          DataCell(
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  products.removeAt(index);
                });
              },
            ),
          ),
        ],
      );
    }).toList();
  }

  DataCell _buildEditableDropdownCell(Map<String, dynamic> row, String key, List<dynamic> items, String labelKey) {
    return DataCell(
      DropdownButtonFormField(
        value: row[key],
        items: items.map((item) {
          return DropdownMenuItem(
            value: item['id'],
            child: Text(item[labelKey], style: bodyTextStyle),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            row[key] = value;
          });
        },
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }

  DataCell _buildEditableTextCell(Map<String, dynamic> row, String key) {
    return DataCell(
      TextFormField(
        initialValue: row[key]?.toString() ?? '',
        keyboardType: TextInputType.number,
        style: bodyTextStyle,
        decoration: const InputDecoration(border: InputBorder.none),
        onChanged: (value) {
          setState(() {
            row[key] = int.tryParse(value) ?? 0;
          });
        },
      ),
    );
  }

 Widget _buildFooterButtons() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      ElevatedButton.icon(
        onPressed: _submitSalesStorageData, // Call the submit function
        style: elevatedButtonStyle,
        icon: const Icon(Icons.save),
        label: const Text('Сохранить'),
      ),
      const SizedBox(width: 16.0),
      IconButton(
        onPressed: () {
          // Export to PDF functionality
        },
        icon: const Icon(Icons.picture_as_pdf),
        color: Colors.blue,
        iconSize: 32.0,
      ),
      const SizedBox(width: 16.0),
      IconButton(
        onPressed: () {
          // Export to Excel functionality
        },
        icon: const Icon(Icons.table_chart),
        color: Colors.green,
        iconSize: 32.0,
      ),
    ],
  );
}

Future<void> _submitSalesStorageData() async {
  if (selectedClient == null || selectedAddress == null || selectedDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Пожалуйста, заполните все поля клиента, адреса и даты')),
    );
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Authentication token not found')),
    );
    return;
  }

  final url = Uri.parse(baseUrl + 'storeSales');
  final requestBody = {
    'client_id': int.parse(selectedClient!),
    'address_id': int.parse(selectedAddress!),
    'date': selectedDate!.toIso8601String(),
    'products': products.map((product) {
      return {
        'product_subcard_id': product['name'],
        'unit_measurement_id': product['unit'],
        'quantity': product['quantity'],
        'brutto': product['brutto'],
        'netto': product['netto'],
        'price': product['price'],
      };
    }).toList(),
  };

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Данные успешно сохранены!')),
      );
      setState(() {
        products.clear();
        selectedClient = null;
        selectedAddress = null;
        selectedDate = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сохранения данных: ${response.body}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ошибка: $e')),
    );
  }
}

}
