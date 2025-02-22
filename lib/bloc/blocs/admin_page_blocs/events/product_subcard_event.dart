import 'package:equatable/equatable.dart';

abstract class ProductSubCardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}
//остаток

class FetchRemainingQuantityEvent extends ProductSubCardEvent {
  final int productSubcardId;

  FetchRemainingQuantityEvent(this.productSubcardId);

  @override
  List<Object?> get props => [productSubcardId];
}

//остаток

class CreateProductSubCardEvent extends ProductSubCardEvent {
  final int productCardId; // ID of the parent ProductCard
  final String name;
  

  CreateProductSubCardEvent({
    required this.productCardId,
    required this.name,
  });

  @override
  List<Object?> get props => [productCardId, name];
}

class FetchProductSubCardsEvent extends ProductSubCardEvent {
  @override
  List<Object?> get props => [];
}
class UpdateProductSubCardEvent extends ProductSubCardEvent {
  final int id;
  final Map<String, dynamic> updatedFields;

  UpdateProductSubCardEvent({required this.id, required this.updatedFields});

  @override
  List<Object?> get props => [id, updatedFields];
}

class DeleteProductSubCardEvent extends ProductSubCardEvent {
  final int id;

  DeleteProductSubCardEvent({required this.id});

  @override
  List<Object?> get props => [id];
}