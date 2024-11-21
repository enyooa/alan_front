import 'package:cash_control/ui/main/models/product_card.dart';
import 'package:equatable/equatable.dart';

abstract class ProductCardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductCardState {}

class ProductLoading extends ProductCardState {}

class ProductCardCreated extends ProductCardState {
  final String message;

  ProductCardCreated({required this.message});

  @override
  List<Object?> get props => [message];
}

class ProductCardError extends ProductCardState {
  final String message;

  ProductCardError({required this.message});

  @override
  List<Object?> get props => [message];
}
class ProductCardLoaded extends ProductCardState {
  final List<ProductCard> products;

  ProductCardLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}
