import 'package:equatable/equatable.dart';

abstract class ProductSubCardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateProductSubCardEvent extends ProductSubCardEvent {
  final int productCardId;
  final int? clientId;
  final double quantitySold;
  final double priceAtSale;

  CreateProductSubCardEvent({
    required this.productCardId,
    this.clientId,
    required this.quantitySold,
    required this.priceAtSale,
  });

  @override
  List<Object?> get props => [productCardId, clientId, quantitySold, priceAtSale];
}
