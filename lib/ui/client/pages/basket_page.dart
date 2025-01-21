import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/blocs/basket_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/basket_event.dart';
import 'package:alan/bloc/blocs/client_page_blocs/states/basket_state.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/address_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/address_state.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/blocs/address_bloc.dart';
import 'package:alan/constant.dart';

class BasketScreen extends StatefulWidget {
  const BasketScreen({Key? key}) : super(key: key);

  @override
  _BasketScreenState createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
  String? selectedAddress;

  @override
  void initState() {
    super.initState();
    context.read<BasketBloc>().add(FetchBasketEvent());
    context.read<AddressBloc>().add(FetchAddressesEvent());
  }

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
          Expanded(
            child: BlocListener<BasketBloc, BasketState>(
              listener: (context, state) {
                if (state is OrderPlacedState) {
                  _showSnackBar(context, 'Отправлена на оформление');
                } else if (state is BasketError) {
                  _showSnackBar(context, 'Ошибка: ${state.message}');
                }
              },
              child: BlocBuilder<BasketBloc, BasketState>(
                builder: (context, basketState) {
                  if (basketState is BasketLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (basketState is BasketError) {
                    return Center(child: Text('Ошибка: ${basketState.message}', style: bodyTextStyle));
                  } else if (basketState.basketItems.isEmpty) {
                    return const Center(child: Text('Ваша корзина пуста.', style: bodyTextStyle));
                  } else {
                    final basketItems = basketState.basketItems;

                    return ListView.builder(
                      itemCount: basketItems.length,
                      itemBuilder: (context, index) {
                        final item = basketItems[index];
                        final productDetails = item.productDetails;
                        final productCard = productDetails?.productCard;
                        final productName = productCard?.nameOfProducts ?? 'Неизвестный продукт';
                        final description = productCard?.description ?? 'Нет описания';
                        final photoUrl = productCard?.photoProduct != null
                            ? '${basePhotoUrl}storage/${productCard!.photoProduct}'
                            : null;

                        return Card(
                          margin: elementPadding,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: elementPadding,
                            child: Row(
                              children: [
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
                                      const SizedBox(height: 8),
                                      Text(
                                        description,
                                        style: captionStyle,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'x${item.quantity}',
                                        style: subheadingStyle,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: borderColor, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BlocBuilder<AddressBloc, AddressState>(
                  builder: (context, addressState) {
                    if (addressState is AddressLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (addressState is AddressesFetched) {
                      final addresses = addressState.addresses.expand((client) => client['addresses']).toList();
                      if (addresses.isEmpty) {
                        return const Text('Нет доступных адресов.', style: bodyTextStyle);
                      }

                      return DropdownButton<String>(
                        value: selectedAddress,
                        isExpanded: true,
                        hint: const Text('Выберите адрес', style: bodyTextStyle),
                        items: addresses.map<DropdownMenuItem<String>>((address) {
                          return DropdownMenuItem<String>(
                            value: address['name'],
                            child: Text(address['name'], style: bodyTextStyle),
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
                BlocBuilder<BasketBloc, BasketState>(
                  builder: (context, basketState) {
                    if (basketState is BasketLoading || basketState is BasketError) {
                      return const SizedBox.shrink();
                    } else {
                      final basketItems = basketState.basketItems;
                      final totalPrice = basketItems.fold(
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
                            onPressed: selectedAddress != null
                                ? () {
                                    context.read<BasketBloc>().add(PlaceOrderEvent(address: selectedAddress!));
                                  }
                                : null,
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
