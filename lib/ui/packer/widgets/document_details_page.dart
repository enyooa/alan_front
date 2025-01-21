import 'package:flutter/material.dart';
import 'package:alan/constant.dart';

class HistoryOrderDetailsPage extends StatelessWidget {
  final Map<String, dynamic> document;

  const HistoryOrderDetailsPage({Key? key, required this.document}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final address = document['address'] ?? 'Не указан';
    final documentId = document['packer_document_id'] ?? 'Не указан';
    final products = document['order_products'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали Накладной', style: headingStyle),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Адрес доставки: $address', style: subheadingStyle),
            const SizedBox(height: 8),
            Text('Документ ID: $documentId', style: bodyTextStyle),
            const Divider(height: 20),
            const Text('Продукты:', style: subheadingStyle),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final productSubCard = product['product_sub_card'] ?? {};
                  final productCard = productSubCard['product_card'] ?? {};
                  final productName = productCard['name_of_products'] ?? 'Не указано';
                  final description = productCard['description'] ?? 'Нет описания';
                  final quantity = product['quantity'] ?? 0;
                  final price = product['price'] ?? 0;
                  final total = quantity * price;

                  final photoUrl = productCard['photo_product'] != null
                      ? '$basePhotoUrl${productCard['photo_product']}'
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
                                Text(description, style: bodyTextStyle),
                                const SizedBox(height: 5),
                                Text(
                                  'Количество: $quantity | Цена: $price ₸ | Сумма: $total ₸',
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
          ],
        ),
      ),
    );
  }
}
