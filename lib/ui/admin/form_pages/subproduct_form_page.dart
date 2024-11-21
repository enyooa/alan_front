import 'package:flutter/material.dart';
import 'package:cash_control/constant.dart';

class SubProductFormPage extends StatefulWidget {
  @override
  _SubProductFormPageState createState() => _SubProductFormPageState();
}

class _SubProductFormPageState extends State<SubProductFormPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController characteristicController = TextEditingController();

  void _saveSubProduct() {
    final name = nameController.text.trim();
    final characteristic = characteristicController.text.trim();

    if (name.isEmpty || characteristic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, заполните все поля')),
      );
      return;
    }

    // Add subproduct saving logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Подпродукт успешно сохранен')),
    );

    // Clear the fields after saving
    _clearFields();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать Подпродукт', style: headingStyle),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextField(nameController, 'Наименование подпродукта'),
            _buildTextField(characteristicController, 'Характеристика'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSubProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
              child: const Text('Сохранить Подпродукт', style: buttonTextStyle),
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

  // Method to clear the fields after saving
  void _clearFields() {
    nameController.clear();
    characteristicController.clear();
  }
}
