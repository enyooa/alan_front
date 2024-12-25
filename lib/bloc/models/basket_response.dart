import 'package:cash_control/bloc/models/basket_item.dart';

class BasketResponse {
  final List<BasketItem> items;

  BasketResponse({required this.items});

  factory BasketResponse.fromJson(Map<String, dynamic> json) {
    return BasketResponse(
      items: (json['basket'] as List<dynamic>)
          .map((item) => BasketItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
