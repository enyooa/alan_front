import 'package:alan/bloc/blocs/client_page_blocs/events/price_offer_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/blocs/client_order_items_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/blocs/price_offer_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/client_order_items_event.dart';
import 'package:alan/bloc/blocs/client_page_blocs/states/client_order_items_state.dart';
import 'package:alan/bloc/blocs/client_page_blocs/states/price_offer_state.dart';
import 'package:alan/constant.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/price_offer_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/blocs/client_order_items_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/blocs/price_offer_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/client_order_items_event.dart';
import 'package:alan/bloc/blocs/client_page_blocs/states/client_order_items_state.dart';
import 'package:alan/bloc/blocs/client_page_blocs/states/price_offer_state.dart';
import 'package:alan/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/blocs/client_order_items_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/blocs/price_offer_bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/client_order_items_event.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/price_offer_event.dart';
import 'package:alan/bloc/blocs/client_page_blocs/states/client_order_items_state.dart';
import 'package:alan/bloc/blocs/client_page_blocs/states/price_offer_state.dart';
import 'package:alan/constant.dart';

class CalculationsPage extends StatefulWidget {
  const CalculationsPage({Key? key}) : super(key: key);

  @override
  _CalculationsPageState createState() => _CalculationsPageState();
}

class _CalculationsPageState extends State<CalculationsPage> {
  final Set<int> favoriteOffers = {};
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    context.read<PriceOfferBloc>().add(FetchPriceOffersEvent());
    context.read<ClientOrderItemsBloc>().add(FetchClientOrderItemsEvent());
  }

  Widget _buildDropdown() {
    return DropdownButton<String>(
      value: selectedCategory,
      dropdownColor: primaryColor.withOpacity(0.9),
      style: subheadingStyle.copyWith(color: Colors.white),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
      items: const [
        DropdownMenuItem(
          value: 'All',
          child: Text('Все', style: headingStyle),
        ),
        DropdownMenuItem(
          value: 'PriceOffers',
          child: Text('Предложения', style: headingStyle),
        ),
        DropdownMenuItem(
          value: 'CourierDocuments',
          child: Text('Документы курьера', style: headingStyle),
        ),
      ],
      onChanged: (value) {
        setState(() {
          selectedCategory = value!;
        });
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Фильтр:',
            style: headingStyle,
          ),
          _buildDropdown(),
        ],
      ),
    );
  }

  Widget _buildPriceOffers(BuildContext context) {
    return BlocBuilder<PriceOfferBloc, PriceOfferState>(
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
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: priceOffers.length,
            itemBuilder: (context, index) {
              final offer = priceOffers[index];
              final productSubCard = offer['product_sub_card'];
              final productCard = productSubCard['product_card'];
              final photoUrl = productCard['photo_product'] != null
                  ? '${baseUrl}${productCard['photo_product']}'
                  : '';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 6,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      photoUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                photoUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image_not_supported, size: 80, color: borderColor),
                              ),
                            )
                          : const Icon(Icons.image_not_supported, size: 80, color: borderColor),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productCard['name_of_products'] ?? 'Товар',
                              style: subheadingStyle.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              productCard['description'] ?? 'Описание отсутствует',
                              style: captionStyle,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${offer['price']} ₸',
                              style: subheadingStyle.copyWith(color: primaryColor),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: favoriteOffers.contains(offer['id'])
                            ? const Icon(Icons.favorite, color: Colors.red)
                            : const Icon(Icons.favorite_border, color: textColor),
                        onPressed: () {
                          setState(() {
                            if (favoriteOffers.contains(offer['id'])) {
                              favoriteOffers.remove(offer['id']);
                            } else {
                              favoriteOffers.add(offer['id']);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCourierDocuments(BuildContext context) {
    return BlocBuilder<ClientOrderItemsBloc, ClientOrderItemsState>(
      builder: (context, state) {
        if (state is ClientOrderItemsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ClientOrderItemsLoaded) {
          final documents = state.clientOrderItems;

          if (documents.isEmpty) {
            return const Center(
              child: Text('Нет доступных документов.', style: bodyTextStyle),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final document = documents[index];
              final courierDocument = document['courier_document'];
              final deliveryAddress = document['order']?['address'] ?? 'Не указано';
              final isConfirmed = courierDocument?['is_confirmed'] ?? false;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 6,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  title: Text(
                    'Адрес: $deliveryAddress',
                    style: subheadingStyle.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'ID документа: ${courierDocument?['id']}',
                    style: captionStyle,
                  ),
                  trailing: ElevatedButton(
                    onPressed: isConfirmed
                        ? null
                        : () {
                            context.read<ClientOrderItemsBloc>().add(
                                  ConfirmCourierDocumentEvent(
                                    courierDocumentId: courierDocument?['id'],
                                  ),
                                );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isConfirmed ? borderColor : primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isConfirmed ? 'Подтверждено' : 'Подтвердить'),
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: pagePadding,
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (selectedCategory == 'All' || selectedCategory == 'PriceOffers')
                      _buildPriceOffers(context),
                    if (selectedCategory == 'All' || selectedCategory == 'CourierDocuments')
                      _buildCourierDocuments(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
