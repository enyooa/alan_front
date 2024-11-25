import 'package:equatable/equatable.dart';

class ProductSubCardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateProductSubCardEvent extends ProductSubCardEvent {
  final int productCardId; // ID of the parent ProductCard
  final String name;
  final double brutto;
  final double netto;

  CreateProductSubCardEvent({
    required this.productCardId,
    required this.name,
    required this.brutto,
    required this.netto,
  });

  @override
  List<Object?> get props => [productCardId, name, brutto, netto];
}
