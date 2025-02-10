

import 'package:alan/bloc/blocs/courier_page_blocs/blocs/courier_order_bloc.dart';
import 'package:alan/bloc/blocs/courier_page_blocs/states/courier_order_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alan/constant.dart';

class DeliveryHomeScreen extends StatefulWidget {
  @override
  State<DeliveryHomeScreen> createState() => _DeliveryHomeScreenState();
}

class _DeliveryHomeScreenState extends State<DeliveryHomeScreen> {
  @override
  void initState() {
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Доставка", style: headingStyle),
        backgroundColor: primaryColor,
      ),
      body: BlocBuilder<CourierOrdersBloc, CourierOrdersState>(
        builder: (context, state) {
          if (state is CourierOrdersLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CourierOrdersLoaded) {
            final documents = state.orders;

            if (documents.isEmpty) {
              return const Center(
                child: Text('Нет доступных документов', style: bodyTextStyle),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final document = documents[index];
                final deliveryAddress = document['address'] ?? 'Не указано';

                return DeliveryItem(
                  storage: 'Склад', // Example placeholder
                  delivery: deliveryAddress,
                );
              },
            );
          } else if (state is CourierOrdersError) {
            return Center(
              child: Text(
                'Ошибка: ${state.message}',
                style: bodyTextStyle.copyWith(color: errorColor),
              ),
            );
          } else {
            return const Center(
              child: Text('Ошибка загрузки данных.', style: bodyTextStyle),
            );
          }
        },
      ),
    );
  }
}

class DeliveryItem extends StatelessWidget {
  final String storage;
  final String delivery;

  const DeliveryItem({
    Key? key,
    required this.storage,
    required this.delivery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.blue),
              const SizedBox(width: 8.0),
              Text(storage, style: const TextStyle(fontSize: 16.0)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: Column(
              children: [
                const Icon(Icons.arrow_downward, color: Colors.blue),
                Row(
                  children: [
                    const Icon(Icons.store, color: Colors.blue),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        delivery,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
