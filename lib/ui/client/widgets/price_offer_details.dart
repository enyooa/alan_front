import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/blocs/basket_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/blocs/favorites_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/basket_event.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/favorites_event.dart';
import 'package:alan/bloc/blocs/client_page_blocs/states/basket_state.dart';
import 'package:alan/bloc/blocs/client_page_blocs/states/favorites_state.dart';
import 'package:alan/bloc/models/basket_item.dart';
import 'package:alan/constant.dart';

class PriceOfferDetailsPage extends StatelessWidget {
  final Map<String, dynamic> offerOrder;
  const PriceOfferDetailsPage({Key? key, required this.offerOrder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int orderId = offerOrder['id'];
    final List<dynamic> items = offerOrder['price_offers'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Предложение #$orderId',style: headingStyle),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
final int productSubCardId =
    item['product_sub_card']?['id'] ??
    (item['product_subcard_id'] ?? -1);            
    final String productName = item['product_sub_card']?['name'] ?? 'Товар';
            final double price = (item['price'] ?? 0).toDouble();
            final double amount = (item['amount'] ?? 0).toDouble();

            // If there's a photo
            String photoUrl = '';
            if (item['product_sub_card']?['product_card']?['photo_product'] != null) {
              photoUrl = '$baseUrl${item['product_sub_card']['product_card']['photo_product']}';
            }

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Product Image
                    photoUrl.isNotEmpty
                        ? Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(photoUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.image_not_supported, size: 40),
                          ),
                    const SizedBox(width: 10),

                    // Product Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            productName,
                            style: subheadingStyle.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text('Кол-во: $amount | Цена: $price ₸', style: titleStyle),
                        ],
                      ),
                    ),

                    // Favorite Button
                    BlocBuilder<FavoritesBloc, FavoritesState>(
                      builder: (context, favState) {
                        final bool isFavorite = (favState is FavoritesLoaded) &&
                            favState.favorites.any((fav) => fav['product_subcard_id'] == productSubCardId);

                        return IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : textColor,
                          ),
                          onPressed: () {
                            if (isFavorite) {
                              context.read<FavoritesBloc>().add(
                                    RemoveFromFavoritesEvent(
                                      productSubcardId: productSubCardId.toString(),
                                    ),
                                  );
                            } else {
                              context.read<FavoritesBloc>().add(
                                    AddToFavoritesEvent(
                                      product: {
                                        'product_subcard_id': productSubCardId,
                                        'source_table': 'price_offers',
                                      },
                                    ),
                                  );
                            }
                          },
                        );
                      },
                    ),

                    // Basket Buttons
                    BlocBuilder<BasketBloc, BasketState>(
                      builder: (context, basketState) {
                        final basketItem = basketState.basketItems.firstWhere(
                          (bItem) => bItem.productSubcardId == productSubCardId,
                          orElse: () => BasketItem(
                            sourceTable: 'price_offers',
                            id: -1,
                            quantity: 0,
                            productSubcardId: productSubCardId,
                            price: 0.0,
                          ),
                        );
                        final int quantity = basketItem.quantity;

                        if (quantity > 0) {
                          // Show increment / decrement
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle, color: primaryColor),
                                onPressed: () {
                                  context.read<BasketBloc>().add(
                                        AddToBasketEvent({
                                          'product_subcard_id': productSubCardId,
                                          'source_table': 'price_offers',
                                          'source_table_id': item['id'], // ← Include this!
                                          'quantity': 1,
                                          'price': price,
                                        }),
                                      );
                                },
                              ),
                              Text('$quantity', style: subheadingStyle),
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: primaryColor),
                                onPressed: () {
                                  context.read<BasketBloc>().add(
                                        AddToBasketEvent({
                                          'product_subcard_id': productSubCardId,
                                          'source_table': 'price_offers',
                                          'source_table_id': item['id'], 

                                          'quantity': 1,
                                          'price': price,
                                        }),
                                      );
                                },
                              ),
                            ],
                          );
                        } else {
                          // "В корзину" button
                          return ElevatedButton(
                            onPressed: () {
                              context.read<BasketBloc>().add(
                                    AddToBasketEvent({
                                      'product_subcard_id': productSubCardId,
                                      'source_table': 'price_offers',
                                        'source_table_id': item['id'], // ← included

                                      'quantity': 1,
                                      'price': price,
                                    }),
                                  );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('В корзину', style: TextStyle(color: Colors.white)),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
