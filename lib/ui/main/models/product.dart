// lib/models/product_model.dart
class Product {
  final int id;
  final String nameOfProducts;
  final String? description;
  final String? country;
  final String? type;
  final double brutto;
  final double netto;
  final String? photoProduct;

  Product({
    required this.id,
    required this.nameOfProducts,
    this.description,
    this.country,
    this.type,
    required this.brutto,
    required this.netto,
    this.photoProduct,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      nameOfProducts: json['name_of_products'],
      description: json['description'],
      country: json['country'],
      type: json['type'],
      brutto: double.parse(json['brutto'].toString()),
      netto: double.parse(json['netto'].toString()),
      photoProduct: json['photo_product'],
    );
  }
}
