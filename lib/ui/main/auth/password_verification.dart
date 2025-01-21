import 'package:alan/ui/main/auth/submit_verification.dart';
import 'package:flutter/material.dart';

class PasswordVerificationScreen extends StatelessWidget {
  final TextEditingController _passwordController = TextEditingController();

  PasswordVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Подтверждение пароля'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Введите пароль',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle password verification logic
                Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => SubmitApplicationScreen()),
  );
           
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 64),
              ),
              child: const Text('Подтвердить'),
            ),
          ],
        ),
      ),
    );
  }
}
