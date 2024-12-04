import 'package:cash_control/bloc/blocs/client_page_blocs/blocs/basket_bloc.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/events/basket_event.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/states/basket_state.dart';
import 'package:cash_control/ui/client/widgets/basket_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ShoppingCartScreen(),
    );
  }
}

class ShoppingCartScreen extends StatelessWidget {
  const ShoppingCartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
      ),
      body: BlocBuilder<BasketBloc, BasketState>(
        builder: (context, state) {
          if (state.basketItems.isEmpty) {
            return const Center(
              child: Text('Ваша корзина пуста'),
            );
          }

          return ListView.builder(
            itemCount: state.basketItems.length,
            itemBuilder: (context, index) {
              final productId = state.basketItems.keys.toList()[index];
              final product = state.basketItems[productId]!;

              return BasketItemCard(product: product);
            },
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<BasketBloc, BasketState>(
        builder: (context, state) {
          final totalPrice = state.basketItems.values.fold(
            0.0,
            (sum, item) => sum + (item['price'] ?? 0) * (item['quantity'] ?? 1),
          );

          return Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Общая сумма: ${totalPrice.toStringAsFixed(2)} ₸',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Add checkout logic here
                  },
                  child: const Text('Оформить заказ'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


class CartItemWidget extends StatelessWidget {
  final Map<String, dynamic> item;

  const CartItemWidget({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Safely handle photo_url
            item['photo_url'] != null && item['photo_url'].isNotEmpty
                ? Image.network(
                    item['photo_url'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.image_not_supported, size: 60), // Fallback icon
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Safely handle name
                  Text(
                    item['name'] ?? 'No Name', // Default to "No Name"
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${item['price'] ?? 0} ₸'), // Default to 0 price
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    // Safely handle id
                    final productId = item['id'] ?? '';
                    if (productId.isNotEmpty) {
                      context.read<BasketBloc>().add(RemoveFromBasketEvent(productId));
                    }
                  },
                  icon: const Icon(Icons.remove),
                ),
                Text('${item['quantity'] ?? 0} шт'), // Default to 0 quantity
                IconButton(
                  onPressed: () {
                    context.read<BasketBloc>().add(AddToBasketEvent(item));
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
