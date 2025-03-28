import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:alan/bloc/blocs/packer_page_blocs/blocs/packer_order_bloc.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/events/packer_order_event.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/states/packer_order_state.dart';

import 'package:alan/constant.dart';

// If you still want to link to the InvoicePage:
import 'package:alan/ui/packer/widgets/create_invoice.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PackerOrdersBloc(baseUrl: baseUrl)
        ..add(FetchSingleOrderEvent(orderId: widget.orderId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Детали Заявки', style: headingStyle),
          backgroundColor: primaryColor,
        ),
        body: BlocBuilder<PackerOrdersBloc, PackerOrdersState>(
          builder: (context, state) {
            if (state is SingleOrderLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SingleOrderLoaded) {
              final order = state.orderDetails;
              final address = order['address'] ?? 'Не указан';
              final createdAt = _formatDate(order['created_at'] ?? '');

              // The order might have a numeric status_id and/or a text-based "status".
              // If your backend only returns status_id, read from that.
              final int? statusId = order['status_id'] as int?;
              final products = order['order_products'] ?? [];

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Адрес доставки: $address', style: subheadingStyle),
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

                          final productName =
                              productCard['name_of_products'] ?? 'Не указано';
                          final productDescription =
                              productCard['description'] ?? 'Нет описания';

                          final quantity = product['quantity'] ?? 0;
                          final price = product['price'] ?? 0;
                          final totalsum = product['totalsum'] ?? 0;

                          // If you had a photo
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
                                          'Количество: $quantity | Цена: $price ₸ | Сумма: $totalsum ₸',
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

                    // Conditionally show the "Создать накладную" button only if status_id != 4
                    // If status_id == 4 => "исполнено"
                    const SizedBox(height: 16),
                    if (statusId != 4) ...[
                      ElevatedButton.icon(
                        onPressed: () {
                          // Just open InvoicePage with no extra BLoC
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                // Re-use the same PackerOrdersBloc from above
                                value: context.read<PackerOrdersBloc>(),
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
                    ] else ...[
                      // If status_id == 4 => show a short message
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        child: const Text(
                          'Статус: исполнено - редактирование не доступно',
                          style: bodyTextStyle,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            } else if (state is PackerOrdersError) {
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
