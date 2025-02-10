import 'package:alan/bloc/blocs/client_page_blocs/states/favorites_state.dart';
import 'package:alan/bloc/models/basket_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/blocs/basket_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/basket_event.dart';
import 'package:alan/bloc/blocs/client_page_blocs/states/basket_state.dart';
import 'package:alan/bloc/blocs/client_page_blocs/blocs/favorites_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/favorites_event.dart';
import 'package:alan/bloc/blocs/client_page_blocs/states/sales_state.dart';
import 'package:alan/bloc/blocs/client_page_blocs/blocs/sales_bloc.dart';
import 'package:alan/constant.dart';
class ProductListPage extends StatefulWidget {
  final String searchQuery;

  const ProductListPage({Key? key, required this.searchQuery}) : super(key: key);

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  void initState() {
    super.initState();
    context.read<FavoritesBloc>().add(FetchFavoritesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalesBloc, SalesState>(
      builder: (context, state) {
        if (state is SalesLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SalesLoadedWithDetails) {
          final salesDetails = state.salesDetails;

          // Filter products based on search query
          final filteredData = salesDetails.where((data) {
            final subCardName = data['sub_card']['name'].toString().toLowerCase();
            return subCardName.contains(widget.searchQuery.toLowerCase());
          }).toList();

          if (filteredData.isEmpty) {
            return const Center(
              child: Text('Нет доступных товаров.', style: bodyTextStyle),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: filteredData.length,
            itemBuilder: (context, index) {
              final item = filteredData[index];
              final subCard = item['sub_card'];
              final productCard = subCard['product_card'];
              final relativePhotoPath = productCard['photo_product'] ?? '';
              final photoUrl = relativePhotoPath.isNotEmpty
                  ? '${basePhotoUrl}storage/$relativePhotoPath'
                  : '';
              final productName = productCard['name_of_products'] ?? 'Товар';
              final description = productCard['description'] ?? 'Описание отсутствует';
              final price = item['price'];
              final unitMeasurement = item['unit_measurement'] ?? 'Единица';
              final subCardName = subCard['name'] ?? 'Подкарточка';
              final productId = item['id'];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
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
                                Text(
                                  'Единица: $unitMeasurement',
                                  style: captionStyle.copyWith(fontStyle: FontStyle.italic),
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
                      child: BlocBuilder<FavoritesBloc, FavoritesState>(
                      builder: (context, favoritesState) {
                        final isFavorite = (favoritesState is FavoritesLoaded) &&
                            favoritesState.favorites.any((fav) => fav['product_subcard_id'] == subCard['id']);

                        return IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : textColor,
                          ),
                          onPressed: () {
                            if (isFavorite) {
                              context.read<FavoritesBloc>().add(
                                    RemoveFromFavoritesEvent(
                                      productSubcardId: subCard['id'].toString(),
                                    ),
                                  );
                            } else {
                              context.read<FavoritesBloc>().add(
                                    AddToFavoritesEvent(
                                      product: {
                                        'product_subcard_id': subCard['id'],
                                        'source_table': 'sales',
                                      },
                                    ),
                                  );
                            }
                          },
                        );
                      },
                    )
                    ),

                    // Increment-Decrement or "В корзину" Button
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: BlocBuilder<BasketBloc, BasketState>(
                        builder: (context, basketState) {
                          final basketItem = basketState.basketItems.firstWhere(
                            (item) => item.productSubcardId == subCard['id'],
                            orElse: () => BasketItem(
                              id: -1,
                              quantity: 0,
                              productSubcardId: subCard['id'],
                              sourceTable: '',
                              price: 0.0,
                            ),
                          );

                          final quantity = basketItem.quantity;

                          if (quantity > 0) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle, color: primaryColor),
                                  onPressed: () {
                                    context.read<BasketBloc>().add(
                                          AddToBasketEvent({
                                            'product_subcard_id': subCard['id'],
                                            'source_table': 'sales',
                                            'source_table_id': item['id'],
                                            'quantity': -1,
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
                                            'product_subcard_id': subCard['id'],
                                            'source_table': 'sales',
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
                            return ElevatedButton(
                              onPressed: () {
                                context.read<BasketBloc>().add(
                                      AddToBasketEvent({
                                        'product_subcard_id': subCard['id'],
                                        'source_table': 'sales',
                                        'source_table_id': item['id'],
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
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          return const Center(
            child: Text('Ошибка загрузки товаров.', style: bodyTextStyle),
          );
        }
      },
    );
  }
}
