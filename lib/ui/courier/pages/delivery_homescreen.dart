import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_control/bloc/blocs/courier_page_blocs/blocs/courier_document_bloc.dart';
import 'package:cash_control/bloc/blocs/courier_page_blocs/events/courier_document_event.dart';
import 'package:cash_control/bloc/blocs/courier_page_blocs/states/courier_document_state.dart';
import 'package:cash_control/constant.dart';

class DeliveryHomeScreen extends StatelessWidget {
  final List<String> fakeStorageAddresses = [
    'Склад №1 Кажымуханова 55',
    'Склад №2 Кажымуханова 60',
    'Склад №3 Кажымуханова 65',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CourierDocumentBloc()..add(FetchCourierDocumentsEvent()),
      child: Scaffold(
        
        body: BlocBuilder<CourierDocumentBloc, CourierDocumentState>(
          builder: (context, state) {
            if (state is CourierDocumentLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CourierDocumentLoaded) {
              final documents = state.documents;

              if (documents.isEmpty) {
                return const Center(
                  child: Text('Нет доступных документов', style: bodyTextStyle),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final storage = fakeStorageAddresses[index % fakeStorageAddresses.length];
                  final delivery = documents[index]['delivery_address'] ?? 'Не указано';

                  return DeliveryItem(
                    storage: storage,
                    delivery: delivery,
                  );
                },
              );
            } else if (state is CourierDocumentError) {
              return Center(
                child: Text('Ошибка: ${state.error}', style: bodyTextStyle.copyWith(color: errorColor)),
              );
            } else {
              return const Center(child: Text('Ошибка загрузки данных.', style: bodyTextStyle));
            }
          },
        ),
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
