abstract class ProductCardState {}

class ProductCardInitial extends ProductCardState {}

class ProductCardLoading extends ProductCardState {}
class ProductCardLoaded extends ProductCardState {}


class ProductCardSuccess extends ProductCardState {
  final String message;

  ProductCardSuccess(this.message);
}

class ProductCardError extends ProductCardState {
  final String error;

  ProductCardError(this.error);
}
