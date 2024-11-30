import 'package:cash_control/ui/admin/dynamic_pages/product_options/product_inventory_page.dart';
import 'package:cash_control/ui/admin/dynamic_pages/product_options/product_pricing_page.dart';
import 'package:cash_control/ui/admin/dynamic_pages/product_options/product_receiving_page.dart';
import 'package:cash_control/ui/admin/dynamic_pages/product_options/product_sale_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cash_control/constant.dart';

class DynamicProductPage extends StatefulWidget {
  @override
  _DynamicProductPageState createState() => _DynamicProductPageState();
}

class _DynamicProductPageState extends State<DynamicProductPage> {
  String selectedOption = 'Ценовое предложение';

  final List<Map<String, dynamic>> productOptions = [
    {'label': 'Продажа', 'icon': FontAwesomeIcons.cashRegister},
    {'label': 'Ценовое предложение', 'icon': FontAwesomeIcons.tags},
    {'label': 'Склад', 'icon': FontAwesomeIcons.warehouse},
    {'label': 'Поступление товара', 'icon': FontAwesomeIcons.truck},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Товар', style: headingStyle),
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
                    items: productOptions.map((option) {
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
                    onChanged: (newValue) {
                      setState(() {
                        selectedOption = newValue!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Выберите опцию',
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
                if (selectedOption == 'Ценовое предложение')
                  ElevatedButton.icon(
                    onPressed: () {
                      // Add creation logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text("Создать", style: buttonTextStyle),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _getSelectedPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getSelectedPage() {
    switch (selectedOption) {
      case 'Продажа':
        return ProductSalePage();
      case 'Ценовое предложение':
        return ProductPricingPage();
      case 'Склад':
        return ProductInventoryPage();
      case 'Поступление товара':
        return ProductReceivingPage();
      default:
        return const Center(
          child: Text(
            'Выберите опцию из списка',
            style: bodyTextStyle,
          ),
        );
    }
  }
}
