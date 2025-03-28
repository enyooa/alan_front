
import 'package:alan/bloc/blocs/courier_page_blocs/blocs/courier_order_bloc.dart';
import 'package:alan/bloc/blocs/courier_page_blocs/blocs/courier_document_bloc.dart';
import 'package:alan/bloc/blocs/courier_page_blocs/events/courier_order_event.dart';
import 'package:alan/bloc/blocs/courier_page_blocs/states/courier_order_state.dart';
import 'package:alan/ui/courier/widgets/create_invoice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:intl/intl.dart'; // For date formatting
import 'package:alan/constant.dart';

class OrderDetailsPage extends StatefulWidget {
  final int orderId;

  const OrderDetailsPage({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd MMMM yyyy, HH:mm', 'ru').format(date); // Russian locale
    } catch (e) {
      return 'Неизвестно';
    }
  }

  String _translateStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Ожидает';
      default:
        return 'Неизвестно';
    }
  }

  Widget _buildActionButtons(BuildContext context, Map<String, dynamic> order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => CourierDocumentBloc(),
                  child: InvoicePage(orderDetails: order),
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          icon: const Icon(Icons.receipt_long, color: Colors.white),
          label: const Text('Создать накладную', style: buttonTextStyle),
        ),
        ElevatedButton.icon(
          onPressed: () {
            // Implement print functionality
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: buttonPadding,
          ),
          icon: const Icon(Icons.print, color: Colors.white),
          label: const Text('Печать', style: buttonTextStyle),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CourierOrdersBloc(baseUrl: baseUrl)
        ..add(FetchSingleOrderEvent(orderId: widget.orderId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Детали Заявки', style: headingStyle),
          backgroundColor: primaryColor,
        ),
        body: BlocBuilder<CourierOrdersBloc, CourierOrdersState>(
          builder: (context, state) {
            if (state is SingleOrderLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SingleOrderLoaded) {
              final order = state.orderDetails;
              final address = order['address'] ?? 'Не указан';
              final status = _translateStatus(order['status'] ?? '');
              final createdAt = _formatDate(order['created_at'] ?? '');
              final products = order['order_products'] ?? [];

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Адрес доставки: $address', style: subheadingStyle),
                    const SizedBox(height: 8),
                    Text('Статус: $status', style: bodyTextStyle),
                    const SizedBox(height: 8),
                    Text('Дата создания: $createdAt', style: bodyTextStyle),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Product List
                    Expanded(
                      child: ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final productSubCard = product['product_sub_card'];
                          final productCard = productSubCard?['product_card'] ?? {};
                          final productName = productCard['name_of_products'] ?? 'Не указано';
                          final productDescription = productCard['description'] ?? 'Нет описания';
                          final quantity = product['packer_quantity'] ?? 0;
                          final price = product['price'] ?? 0;

                          final photoUrl = productCard['photo_product'] != null
                              ? '{$basePhotoUrl}storage/products/${productCard['photo_product']}'
                              : '';

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  photoUrl.isNotEmpty
                                      ? Image.network(
                                          photoUrl,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.broken_image, size: 80),
                                        )
                                      : const Icon(Icons.image_not_supported, size: 80),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(productName, style: subheadingStyle),
                                        Text(productDescription, style: bodyTextStyle),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Количество: $quantity | Цена: $price ₸',
                                          style: bodyTextStyle,
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
                    _buildActionButtons(context, order),
                  ],
                ),
              );
            } else if (state is CourierOrdersError) {
              return Center(
                child: Text(
                  'Ошибка: ${state.message}',
                  style: bodyTextStyle.copyWith(color: errorColor),
                ),
              );
            } else {
              return const Center(child: Text('Ошибка загрузки.'));
            }
          },
        ),
      ),
    );
  }
}
