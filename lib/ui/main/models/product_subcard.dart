class ProductSubCard {
  final int id;
  final String nameOfProducts;

  ProductSubCard({
    required this.id,
    required this.nameOfProducts,
  });

  factory ProductSubCard.fromJson(Map<String, dynamic> json) {
    return ProductSubCard(
      id: json['id'] as int,
      nameOfProducts: json['name_of_products'] as String,
    );
  }
}
