import 'package:cash_control/bloc/blocs/admin_page_blocs/blocs/product_card_bloc.dart';

abstract class ProductCardState {}

class ProductCardInitial extends ProductCardState {}

class ProductCardLoading extends ProductCardState {}

class ProductCardSuccess extends ProductCardState {
  final String message;

  ProductCardSuccess(this.message);
}

class ProductCardError extends ProductCardState {
  final String error;

  ProductCardError(this.error);
}

class ProductCardLoaded extends ProductCardState {
  final List<ProductCard> productCards;

  ProductCardLoaded({required this.productCards});
}
