import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Basket
import 'package:alan/bloc/blocs/client_page_blocs/blocs/basket_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/basket_event.dart';
import 'package:alan/bloc/blocs/client_page_blocs/states/basket_state.dart';

// Favorites
import 'package:alan/bloc/blocs/client_page_blocs/blocs/favorites_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/favorites_event.dart';
import 'package:alan/bloc/blocs/client_page_blocs/states/favorites_state.dart';

// Address
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/address_bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/address_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/address_state.dart';

// Your basket item model
import 'package:alan/bloc/models/basket_item.dart';

// Styles & constants
import 'package:alan/constant.dart';

class BasketScreen extends StatefulWidget {
  const BasketScreen({Key? key}) : super(key: key);

  @override
  _BasketScreenState createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
  // We'll store the chosen address name
  String? selectedAddress;

  @override
  void initState() {
    super.initState();
    // Trigger the basket fetch
    context.read<BasketBloc>().add(FetchBasketEvent());
    // Trigger addresses fetch
    context.read<AddressBloc>().add(FetchAddressesEvent());
    // Optionally fetch favorites if not done
    context.read<FavoritesBloc>().add(FetchFavoritesEvent());
  }

  /// A helper to show a SnackBar for success/failure
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: bodyTextStyle.copyWith(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина', style: headingStyle),
        backgroundColor: primaryColor,
      ),
      body: Column(
        children: [
          // 1) Main basket items area
          Expanded(
            child: BlocListener<BasketBloc, BasketState>(
              listener: (context, state) {
                if (state is OrderPlacedState) {
                  // Show a success message if order is placed
                  _showSnackBar(context, 'Отправлена на оформление');
                } else if (state is BasketError) {
                  // Show an error message if something failed
                  _showSnackBar(context, 'Ошибка: ${state.message}');
                }
              },
              child: BlocBuilder<BasketBloc, BasketState>(
                builder: (context, basketState) {
                  // 1a) Loading
                  if (basketState is BasketLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // 1b) Error
                  else if (basketState is BasketError) {
                    return Center(
                      child: Text('Ошибка: ${basketState.message}', style: bodyTextStyle),
                    );
                  }
                  // 1c) Empty
                  else if (basketState.basketItems.isEmpty) {
                    return const Center(
                      child: Text('Ваша корзина пуста.', style: bodyTextStyle),
                    );
                  }
                  // 1d) Items exist
                  else {
                    final basketItems = basketState.basketItems;

                    return ListView.builder(
                      itemCount: basketItems.length,
                      itemBuilder: (context, index) {
                        final BasketItem item = basketItems[index];

                        // For convenience
                        final productDetails = item.productDetails;
                        final productCard = productDetails?.productCard;
                        final productName = productCard?.nameOfProducts ?? 'Неизвестно';
                        final description = productCard?.description ?? 'Нет описания';
                        // If server returns `photo_product`: sub folder in storage
                        final photoUrl = (productCard?.photoProduct != null)
                            ? '${basePhotoUrl}storage/${productCard!.photoProduct}'
                            : '';

                        // We'll use item.productSubcardId as the "favorite" identifier
                        final int subcardId = item.productSubcardId;

                        return Card(
                          margin: elementPadding,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: Stack(
                            children: [
                              // Main row content
                              Padding(
                                padding: elementPadding,
                                child: Row(
                                  children: [
                                    // Photo
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
                                    const SizedBox(width: 16),

                                    // Title, desc, etc
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
                                            description,
                                            style: captionStyle,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Количество: x${item.quantity}',
                                            style: bodyTextStyle,
                                          ),
                                          Text(
                                            'Цена: ${item.price} ₸',
                                            style: bodyTextStyle.copyWith(color: primaryColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // (A) Top-right Favorite icon
                              Positioned(
                                top: 8,
                                right: 8,
                                child: BlocBuilder<FavoritesBloc, FavoritesState>(
                                  builder: (context, favState) {
                                    final bool isFavorite = (favState is FavoritesLoaded) &&
                                        favState.favorites.any(
                                          (fav) => fav['product_subcard_id'] == subcardId,
                                        );

                                    return IconButton(
                                      icon: Icon(
                                        isFavorite ? Icons.favorite : Icons.favorite_border,
                                        color: isFavorite ? Colors.red : textColor,
                                      ),
                                      onPressed: () {
                                        if (isFavorite) {
                                          context.read<FavoritesBloc>().add(
                                                RemoveFromFavoritesEvent(
                                                  productSubcardId: subcardId.toString(),
                                                ),
                                              );
                                        } else {
                                          context.read<FavoritesBloc>().add(
                                                AddToFavoritesEvent(
                                                  product: {
                                                    'product_subcard_id': subcardId,
                                                    'source_table': item.sourceTable,
                                                  },
                                                ),
                                              );
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),

                              // (B) Bottom-right increment/decrement
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle, color: primaryColor),
                                      onPressed: () {
                                        // dispatch event with negative quantity => decrement
                                        context.read<BasketBloc>().add(
                                          AddToBasketEvent({
                                            'product_subcard_id': item.productSubcardId,
                                            'source_table': item.sourceTable,
                                            'quantity': -1, // decrement
                                            'price': item.price,
                                          }),
                                        );
                                      },
                                    ),
                                    Text('${item.quantity}', style: subheadingStyle),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle, color: primaryColor),
                                      onPressed: () {
                                        // dispatch event => increment
                                        context.read<BasketBloc>().add(
                                          AddToBasketEvent({
                                            'product_subcard_id': item.productSubcardId,
                                            'source_table': item.sourceTable,
                                            'quantity': 1,
                                            'price': item.price,
                                          }),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),

          // 2) The address dropdown + total price + checkout
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: borderColor, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // (A) Address dropdown
                BlocBuilder<AddressBloc, AddressState>(
                  builder: (context, addressState) {
                    if (addressState is AddressLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (addressState is AddressesFetched) {
                      final addresses = addressState.addresses
                          .expand((client) => client['addresses'])
                          .toList();
                      if (addresses.isEmpty) {
                        return const Text(
                          'Нет доступных адресов.',
                          style: bodyTextStyle,
                        );
                      }

                      return DropdownButton<String>(
                        value: selectedAddress,
                        isExpanded: true,
                        hint: const Text('Выберите адрес', style: bodyTextStyle),
                        items: addresses.map<DropdownMenuItem<String>>((addr) {
                          return DropdownMenuItem<String>(
                            value: addr['name'],
                            child: Text(addr['name'], style: bodyTextStyle),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedAddress = value;
                          });
                        },
                      );
                    } else if (addressState is AddressError) {
                      return Text('Ошибка: ${addressState.error}', style: bodyTextStyle);
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 12),

                // (B) Total price + Place order
                BlocBuilder<BasketBloc, BasketState>(
                  builder: (context, basketState) {
                    if (basketState is BasketLoading || basketState is BasketError) {
                      // If loading or error, hide the row
                      return const SizedBox.shrink();
                    } else {
                      final basketItems = basketState.basketItems;
                      final totalPrice = basketItems.fold<double>(
                        0.0,
                        (sum, item) => sum + (item.quantity * item.price),
                      );

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Итого: ${totalPrice.toStringAsFixed(2)} ₸',
                            style: subheadingStyle,
                          ),
                          ElevatedButton(
                            onPressed: (selectedAddress != null)
                                ? () {
                                    // Dispatch place order
                                    context.read<BasketBloc>().add(
                                      PlaceOrderEvent(address: selectedAddress!),
                                    );
                                  }
                                : null, // disable if no address selected
                            style: elevatedButtonStyle,
                            child: const Text('Оформить заказ'),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
