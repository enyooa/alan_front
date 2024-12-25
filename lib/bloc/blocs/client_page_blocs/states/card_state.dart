abstract class ProductCardState {}

class ProductCardInitial extends ProductCardState {}

class ProductCardLoading extends ProductCardState {}
class ProductCardError extends ProductCardState {
  final String message;

  ProductCardError(this.message);
}

class ProductCardsLoaded extends ProductCardState {
  final List<Map<String, dynamic>> productCards;

  ProductCardsLoaded(this.productCards);
}
