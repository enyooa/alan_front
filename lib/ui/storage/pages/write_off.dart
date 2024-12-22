import 'package:flutter/material.dart';

class WriteOffPage extends StatelessWidget {
  const WriteOffPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to write-off logic
          },
          child: const Text('Добавить Списание'),
        ),
      ),
    );
  }
}
