import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Blocs & Events
import 'package:alan/bloc/blocs/client_page_blocs/blocs/basket_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/basket_event.dart';
import 'package:alan/bloc/blocs/client_page_blocs/blocs/favorites_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/favorites_event.dart';

// States
import 'package:alan/bloc/blocs/client_page_blocs/states/basket_state.dart';
import 'package:alan/bloc/blocs/client_page_blocs/states/favorites_state.dart';

// Models & Constants
import 'package:alan/bloc/models/basket_item.dart';
import 'package:alan/constant.dart';

class PriceOfferDetailsPage extends StatelessWidget {
  final Map<String, dynamic> offerOrder;
  const PriceOfferDetailsPage({
    Key? key,
    required this.offerOrder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int orderId = offerOrder['id'];
    // The list of items under this offer order:
    final List<dynamic> items = offerOrder['price_offers'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Предложение #$orderId',
          style: headingStyle,
        ),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];

            // Identify the product_sub_card_id from the nested JSON:
            final int productSubCardId = item['product_sub_card']?['id'] ??
                (item['product_subcard_id'] ?? -1);

            // Some fields from the JSON:
            final String productName =
                item['product_sub_card']?['name'] ?? 'Товар';
            final double price = (item['price'] ?? 0).toDouble();
            final double amount = (item['amount'] ?? 0).toDouble();

            // If your backend already calculated totalsum:
            final double totalSum = (item['totalsum'] ?? 0).toDouble();

            // If you prefer to recalc totalsum as price * amount, do:
            // final double totalSum = price * amount;

            // Unit measurement field (e.g. "мешок", "кг", etc.)
            final String unitMeasurement =
                (item['unit_measurement'] ?? 'шт').toString();

            // Handling photo from nested "product_card"
            String photoUrl = '';
            if (item['product_sub_card']?['product_card']?['photo_product'] !=
                null) {
              photoUrl =
                  '$baseUrl${item['product_sub_card']['product_card']['photo_product']}';
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
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 40,
                            ),
                          ),
                    const SizedBox(width: 10),

                    // Product Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            productName,
                            style: subheadingStyle.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Кол-во: $amount | Цена: $price ₸',
                            style: titleStyle,
                          ),
                          Text(
                            'Ед: $unitMeasurement | Сумма: $totalSum ₸',
                            style: captionStyle,
                          ),
                        ],
                      ),
                    ),

                    // Favorite Button
                    BlocBuilder<FavoritesBloc, FavoritesState>(
                      builder: (context, favState) {
                        final bool isFavorite =
                            (favState is FavoritesLoaded) &&
                                favState.favorites.any(
                                  (fav) =>
                                      fav['product_subcard_id'] ==
                                      productSubCardId,
                                );

                        return IconButton(
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFavorite ? Colors.red : textColor,
                          ),
                          onPressed: () {
                            if (isFavorite) {
                              context.read<FavoritesBloc>().add(
                                    RemoveFromFavoritesEvent(
                                      productSubcardId:
                                          productSubCardId.toString(),
                                    ),
                                  );
                            } else {
                              context.read<FavoritesBloc>().add(
                                    AddToFavoritesEvent(
                                      product: {
                                        'product_subcard_id':
                                            productSubCardId,
                                        'source_table': 'price_offer_items',
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
                        // Check if it's already in the basket
                        final basketItem =
                            basketState.basketItems.firstWhere(
                          (bItem) =>
                              bItem.productSubcardId == productSubCardId,
                          orElse: () => BasketItem(
                            sourceTable: 'price_offer_items',
                            id: -1,
                            quantity: 0,
                            productSubcardId: productSubCardId,
                            price: 0.0,
                          ),
                        );

                        final int quantity = basketItem.quantity;

                        // If the user already has some quantity
                        // show increment/decrement
                        if (quantity > 0) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle,
                                  color: primaryColor,
                                ),
                                onPressed: () {
                                  context.read<BasketBloc>().add(
                                        AddToBasketEvent({
                                          'product_subcard_id':
                                              productSubCardId,
                                          'source_table':
                                              'price_offer_items',
                                          'source_table_id': item['id'],
                                          'quantity': -1,
                                          'price': price,
                                          // NEW FIELDS:
                                          'unit_measurement':
                                              unitMeasurement,
                                          'totalsum': totalSum,
                                        }),
                                      );
                                },
                              ),
                              Text(
                                '$quantity',
                                style: subheadingStyle,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add_circle,
                                  color: primaryColor,
                                ),
                                onPressed: () {
                                  context.read<BasketBloc>().add(
                                        AddToBasketEvent({
                                          'product_subcard_id':
                                              productSubCardId,
                                          'source_table':
                                              'price_offer_items',
                                          'source_table_id': item['id'],
                                          'quantity': 1,
                                          'price': price,
                                          // NEW FIELDS:
                                          'unit_measurement':
                                              unitMeasurement,
                                          'totalsum': totalSum,
                                        }),
                                      );
                                },
                              ),
                            ],
                          );
                        } else {
                          // If quantity == 0, show "В корзину"
                          return ElevatedButton(
                            onPressed: () {
                              context.read<BasketBloc>().add(
                                    AddToBasketEvent({
                                      'product_subcard_id':
                                          productSubCardId,
                                      'source_table':
                                          'price_offer_items',
                                      'source_table_id': item['id'],
                                      'quantity': 1,
                                      'price': price,
                                      // NEW FIELDS:
                                      'unit_measurement': unitMeasurement,
                                      'totalsum': totalSum,
                                    }),
                                  );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'В корзину',
                              style: TextStyle(color: Colors.white),
                            ),
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
