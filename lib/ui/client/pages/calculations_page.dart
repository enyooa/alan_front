import 'package:cash_control/bloc/blocs/client_page_blocs/blocs/price_offer_bloc.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/states/basket_state.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/states/price_offer_state.dart';
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
                                              context.read<BasketBloc>().add(
                                                    AddToBasketEvent({
                                                      'product_subcard_id': productSubCard['id'],
                                                      'source_table': 'price_requests',
                                                      'quantity': 1,
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

              // Section: Packer Documents
              const Text(
                'Документы упаковщика',
                style: subheadingStyle,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 300, // Set a fixed height for the scrollable list
                child: BlocBuilder<PackerDocumentBloc, PackerDocumentState>(
                  builder: (context, state) {
                    if (state is PackerDocumentLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is PackerDocumentsFetched) {
                      final documents = state.documents;

                      if (documents.isEmpty) {
                        return const Center(
                          child: Text(
                            'Нет доступных документов.',
                            style: bodyTextStyle,
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          final document = documents[index];
                          final courierId = document['id_courier'];
                          final deliveryAddress = document['delivery_address'];
                          final amount = document['amount_of_products'];

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text('Курьер: $courierId', style: subheadingStyle),
                              subtitle: Text(
                                'Адрес: $deliveryAddress\nКол-во: $amount',
                                style: bodyTextStyle,
                              ),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  // Confirm logic here
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                                child: const Text(
                                  'Подтвердить',
                                  style: buttonTextStyle,
                                ),
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
            ],
          ),
        ),
      ),
    );
  }
}
