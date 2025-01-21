import 'package:alan/ui/admin/dynamic_pages/report_pages/cashbox_report.dart';
import 'package:alan/ui/admin/dynamic_pages/report_pages/storage_report.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:alan/constant.dart';

class DynamicReportPage extends StatefulWidget {
  @override
  _DynamicReportPageState createState() => _DynamicReportPageState();
}

class _DynamicReportPageState extends State<DynamicReportPage> {
  String? selectedOption;

  final List<Map<String, dynamic>> reportOptions = [
    {'label': 'Отчет по кассе', 'icon': FontAwesomeIcons.cashRegister, 'page': CashboxReportPage()},
    {'label': 'Отчет по складу', 'icon': FontAwesomeIcons.warehouse, 'page': StorageReportPage()},
  ];

  Widget _buildSelectedPage() {
    final selectedPage = reportOptions.firstWhere(
      (option) => option['label'] == selectedOption,
      orElse: () => {'page': const Center(child: Text('Выберите отчет из списка', style: bodyTextStyle))},
    )['page'];

    return selectedPage ?? const Center(child: Text('Выберите отчет из списка', style: bodyTextStyle));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выберите отчет', style: headingStyle),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedOption,
                    hint: Row(
                      children: const [
                        FaIcon(FontAwesomeIcons.handPointDown, size: 16, color: primaryColor),
                        SizedBox(width: 8),
                        Text('Выберите отчет', style: subheadingStyle),
                      ],
                    ),
                    items: reportOptions.map((option) {
                      return DropdownMenuItem<String>(
                        value: option['label'],
                        child: Row(
                          children: [
                            FaIcon(option['icon'], size: 16, color: primaryColor),
                            const SizedBox(width: 8),
                            Text(option['label'], style: bodyTextStyle),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Опции отчета',
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
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildSelectedPage(),
            ),
          ],
        ),
      ),
    );
  }
}
