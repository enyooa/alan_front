class PriceRequest {
  final String choiceStatus;
  final String userId; // Ensure userId is consistent in type
  final int? addressId;
  final List<ProductRequestItem> products; // Use a clear name for items in the request

  PriceRequest({
    required this.choiceStatus,
    required this.userId,
    this.addressId,
    required this.products,
  });

  Map<String, dynamic> toJson() {
    return {
      'choice_status': choiceStatus,
      'user_id': userId,
      'address_id': addressId,
      'products': products.map((product) => product.toJson()).toList(),
    };
  }
}

class ProductRequestItem {
  final String productId;
  final String unitMeasurement;
  final int amount;
  final double price;

  ProductRequestItem({
    required this.productId,
    required this.unitMeasurement,
    required this.amount,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'unit_measurement': unitMeasurement,
      'amount': amount,
      'price': price,
    };
  }
}


