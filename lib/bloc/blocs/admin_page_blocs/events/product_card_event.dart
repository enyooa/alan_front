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


class UpdateProductCardEvent extends ProductCardEvent {
  final int id;
  final Map<String, dynamic> updatedFields;

  UpdateProductCardEvent({required this.id, required this.updatedFields});

  @override
  List<Object?> get props => [id, updatedFields];
}

class DeleteProductCardEvent extends ProductCardEvent {
  final int id;

  DeleteProductCardEvent({required this.id});

  @override
  List<Object?> get props => [id];
}