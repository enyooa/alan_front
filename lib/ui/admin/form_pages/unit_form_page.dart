import 'package:flutter/material.dart';
import 'package:cash_control/constant.dart';

class UnitFormPage extends StatefulWidget {
  @override
  _UnitFormPageState createState() => _UnitFormPageState();
}

class _UnitFormPageState extends State<UnitFormPage> {
  final TextEditingController unitNameController = TextEditingController();

  void _saveUnit() {
    final unitName = unitNameController.text.trim();

    if (unitName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, введите наименование единицы')),
      );
      return;
    }

    // Add your unit saving logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Единица успешно сохранена')),
    );

    // Clear the text field after saving
    _clearFields();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать Единицу Измерения', style: headingStyle),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextField(unitNameController, 'Наименование единицы'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveUnit,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
              child: const Text('Сохранить', style: buttonTextStyle),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build text fields with consistent styling
  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: subheadingStyle,
          border: const OutlineInputBorder(),
        ),
        style: bodyTextStyle,
      ),
    );
  }

  // Function to clear the input fields
  void _clearFields() {
    unitNameController.clear();
  }
}
