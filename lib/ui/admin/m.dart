import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class EditableTablePage extends StatefulWidget {
  @override
  _EditableTablePageState createState() => _EditableTablePageState();
}

class _EditableTablePageState extends State<EditableTablePage> {
  // Sample data, replace with data fetched from API
  List<Map<String, dynamic>> tableData = List.generate(10, (index) {
    return {
      'name': 'Item $index',
      'unit': 'шт',  // default unit
      'quantity': '', // editable
      'price': '',    // editable
      'sum': ''       // calculated based on quantity * price
    };
  });

  // Available units
  final List<String> units = ['шт', 'кг', 'л']; // replace with actual unit list if necessary

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editable Table'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Table(
                border: TableBorder.all(color: Colors.grey),
                columnWidths: {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(),
                  2: FlexColumnWidth(),
                  3: FlexColumnWidth(),
                  4: FlexColumnWidth(),
                },
                children: [
                  // Header row
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey.shade300),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('наименование', textAlign: TextAlign.center),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('ед изм', textAlign: TextAlign.center),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('кол во', textAlign: TextAlign.center),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('цена', textAlign: TextAlign.center),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('сумма', textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                  // Data rows with editable fields
                  for (var item in tableData)
                    TableRow(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(item['name']),
                        ),
                        // Dropdown for unit selection
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: DropdownButtonFormField<String>(
                            value: item['unit'],
                            items: units.map((String unit) {
                              return DropdownMenuItem<String>(
                                value: unit,
                                child: Text(unit),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                item['unit'] = newValue;
                              });
                            },
                          ),
                        ),
                        // Editable quantity field
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: TextFormField(
                            initialValue: item['quantity'],
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                item['quantity'] = value;
                                _calculateSum(item);
                              });
                            },
                          ),
                        ),
                        // Editable price field
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: TextFormField(
                            initialValue: item['price'],
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                item['price'] = value;
                                _calculateSum(item);
                              });
                            },
                          ),
                        ),
                        // Sum field (calculated)
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(item['sum']),
                        ),
                      ],
                    ),
                  // Total row
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Итого', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Text(''),
                      Text(''),
                      Text(''),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(_calculateTotalSum()),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitData, // Method to send data back to the backend
                child: Text('Submit Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to calculate sum for each row
  void _calculateSum(Map<String, dynamic> item) {
    final quantity = double.tryParse(item['quantity'] ?? '0') ?? 0;
    final price = double.tryParse(item['price'] ?? '0') ?? 0;
    item['sum'] = (quantity * price).toStringAsFixed(2);
  }

  // Method to calculate total sum of all rows
  String _calculateTotalSum() {
    double total = tableData.fold(0, (sum, item) {
      final itemSum = double.tryParse(item['sum'] ?? '0') ?? 0;
      return sum + itemSum;
    });
    return total.toStringAsFixed(2);
  }

  // Method to submit data to the backend
  void _submitData() {
    // Here you would send `tableData` to the backend
    // e.g., using HTTP POST request
    print('Submitting data: $tableData');
  }
}
