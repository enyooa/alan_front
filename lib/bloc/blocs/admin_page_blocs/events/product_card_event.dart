import 'dart:io';

abstract class ProductCardEvent {}

// Event for creating a product card
class CreateProductCardEvent extends ProductCardEvent {
  final String nameOfProducts;
  final String? description;
  final String? country;
  final String? type;
  final double brutto;
  final double netto;
  final File? photoProduct;

  CreateProductCardEvent({
    required this.nameOfProducts,
    this.description,
    this.country,
    this.type,
    required this.brutto,
    required this.netto,
    this.photoProduct,
  });
}
class FetchProductCardsEvent extends ProductCardEvent {}
