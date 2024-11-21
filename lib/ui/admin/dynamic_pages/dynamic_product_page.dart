import 'package:cash_control/ui/admin/dynamic_pages/product_options/product_inventory_page.dart';
import 'package:cash_control/ui/admin/dynamic_pages/product_options/product_pricing_page.dart';
import 'package:cash_control/ui/admin/dynamic_pages/product_options/product_receiving_page.dart';
import 'package:cash_control/ui/admin/dynamic_pages/product_options/product_sale_page.dart';
import 'package:flutter/material.dart';
import 'package:cash_control/constant.dart';

class DynamicProductPage extends StatefulWidget {
  @override
  _DynamicProductPageState createState() => _DynamicProductPageState();
}

class _DynamicProductPageState extends State<DynamicProductPage> {
  String selectedOption = 'Ценовое предложение';

  final List<String> options = [
    'Продажа',
    'Ценовое предложение',
    'Склад',
    'Поступление товара',
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
                    items: options.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: bodyTextStyle),
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
                        
                        // borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    style: bodyTextStyle,
                    dropdownColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                if (selectedOption == 'Ценовое предложение')
                  ElevatedButton(
                    onPressed: () {
                      // Add creation logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                    child: const Text("Создать", style: buttonTextStyle),
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
