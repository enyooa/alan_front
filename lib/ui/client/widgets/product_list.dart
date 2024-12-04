import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/product_card_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/product_sale_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/product_subcard_bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/product_card_state.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/product_sale_state.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/product_subcard_state.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/blocs/basket_bloc.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/events/basket_event.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/events/favorite_event.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/states/basket_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ProductList extends StatelessWidget {
  final String searchQuery;

  const ProductList({Key? key, required this.searchQuery}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalesBloc, SalesState>(
      builder: (context, salesState) {
        if (salesState is SalesLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (salesState is SalesLoaded) {
          final sales = salesState.salesList;

          return BlocBuilder<ProductSubCardBloc, ProductSubCardState>(
            builder: (context, subcardState) {
              if (subcardState is ProductSubCardLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (subcardState is ProductSubCardsLoaded) {
                final subcards = subcardState.productSubCards;

                return BlocBuilder<ProductCardBloc, ProductCardState>(
                  builder: (context, cardState) {
                    if (cardState is ProductCardLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (cardState is ProductCardsLoaded) {
                      final productCards = cardState.productCards;

                      // Combine sales, subcards, and product cards
                      final combinedData = sales.map((sale) {
                        final subcard = subcards.firstWhere(
                          (sub) => sub['id'] == sale['product_subcard_id'],
                          orElse: () => <String, dynamic>{},
                        );

                        final productCard = productCards.firstWhere(
                          (card) => card['id'] == subcard['product_card_id'],
                          orElse: () => <String, dynamic>{},
                        );

                        return {
                          'sale': sale,
                          'subcard_name': subcard['name'] ?? 'Unnamed Subcard',
                          'product_card': productCard,
                          'photo_url': productCard['photo_url'] ?? '',
                          'is_favorite': productCard['is_favorite'] ?? false,
                        };
                      }).toList();

                      // Filter combined data based on search query
                      final filteredData = combinedData.where((data) {
                        final subcardName =
                            data['subcard_name'].toString().toLowerCase();
                        return subcardName.contains(searchQuery.toLowerCase());
                      }).toList();

                      return ListView.builder(
                        itemCount: filteredData.length,
                        itemBuilder: (context, index) {
                          final item = filteredData[index];
                          final productCard = item['product_card'] ?? {};
                          final photoUrl = productCard['photo_url'] ?? '';
                          final description = productCard['description'] ?? '';
                          final price = item['sale']['price'];
                          final productId = item['sale']['id'];
                          bool isFavorite = item['is_favorite'];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  // Product Image
                                  photoUrl.isNotEmpty
                                      ? Image.network(
                                          photoUrl,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error,
                                                  stackTrace) =>
                                              const Icon(Icons.broken_image,
                                                  size: 80),
                                        )
                                      : const Icon(Icons.image_not_supported,
                                          size: 80),
                                  const SizedBox(width: 8),
                                  // Product Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['subcard_name'] ??
                                              'Unnamed Subcard',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          description,
                                          style: const TextStyle(
                                              color: Colors.grey),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$price ₸',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Counter, Favorites, and Add Button
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove),
                                            onPressed: () {
                                              context
                                                  .read<BasketBloc>()
                                                  .add(RemoveFromBasketEvent(
                                                      productId));
                                            },
                                          ),
                                          BlocBuilder<BasketBloc, BasketState>(
                                            builder: (context, basketState) {
                                              final count = basketState
                                                      .basketItems[productId]?[
                                                  'quantity'] ??
                                                  0;
                                              return Text(
                                                '$count',
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add),
                                            onPressed: () {
                                              context
                                                  .read<BasketBloc>()
                                                  .add(AddToBasketEvent(
                                                      item['sale']));
                                            },
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isFavorite
                                              ? Colors.red
                                              : Colors.grey,
                                        ),
                                        onPressed: () {
                                          // Toggle favorite status
                                          isFavorite = !isFavorite;
                                          context.read<BasketBloc>().add(
                                              ToggleFavoriteEvent(productId) as BasketEvent);
                                        },
                                      ),
                                      ElevatedButton(
  onPressed: () {
    final product = {
      'id': item['sale']['id'], // Ensure the product ID exists
      'name': item['subcard_name'], // Name of the product
      'price': item['sale']['price'], // Product price
      'description': item['product_card']['description'] ?? '', // Description
      'photo_url': item['photo_url'] ?? '', // Photo URL
      'quantity': 1, // Default quantity when adding
    };
    context.read<BasketBloc>().add(AddToBasketEvent(product));
  },
  child: const Text('В корзину'),
),



                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(
                          child: Text('Failed to load product cards.'));
                    }
                  },
                );
              } else {
                return const Center(child: Text('Failed to load subcards.'));
              }
            },
          );
        } else {
          return const Center(child: Text('Failed to load sales.'));
        }
      },
    );
  }
}
