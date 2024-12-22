abstract class ProductSubCardState {}

class ProductSubCardInitial extends ProductSubCardState {}

class ProductSubCardLoading extends ProductSubCardState {}

class ProductSubCardsLoaded extends ProductSubCardState {
  final List<Map<String, dynamic>> productSubCards;

  ProductSubCardsLoaded(this.productSubCards);
}

class ProductSubCardCreated extends ProductSubCardState {
  final String message;

  ProductSubCardCreated(this.message);
}

class ProductSubCardUpdated extends ProductSubCardState {
  final String message;

  ProductSubCardUpdated({required this.message});
}

class ProductSubCardDeleted extends ProductSubCardState {
  final String message;

  ProductSubCardDeleted({required this.message});
}


class ProductSubCardError extends ProductSubCardState {
  final String message;

  ProductSubCardError(this.message);
}
