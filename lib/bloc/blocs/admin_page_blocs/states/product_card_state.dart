abstract class ProductCardState {}

class ProductCardInitial extends ProductCardState {}

class ProductCardLoading extends ProductCardState {}

class ProductCardCreated extends ProductCardState {
  final String message;

  ProductCardCreated(this.message);
}

class ProductCardError extends ProductCardState {
  final String message;

  ProductCardError(this.message);
}

class ProductCardsLoaded extends ProductCardState {
  final List<Map<String, dynamic>> productCards;

  ProductCardsLoaded(this.productCards);
}
class SingleProductCardLoaded extends ProductCardState {
  final Map<String, dynamic> productCard;
  SingleProductCardLoaded(this.productCard);
}