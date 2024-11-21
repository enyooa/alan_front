import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ProductCardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchProductCardsEvent extends ProductCardEvent {}

class CreateProductCardEvent extends ProductCardEvent {
  final String nameOfProducts;
  final String description;
  final String country;
  final String type;
  final double brutto;
  final double netto;
  final File? photoProduct;

  CreateProductCardEvent({
    required this.nameOfProducts,
    required this.description,
    required this.country,
    required this.type,
    required this.brutto,
    required this.netto,
    this.photoProduct,
  });

  @override
  List<Object?> get props => [
        nameOfProducts,
        description,
        country,
        type,
        brutto,
        netto,
        photoProduct
      ];
}
