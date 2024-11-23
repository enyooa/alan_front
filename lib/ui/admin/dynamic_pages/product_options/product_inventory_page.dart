import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cash_control/constant.dart';

class ProductInventoryPage extends StatefulWidget {
  @override
  _ProductInventoryPageState createState() => _ProductInventoryPageState();
}

class _ProductInventoryPageState extends State<ProductInventoryPage> {
  String selectedReport = 'Склад';

  final List<Map<String, dynamic>> reportOptions = [
    {'label': 'Склад', 'icon': FontAwesomeIcons.warehouse},
    {'label': 'Информация о складовщике', 'icon': FontAwesomeIcons.user},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Инвентаризация склада',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade300, // AppBar background color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedReport,
                    items: reportOptions.map((report) {
                      return DropdownMenuItem<String>(
                        value: report['label'],
                        child: Row(
                          children: [
                            FaIcon(report['icon'], size: 16, color: primaryColor),
                            const SizedBox(width: 8),
                            Text(report['label'], style: bodyTextStyle),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedReport = value!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Выберите отчет',
                      labelStyle: formLabelStyle,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    style: bodyTextStyle,
                    dropdownColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Add logic for generating the selected report
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                  child: const Text("Сформировать", style: buttonTextStyle),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: selectedReport == 'Склад'
                  ? _buildInventoryTable()
                  : _buildInventoryManagerTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("Склад", style: titleStyle),
        const SizedBox(height: 10),
        Table(
          border: TableBorder.all(color: borderColor),
          children: [
            TableRow(
              decoration: BoxDecoration(color: primaryColor.withOpacity(0.2)),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Наименование', style: tableHeaderStyle),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Ед изм', style: tableHeaderStyle),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Кол-во', style: tableHeaderStyle),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Цена', style: tableHeaderStyle),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Сумма', style: tableHeaderStyle),
                ),
              ],
            ),
            TableRow(
              children: List.generate(
                5,
                (index) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('-', style: bodyTextStyle),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInventoryManagerTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("Информация о складовщике", style: titleStyle),
        const SizedBox(height: 10),
        Table(
          border: TableBorder.all(color: borderColor),
          children: [
            TableRow(
              decoration: BoxDecoration(color: primaryColor.withOpacity(0.2)),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Имя складовщика', style: tableHeaderStyle),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Адрес складовщика', style: tableHeaderStyle),
                ),
              ],
            ),
            TableRow(
              children: List.generate(
                2,
                (index) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('-', style: bodyTextStyle),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
