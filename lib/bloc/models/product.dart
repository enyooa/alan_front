class Product {
  final String id;
  final String name;
  final double price;
  final String photoUrl;
  int quantity;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.photoUrl,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'photoUrl': photoUrl,
      'quantity': quantity,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? 'No Name',
      price: map['price']?.toDouble() ?? 0.0,
      photoUrl: map['photoUrl'] ?? '',
      quantity: map['quantity'] ?? 1,
    );
  }
}
