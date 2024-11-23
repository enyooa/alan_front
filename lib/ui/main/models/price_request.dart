class PriceRequest {
  final String clientId;
  final List<PriceRequestItem> products;

  PriceRequest({
    required this.clientId,
    required this.products,
  });

  factory PriceRequest.fromJson(Map<String, dynamic> json) {
    return PriceRequest(
      clientId: json['client_id'],
      products: (json['products'] as List)
          .map((product) => PriceRequestItem.fromJson(product))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client_id': clientId,
      'products': products.map((product) => product.toJson()).toList(),
    };
  }
}

class PriceRequestItem {
  final String productCardId;
  final int quantity;
  final double price;

  PriceRequestItem({
    required this.productCardId,
    required this.quantity,
    required this.price,
  });

  factory PriceRequestItem.fromJson(Map<String, dynamic> json) {
    return PriceRequestItem(
      productCardId: json['product_card_id'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_card_id': productCardId,
      'quantity': quantity,
      'price': price,
    };
  }
}
