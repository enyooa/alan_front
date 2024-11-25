class ProductCard {
  final int id;
  final String nameOfProducts;
  final String? description;
  final String? country;
  final String? type;
  final String? photoUrl;

  ProductCard({
    required this.id,
    required this.nameOfProducts,
    this.description,
    this.country,
    this.type,
    this.photoUrl,
  });

  factory ProductCard.fromJson(Map<String, dynamic> json) {
    return ProductCard(
      id: json['id'],
      nameOfProducts: json['name_of_products'],
      description: json['description'],
      country: json['country'],
      type: json['type'],
      photoUrl: json['photo_url'],
    );
  }
}
