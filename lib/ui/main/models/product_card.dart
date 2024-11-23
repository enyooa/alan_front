class ProductCard {
  final int id;
  final String nameOfProducts;
  final String? description;
  final String? country;
  final String? type;
  final double brutto;
  final double netto;
  final String? photoProduct;
  final String? photoUrl;

  ProductCard({
    required this.id,
    required this.nameOfProducts,
    this.description,
    this.country,
    this.type,
    required this.brutto,
    required this.netto,
    this.photoProduct,
    this.photoUrl,
  });

  factory ProductCard.fromJson(Map<String, dynamic> json) {
    return ProductCard(
      id: json['id'] ?? 0,
      nameOfProducts: json['name_of_products'] ?? 'Unknown Product',
      description: json['description'],
      country: json['country'],
      type: json['type'],
      brutto: double.tryParse(json['brutto']?.toString() ?? '0') ?? 0.0,
      netto: double.tryParse(json['netto']?.toString() ?? '0') ?? 0.0,
      photoProduct: json['photo_product'],
      photoUrl: json['photo_url'],
    );
  }
}
