class BasketItem {
  final int id;
  final int quantity;
  final int productSubcardId;
  final String sourceTable;
  final ProductDetails? productDetails;

  BasketItem({
    required this.id,
    required this.quantity,
    required this.productSubcardId,
    required this.sourceTable,
    this.productDetails,
  });

  factory BasketItem.fromJson(Map<String, dynamic> json) {
    return BasketItem(
      id: json['id'],
      quantity: json['quantity'],
      productSubcardId: json['product_subcard_id'],
      sourceTable: json['source_table'],
      productDetails: json['product_details'] != null
          ? ProductDetails.fromJson(json['product_details'])
          : null,
    );
  }
}

class ProductDetails {
  final String? subcardName;
  final int? brutto;
  final int? netto;
  final ProductCard? productCard;

  ProductDetails({
    this.subcardName,
    this.brutto,
    this.netto,
    this.productCard,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    return ProductDetails(
      subcardName: json['subcard_name'],
      brutto: json['brutto'],
      netto: json['netto'],
      productCard: json['product_card'] != null
          ? ProductCard.fromJson(json['product_card'])
          : null,
    );
  }
}

class ProductCard {
  final String? nameOfProducts;
  final String? description;
  final String? photoProduct;

  ProductCard({
    this.nameOfProducts,
    this.description,
    this.photoProduct,
  });

  factory ProductCard.fromJson(Map<String, dynamic> json) {
    return ProductCard(
      nameOfProducts: json['name_of_products'],
      description: json['description'],
      photoProduct: json['photo_product'],
    );
  }
}
