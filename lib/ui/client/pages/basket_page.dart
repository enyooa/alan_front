import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/blocs/basket_bloc.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/events/basket_event.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/states/basket_state.dart';
import 'package:cash_control/constant.dart';

class BasketScreen extends StatefulWidget {
  const BasketScreen({Key? key}) : super(key: key);

  @override
  _BasketScreenState createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BasketBloc>().add(FetchBasketEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basket'),
        backgroundColor: primaryColor,
      ),
      body: BlocBuilder<BasketBloc, BasketState>(
        builder: (context, state) {
          if (state is BasketLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BasketError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state.basketItems.isEmpty) {
            return const Center(child: Text('Ваша корзина пуста'));
          } else {
            final basketItems = state.basketItems;

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: basketItems.length,
                    itemBuilder: (context, index) {
                      final item = basketItems[index];
                      final productDetails = item.productDetails;
                      final productCard = productDetails?.productCard;
                      final productName = productCard?.nameOfProducts ?? 'Unknown Product';
                      final description = productCard?.description ?? 'No description available';
                      final photoUrl = productCard?.photoProduct != null
                          ? '${basePhotoUrl}storage/${productCard!.photoProduct}'
                          : null;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
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
                                      style: subheadingStyle.copyWith(fontWeight: FontWeight.bold),
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
                                      style: subheadingStyle.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Order Button
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Общая сумма: ${state.totalItems * 100}₸', // Replace with actual sum logic
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.read<BasketBloc>().add(PlaceOrderEvent(address: 'User Address'));
                        },
                        child: const Text('Оформить заказ'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
