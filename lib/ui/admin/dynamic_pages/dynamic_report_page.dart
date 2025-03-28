import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Здесь импортируем сами страницы-отчёты
import 'package:alan/ui/admin/dynamic_pages/report_pages/cashbox_report.dart';
import 'package:alan/ui/admin/dynamic_pages/report_pages/storage_report.dart';
import 'package:alan/ui/admin/dynamic_pages/report_pages/debts_report.dart';
import 'package:alan/ui/admin/dynamic_pages/report_pages/sales_report.dart';

// Для примера определим стиль текста и цвет, 
// чтобы было похоже на ваш код
const TextStyle headingStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
const TextStyle subheadingStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
const TextStyle bodyTextStyle = TextStyle(fontSize: 14);
const TextStyle formLabelStyle = TextStyle(fontSize: 14, color: Colors.grey);
const Color primaryColor = Colors.blue;

class DynamicReportPage extends StatefulWidget {
  const DynamicReportPage({Key? key}) : super(key: key);

  @override
  _DynamicReportPageState createState() => _DynamicReportPageState();
}

class _DynamicReportPageState extends State<DynamicReportPage> {
  String? selectedOption;

  // Список вариантов для Dropdown
  final List<Map<String, dynamic>> reportOptions = [
    {
      'label': 'Отчет по кассе',
      'icon': FontAwesomeIcons.cashRegister,
      'page':  CashboxReportPage(),
    },
    {
      'label': 'Отчет по складу',
      'icon': FontAwesomeIcons.warehouse,
      'page': const StorageReportPage(),
    },
    {
      'label': 'Отчет по долгам',
      'icon': FontAwesomeIcons.moneyBillTransfer,
      'page': const DebtsReportPage(),
    },
    {
      'label': 'Отчет по продажам',
      'icon': FontAwesomeIcons.chartLine,
      'page': const SalesReportPage(),
    },
  ];

  // Метод, возвращающий нужную страницу
  Widget _buildSelectedPage() {
    final selectedPage = reportOptions.firstWhere(
      (option) => option['label'] == selectedOption,
      orElse: () => {
        'page': const Center(
          child: Text('Выберите отчет из списка', style: bodyTextStyle),
        ),
      },
    )['page'];

    // Если ничего не выбрано, вернётся дефолтный Center(...)
    return selectedPage ?? const Center(
      child: Text('Выберите отчет из списка', style: bodyTextStyle),
    );
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
            // Dropdown для выбора отчёта
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

            // Здесь показываем выбранную страницу
            Expanded(
              child: _buildSelectedPage(),
            ),
          ],
        ),
      ),
    );
  }
}
