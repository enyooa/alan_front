abstract class ProductSubCardState {}

class ProductSubCardInitial extends ProductSubCardState {}

class ProductSubCardLoading extends ProductSubCardState {}

class ProductSubCardsLoaded extends ProductSubCardState {
  final List<Map<String, dynamic>> productSubCards;

  ProductSubCardsLoaded(this.productSubCards);
}
class ProductSubCardError extends ProductSubCardState {
  final String message;

  ProductSubCardError(this.message);
}