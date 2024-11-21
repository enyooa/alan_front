abstract class PriceRequestState {}

class PriceRequestInitial extends PriceRequestState {}

class PriceRequestLoading extends PriceRequestState {}

class PriceRequestCreated extends PriceRequestState {
  final String message;

  PriceRequestCreated(this.message);
}

class PriceRequestError extends PriceRequestState {
  final String message;

  PriceRequestError(this.message);
}
