import 'package:cash_control/ui/cashbox/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class CalculationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CashboxAppbar(title: "Расчеты"),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Filter Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text('Дата с по', style: TextStyle(color: Colors.black)),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: DropdownButton<String>(
                    underline: SizedBox(),
                    hint: Text('Выбор счета'),
                    items: ['Счет 1', 'Счет 2', 'Счет 3']
                        .map((String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                    onChanged: (value) {},
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[400],
                  ),
                  child: Text('сформировать',style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            Divider(),
            // Table Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              color: Colors.grey[300],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Контрагент', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('сумма', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // Table Data Rows
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Контрагент $index'),
                        Text('0.00'),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Export Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.table_chart, color: Colors.blue[400]),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.picture_as_pdf, color: Colors.blue[400]),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar
        );
  }
}
