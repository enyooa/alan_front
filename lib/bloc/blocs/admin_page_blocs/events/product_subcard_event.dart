import 'dart:convert';

abstract class ProductSubCardEvent {}

// Fetch subcards
class FetchProductSubCardsEvent extends ProductSubCardEvent {}

// Create a new subcard
class CreateProductSubCardEvent extends ProductSubCardEvent {
  final int productCardId;
  final double quantitySold;
  final int priceAtSale;

  CreateProductSubCardEvent({
    required this.productCardId,
    required this.quantitySold,
    required this.priceAtSale,
  });
}
