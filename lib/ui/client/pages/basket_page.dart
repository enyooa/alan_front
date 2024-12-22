import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/blocs/basket_bloc.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/events/basket_event.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/states/basket_state.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({Key? key}) : super(key: key);

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BasketBloc>().add(FetchBasketEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
      ),
      body: BlocBuilder<BasketBloc, BasketState>(
        builder: (context, state) {
          if (state is BasketLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BasketUpdated || state is BasketState) {
            final basketItems = state.basketItems.values.toList();
            if (basketItems.isEmpty) {
              return const Center(child: Text('Ваша корзина пуста'));
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: basketItems.length,
                    itemBuilder: (context, index) {
                      final item = basketItems[index];
                      return ListTile(
                        title: Text(item['product_subcard_id'].toString()),
                        subtitle: Text('Количество: ${item['quantity']}'),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.white,
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
                          // Trigger the PlaceOrderEvent
                          context
                              .read<BasketBloc>()
                              .add(PlaceOrderEvent(address: 'User Address'));
                        },
                        child: const Text('Оформить заказ'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if (state is BasketError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text('Ошибка загрузки'));
          }
        },
      ),
    );
  }
}
