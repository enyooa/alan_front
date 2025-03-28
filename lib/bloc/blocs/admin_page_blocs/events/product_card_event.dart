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

// product_card_event.dart
class FetchSingleProductCardEvent extends ProductCardEvent {
  final int id;
  FetchSingleProductCardEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateProductCardEvent extends ProductCardEvent {
  final int id;
  final Map<String, dynamic> updatedFields;
  final File? photoFile; // <--- ADD THIS

  UpdateProductCardEvent({
    required this.id,
    required this.updatedFields,
    this.photoFile,
  });

  @override
  List<Object?> get props => [id, updatedFields, photoFile];
}


class DeleteProductCardEvent extends ProductCardEvent {
  final int id;

  DeleteProductCardEvent({required this.id});

  @override
  List<Object?> get props => [id];
}