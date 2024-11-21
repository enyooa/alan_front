// lib/bloc/states/product_state.dart
import 'package:cash_control/ui/main/models/product_card.dart';
import 'package:equatable/equatable.dart';

abstract class ProductState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductCreated extends ProductState {}

class ProductsLoaded extends ProductState {
  final List<ProductCard> products;

  ProductsLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

class ProductError extends ProductState {
  final String message;

  ProductError({required this.message});

  @override
  List<Object?> get props => [message];
}
