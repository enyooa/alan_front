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
//остаток
class RemainingQuantityLoading extends ProductSubCardState {
  final int productSubcardId;

  RemainingQuantityLoading(this.productSubcardId);

  @override
  List<Object> get props => [productSubcardId];
}

class RemainingQuantityLoaded extends ProductSubCardState {
  final int productSubcardId;
  final double remainingQuantity;
  final String unitMeasurement; // Add this field for unit measurement

  RemainingQuantityLoaded({
    required this.productSubcardId,
    required this.remainingQuantity,
    required this.unitMeasurement,
  });
}


class RemainingQuantityError extends ProductSubCardState {
  final String message;

  RemainingQuantityError(this.message);
}