import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: const Center(
        child: Text(
          'Ваши избранные товары',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
