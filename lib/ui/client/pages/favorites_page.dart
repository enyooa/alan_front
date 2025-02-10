import 'package:alan/bloc/blocs/client_page_blocs/states/basket_state.dart';
import 'package:alan/bloc/models/basket_item.dart';
import 'package:alan/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/blocs/favorites_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/favorites_event.dart';
import 'package:alan/bloc/blocs/client_page_blocs/states/favorites_state.dart';
import 'package:alan/bloc/blocs/client_page_blocs/blocs/basket_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/basket_event.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    context.read<FavoritesBloc>().add(FetchFavoritesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Избранное', style: headingStyle),
        backgroundColor: primaryColor,
      ),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, favoritesState) {
          if (favoritesState is FavoritesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (favoritesState is FavoritesLoaded) {
            final favorites = favoritesState.favorites;

            if (favorites.isEmpty) {
              return const Center(
                child: Text(
                  'Нет избранных товаров.',
                  style: subheadingStyle,
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final favorite = favorites[index];
                final productDetails = favorite['product_details'] ?? {};
                final productCard = productDetails['product_card'] ?? {};

                final photoUrl = productCard['photo_product'] != null
                    ? '$baseUrl/storage/${productCard['photo_product']}'
                    : '';
                final productName =
                    productCard['name_of_products'] ?? 'Неизвестный продукт';
                final description =
                    productCard['description'] ?? 'Описание отсутствует';
                final subCardName =
                    favorite['sub_card_name'] ?? 'Подкарточка';
                final price = favorite['price'] ?? 0;

                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
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
                                      borderRadius:
                                          BorderRadius.circular(8),
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
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    productName,
                                    style: subheadingStyle.copyWith(
                                        fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    subCardName,
                                    style: captionStyle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    description,
                                    style: captionStyle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Цена: $price ₸',
                                    style: bodyTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Favorite Button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: errorColor),
                          onPressed: () {
                            context.read<FavoritesBloc>().add(
                                  RemoveFromFavoritesEvent(
                                    productSubcardId:
                                        favorite['product_subcard_id']
                                            .toString(),
                                  ),
                                );
                          },
                        ),
                      ),

                      // Add to Basket Button or Increment/Decrement Controls
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: BlocBuilder<BasketBloc, BasketState>(
                          builder: (context, basketState) {
                            final basketItem =
                                basketState.basketItems.firstWhere(
                              (item) =>
                                  item.productSubcardId ==
                                  favorite['product_subcard_id'],
                              orElse: () => BasketItem(
                                id: -1,
                                quantity: 0,
                                productSubcardId:
                                    favorite['product_subcard_id'],
                                sourceTable: 'favorites',
                                price: price,
                              ),
                            );

                            final quantity = basketItem.quantity;

                            if (quantity > 0) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                        Icons.remove_circle,
                                        color: primaryColor),
                                    onPressed: () {
                                      context
                                          .read<BasketBloc>()
                                          .add(AddToBasketEvent({
                                            'product_subcard_id': favorite[
                                                'product_subcard_id'],
                                            'source_table': 'favorites',
                                            'source_table_id': favorite['id'],
                                            'quantity': -1,
                                            'price': price,
                                          }));
                                    },
                                  ),
                                  Text('$quantity', style: subheadingStyle),
                                  IconButton(
                                    icon: const Icon(
                                        Icons.add_circle,
                                        color: primaryColor),
                                    onPressed: () {
                                      context
                                          .read<BasketBloc>()
                                          .add(AddToBasketEvent({
                                            'product_subcard_id': favorite[
                                                'product_subcard_id'],
                                            'source_table': 'favorites',
                                            'source_table_id': favorite['id'],
                                            'quantity': 1,
                                            'price': price,
                                          }));
                                    },
                                  ),
                                ],
                              );
                            } else {
                              return ElevatedButton(
                                onPressed: () {
                                  context
                                      .read<BasketBloc>()
                                      .add(AddToBasketEvent({
                                        'product_subcard_id': favorite[
                                            'product_subcard_id'],
                                        'source_table': 'favorites',
                                        'source_table_id': favorite['id'],
                                        'quantity': 1,
                                        'price': price,
                                      }));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('В корзину',
                                    style: TextStyle(color: Colors.white)),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (favoritesState is FavoritesError) {
            return Center(
              child: Text(
                'Ошибка: ${favoritesState.message}',
                style: bodyTextStyle.copyWith(color: errorColor),
              ),
            );
          } else {
            return const Center(
              child: Text(
                'Нет данных.',
                style: subheadingStyle,
              ),
            );
          }
        },
      ),
    );
  }
}
