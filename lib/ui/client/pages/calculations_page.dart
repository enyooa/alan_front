import 'package:cash_control/bloc/blocs/client_page_blocs/blocs/client_order_items_bloc.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/blocs/price_offer_bloc.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/events/client_order_items_event.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/states/basket_state.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/states/client_order_items_state.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/states/price_offer_state.dart';
import 'package:cash_control/bloc/blocs/courier_page_blocs/blocs/courier_document_bloc.dart';
import 'package:cash_control/bloc/blocs/courier_page_blocs/events/courier_document_event.dart';
import 'package:cash_control/bloc/blocs/courier_page_blocs/states/courier_document_state.dart';
import 'package:cash_control/bloc/blocs/packer_page_blocs/events/couriers_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/price_offer_bloc.dart';
// import 'package:cash_control/bloc/blocs/admin_page_blocs/states/price_offer_state.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/blocs/favorites_bloc.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/events/favorites_event.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/blocs/basket_bloc.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/events/basket_event.dart';
import 'package:cash_control/bloc/blocs/packer_page_blocs/blocs/packer_document_bloc.dart';
import 'package:cash_control/bloc/blocs/packer_page_blocs/events/packer_document_event.dart';
import 'package:cash_control/bloc/blocs/packer_page_blocs/states/packer_document_state.dart';
import 'package:cash_control/constant.dart';

class CalculationsPage extends StatefulWidget {
  const CalculationsPage({Key? key}) : super(key: key);

  @override
  _CalculationsPageState createState() => _CalculationsPageState();
}

class _CalculationsPageState extends State<CalculationsPage> {
  final Set<int> favoriteOffers = {};

  @override
  void initState() {
    super.initState();
    context.read<PackerDocumentBloc>().add(FetchPackerDocumentsEvent());
    context.read<ClientOrderItemsBloc>().add(FetchClientOrderItemsEvent());

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Расчеты',
          style: headingStyle,
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section: Price Offers
              const Text(
                'Предложения',
                style: subheadingStyle,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 300, // Set a fixed height for the scrollable list
                child: BlocBuilder<PriceOfferBloc, PriceOfferState>(
                  builder: (context, state) {
                    if (state is PriceOfferLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is PriceOffersFetched) {
                      final priceOffers = state.priceOffers;

                      if (priceOffers.isEmpty) {
                        return const Center(
                          child: Text(
                            'Нет доступных предложений.',
                            style: bodyTextStyle,
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: priceOffers.length,
                        itemBuilder: (context, index) {
                          final offer = priceOffers[index];
                          final productSubCard = offer['product_sub_card'];
                          final productCard = productSubCard['product_card'];
                          final productId = offer['id'];

                          final photoUrl = productCard['photo_product'] != null
                              ? '${baseUrl}${productCard['photo_product']}'
                              : '';

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  // Product Image
                                  photoUrl.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            photoUrl,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                const Icon(Icons.broken_image, size: 80),
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
                                          productCard['name_of_products'] ?? 'Товар',
                                          style: subheadingStyle.copyWith(fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          productCard['description'] ?? 'Описание отсутствует',
                                          style: captionStyle,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${offer['price']} ₸',
                                          style: subheadingStyle.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Количество: ${offer['amount']} ${offer['unit_measurement']}',
                                          style: bodyTextStyle,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Action Buttons
                                  Column(
                                    children: [
                                      // Add to Cart Button
                                      BlocConsumer<BasketBloc, BasketState>(
                                        listener: (context, state) {
                                          if (state is BasketError) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text(state.message)),
                                            );
                                          }
                                        },
                                        builder: (context, basketState) {
                                          return IconButton(
                                            icon: const Icon(Icons.add_shopping_cart, color: primaryColor),
                                            onPressed: () {
                                              final price = double.tryParse(offer['price'].toString()) ?? 0.0;
                                              if (price <= 0) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Invalid price for the product')),
                                                );
                                                return;
                                              }

                                              context.read<BasketBloc>().add(
                                                    AddToBasketEvent({
                                                      'product_subcard_id': productSubCard['id'],
                                                      'source_table': 'price_requests',
                                                      'source_table_id': offer['id'], // Include source_table_id
                                                      'quantity': 1, // Ensure a default valid quantity
                                                      'price': price, // Pass the price explicitly
                                                    }),
                                                  );
                                            },

                                          );
                                        },
                                      ),

                                      // Favorite Button
                                      IconButton(
                                        icon: Icon(
                                          favoriteOffers.contains(productId)
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: favoriteOffers.contains(productId)
                                              ? Colors.red
                                              : Colors.grey,
                                        ),
                                        onPressed: () {
                                          if (favoriteOffers.contains(productId)) {
                                            context.read<FavoritesBloc>().add(
                                                  RemoveFromFavoritesEvent(
                                                    productSubcardId: productSubCard['id'],
                                                  ),
                                                );
                                          } else {
                                            context.read<FavoritesBloc>().add(
                                                  AddToFavoritesEvent(
                                                    product: {'product_subcard_id': productSubCard['id']},
                                                  ),
                                                );
                                          }
                                          setState(() {
                                            if (favoriteOffers.contains(productId)) {
                                              favoriteOffers.remove(productId);
                                            } else {
                                              favoriteOffers.add(productId);
                                            }
                                          });
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
                    } else {
                      return const Center(
                        child: Text(
                          'Нет данных.',
                          style: bodyTextStyle,
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
 Text(
          'Документы курьера',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 300, // Fixed height for the scrollable list
          child: BlocBuilder<ClientOrderItemsBloc, ClientOrderItemsState>(
            builder: (context, state) {
              if (state is ClientOrderItemsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ClientOrderItemsLoaded) {
final documents = state.clientOrderItems.toSet().toList(); // Remove duplicates
print('Documents: ${state.clientOrderItems}');

                if (documents.isEmpty) {
                  return const Center(
                    child: Text(
                      'Нет доступных документов.',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final document = documents[index];
                    final courierDocument = document['courier_document'];
                    final deliveryAddress = document['order']?['address'] ?? 'Не указано';
                    final courierDocumentId = courierDocument?['id'] ?? 0;
                    final isConfirmed = courierDocument?['is_confirmed'] ?? false;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          'Адрес: $deliveryAddress',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'ID документа: $courierDocumentId',
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: ElevatedButton(
                          onPressed: isConfirmed
                              ? null
                              : () {
                                  context.read<ClientOrderItemsBloc>().add(
                                        ConfirmCourierDocumentEvent(
                                          courierDocumentId: courierDocumentId,
                                        ),
                                      );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isConfirmed ? Colors.grey : Colors.blue,
                          ),
                          child: Text(
                            isConfirmed ? 'Подтверждено' : 'Подтвердить',
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else if (state is ClientOrderItemsError) {
                return Center(
                  child: Text(
                    'Ошибка: ${state.error}',
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                );
              } else {
                return const Center(
                  child: Text(
                    'Нет данных.',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }
            },
          ),
        ),
      

            ],
          ),
        ),
      ),
    );
  }
}
