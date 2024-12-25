import 'package:cash_control/constant.dart';
import 'package:cash_control/ui/admin/dynamic_pages/form_pages/address_page.dart';
import 'package:cash_control/ui/admin/dynamic_pages/form_pages/provider_form_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cash_control/ui/admin/dynamic_pages/form_pages/employee_form_page.dart';
import 'package:cash_control/ui/admin/dynamic_pages/form_pages/organization_form_page.dart';
import 'package:cash_control/ui/admin/dynamic_pages/form_pages/product_card_page.dart';
import 'package:cash_control/ui/admin/dynamic_pages/form_pages/subproduct_card_page.dart';
import 'package:cash_control/ui/admin/dynamic_pages/form_pages/unit_form_page.dart';

class DynamicFormPage extends StatefulWidget {
  @override
  _DynamicFormPageState createState() => _DynamicFormPageState();
}

class _DynamicFormPageState extends State<DynamicFormPage> {
  String? selectedOption;

  final List<Map<String, dynamic>> formOptions = [
    {'label': 'Сотрудника', 'icon': FontAwesomeIcons.userTie},
    {'label': 'Карточка товара', 'icon': FontAwesomeIcons.boxOpen},
    {'label': 'Подкарточка', 'icon': FontAwesomeIcons.clipboardList},
    // {'label': 'Поставщик товара', 'icon': FontAwesomeIcons.truck},
    {'label': 'Поставщик', 'icon': FontAwesomeIcons.truckArrowRight},

    {'label': 'Ед изм', 'icon': FontAwesomeIcons.balanceScale},
    {'label': 'Адрес', 'icon': FontAwesomeIcons.addressBook},
    
  ];

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
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedOption,
                    hint: Row(
                      children: const [
                        FaIcon(FontAwesomeIcons.handPointDown, size: 16, color: primaryColor),
                        SizedBox(width: 8),
                        Text('Выберите опцию', style: subheadingStyle),
                      ],
                    ),
                    items: formOptions.map((option) {
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
                      labelText: 'Опции формы',
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
                  onPressed: selectedOption != null
                      ? () {
                          // Add creation logic here, if needed
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                  child: const Text("Создать", style: buttonTextStyle),
                ),
              ],
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
        return ProductCardPage();
      case 'Подкарточка':
        return ProductSubCardPage();
      // case 'Поставщик товара':
      //   return OrganizationFormPage();
      case 'Поставщик':
        return ProviderPage();
      case 'Ед изм':
        return UnitFormPage();
      case 'Адрес':
        return AddressPage();
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
