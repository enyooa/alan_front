class ProductSubCard {
  final int id;
  final int productCardId;
  final String name;
  final double brutto;
  final double netto;

  ProductSubCard({
    required this.id,
    required this.productCardId,
    required this.name,
    required this.brutto,
    required this.netto,
  });

  factory ProductSubCard.fromJson(Map<String, dynamic> json) {
    return ProductSubCard(
      id: json['id'],
      productCardId: json['product_card_id'],
      name: json['name'],
      brutto: json['brutto'].toDouble(),
      netto: json['netto'].toDouble(),
    );
  }
}
