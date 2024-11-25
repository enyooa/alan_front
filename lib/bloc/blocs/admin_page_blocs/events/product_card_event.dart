import 'dart:io';
import 'package:equatable/equatable.dart';

class ProductCardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}
class FetchProductCardsEvent extends ProductCardEvent {}

class CreateProductCardEvent extends ProductCardEvent {
  final String nameOfProducts;
  final String? description;
  final String? country;
  final String? type;
  final File? photoProduct;

  CreateProductCardEvent({
    required this.nameOfProducts,
    this.description,
    this.country,
    this.type,
    this.photoProduct,
  });

  @override
  List<Object?> get props => [nameOfProducts, description, country, type, photoProduct];
}
