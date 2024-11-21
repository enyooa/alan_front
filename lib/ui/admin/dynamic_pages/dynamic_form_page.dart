import 'package:cash_control/constant.dart';
import 'package:flutter/material.dart';
import 'package:cash_control/ui/admin/form_pages/employee_form_page.dart';
import 'package:cash_control/ui/admin/form_pages/organization_form_page.dart';
import 'package:cash_control/ui/admin/form_pages/product_form_page.dart';
import 'package:cash_control/ui/admin/form_pages/subproduct_form_page.dart';
import 'package:cash_control/ui/admin/form_pages/unit_form_page.dart';

class DynamicFormPage extends StatefulWidget {
  @override
  _DynamicFormPageState createState() => _DynamicFormPageState();
}

class _DynamicFormPageState extends State<DynamicFormPage> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Справка', style: headingStyle),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedOption,
              hint: const Text(
                'Выберите опцию',
                style: subheadingStyle,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Сотрудника',
                  child: Text('Сотрудника', style: bodyTextStyle),
                ),
                DropdownMenuItem(
                  value: 'Карточка товара',
                  child: Text('Карточка товара', style: bodyTextStyle),
                ),
                DropdownMenuItem(
                  value: 'Подкарточка',
                  child: Text('Подкарточка', style: bodyTextStyle),
                ),
                DropdownMenuItem(
                  value: 'Поставщик товара',
                  child: Text('Поставщик товара', style: bodyTextStyle),
                ),
                DropdownMenuItem(
                  value: 'Ед изм',
                  child: Text('Единица измерения', style: bodyTextStyle),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedOption = value;
                });
              },
              style: bodyTextStyle,
              dropdownColor: Colors.white,
              iconEnabledColor: primaryColor,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    switch (selectedOption) {
      case 'Сотрудника':
        return EmployeeFormPage();
      case 'Карточка товара':
        return ProductFormPage();
      case 'Подкарточка':
        return SubProductFormPage();
      case 'Поставщик товара':
        return OrganizationFormPage();
      case 'Ед изм':
        return UnitFormPage();
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
