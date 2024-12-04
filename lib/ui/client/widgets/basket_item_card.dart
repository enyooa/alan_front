import 'package:cash_control/bloc/blocs/client_page_blocs/blocs/basket_bloc.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/events/basket_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BasketItemCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const BasketItemCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productName = product['name'] ?? 'Без названия';
    final productDescription = product['description'] ?? '';
    final productPrice = product['price'] ?? 0.0;
    final productQuantity = product['quantity'] ?? 0;
    final productPhotoUrl = product['photo_url'] ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Product Image
            productPhotoUrl.isNotEmpty
                ? Image.network(
                    productPhotoUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 80),
                  )
                : const Icon(Icons.image_not_supported, size: 80),
            const SizedBox(width: 8),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    productDescription,
                    style: const TextStyle(color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${productPrice.toStringAsFixed(2)} ₸',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Counter and Buttons
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
  children: [
    IconButton(
      icon: const Icon(Icons.remove),
      onPressed: () {
        context.read<BasketBloc>().add(RemoveFromBasketEvent(product['id']));
      },
    ),
    Text(
      '${product['quantity']}', // Ensure quantity updates correctly
      style: const TextStyle(fontSize: 16),
    ),
    IconButton(
      icon: const Icon(Icons.add),
      onPressed: () {
        context.read<BasketBloc>().add(AddToBasketEvent(product));
      },
    ),
  ],
),

                ],
            ),
          ],
        ),
      ),
    );
  }
}
