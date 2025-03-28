// order_details_page.dart
import 'package:flutter/material.dart';
import 'package:alan/constant.dart';

class OrderDetailsPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailsPage({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderId = order['id'];
    final statusId = order['status_id'] as int?;
    final address = order['address'] ?? 'Без адреса';
    final orderItems = order['order_items'] ?? [];

    double sum = 0.0;
    for (final item in orderItems) {
      final price = (item['price'] ?? 0).toDouble();
      final qty   = (item['courier_quantity'] ?? 0).toDouble();
      sum += price * qty;
    }

    // No "confirm" button logic here – no BLoC usage.
    final bool isDone = (statusId == 4);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Заказ #$orderId', style: headingStyle),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Адрес: $address', style: subheadingStyle),
            const SizedBox(height: 8),
            Text('Сумма: ${sum.toStringAsFixed(2)} ₸',
                style: subheadingStyle.copyWith(color: primaryColor)),
            const SizedBox(height: 16),
            Text('Товары:', style: subheadingStyle),
            Expanded(
              child: ListView.builder(
                itemCount: orderItems.length,
                itemBuilder: (context, index) {
                  final item = orderItems[index];
                  final productName = item['product_sub_card']?['name'] ?? 'Товар';
                  final quantity = item['courier_quantity'] ?? 0;
                  final price = item['price'] ?? 0;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: Text(productName, style: subheadingStyle),
                      subtitle: Text(
                        'Кол-во: $quantity | Цена: $price ₸',
                        style: bodyTextStyle,
                      ),
                    ),
                  );
                },
              ),
            ),
            // No "Confirm" button here
          ],
        ),
      ),
    );
  }
}
