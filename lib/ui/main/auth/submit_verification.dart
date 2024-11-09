import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart'; // Import this package for SVG ImageProvider

class SubmitApplicationScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  SubmitApplicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Stack(children: [
          CircleAvatar(
            radius: 64,
            backgroundImage: Svg("assets/images/avatar.svg")
              ),
        ],),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Наименование',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _whatsappController,
              decoration: const InputDecoration(
                labelText: 'номер WhatsApp',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _organizationController,
              decoration: const InputDecoration(
                labelText: 'формы организации',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Адрес поставки',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle submit logic
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 64),
              ),
              child: const Text('Отправить заявку'),
            ),
          ],
        ),
      ),
    );
  }
}
