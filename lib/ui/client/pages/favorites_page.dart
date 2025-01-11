import 'package:cash_control/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/blocs/favorites_bloc.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/events/favorites_event.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/states/favorites_state.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/blocs/basket_bloc.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/events/basket_event.dart';

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
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FavoritesLoaded) {
            final favorites = state.favorites;

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
                    ? '$baseUrl/${productCard['photo_product']}'
                    : null;
                final productName = productCard['name_of_products'] ?? 'Неизвестный продукт';
                final description = productCard['description'] ?? 'Описание отсутствует';

                return Card(
                  margin: elementPadding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        // Product Image
                        photoUrl != null
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
                        const SizedBox(width: 16),

                        // Product Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productName,
                                style: subheadingStyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                description,
                                style: captionStyle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Action Buttons
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.shopping_cart, color: primaryColor),
                              onPressed: () {
                                final productSubcardId = favorite['product_subcard_id'];
                                final productPrice = favorite['price'] ?? 0; // Default price
                                context.read<BasketBloc>().add(
                                      AddToBasketEvent({
                                        'product_subcard_id': productSubcardId,
                                        'source_table': 'favorites',
                                        'quantity': 1,
                                        'price': productPrice,
                                      }),
                                    );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '$productName добавлен в корзину',
                                      style: bodyTextStyle.copyWith(color: Colors.white),
                                    ),
                                    backgroundColor: primaryColor,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: errorColor),
                              onPressed: () {
                                context.read<FavoritesBloc>().add(
                                      RemoveFromFavoritesEvent(
                                        productSubcardId: favorite['product_subcard_id'].toString(),
                                      ),
                                    );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is FavoritesError) {
            return Center(
              child: Text(
                'Ошибка: ${state.message}',
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
