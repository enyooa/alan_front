import 'package:flutter/material.dart';
import 'widgets/appbar.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: "Избранное"),
      body: ListView.builder(
        itemCount: 5, // Example favorites count
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: const Icon(Icons.favorite, color: Colors.red),
              title: Text("Favorite Product $index"),
              subtitle: const Text("Product details go here."),
              trailing: ElevatedButton(
                onPressed: () {},
                child: const Text("В корзину"),
              ),
            ),
          );
        },
      ),
    );
  }
}
