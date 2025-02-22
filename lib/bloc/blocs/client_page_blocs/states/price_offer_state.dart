import 'package:equatable/equatable.dart';

abstract class PriceOfferState extends Equatable {
  const PriceOfferState();

  @override
  List<Object?> get props => [];
}

class PriceOfferInitial extends PriceOfferState {}

class PriceOfferLoading extends PriceOfferState {}

class PriceOffersFetched extends PriceOfferState {
  final List<dynamic> priceOffers; 
  // "priceOffers" here actually refers to a list of PriceOfferOrders from your JSON.

  const PriceOffersFetched({required this.priceOffers});

  @override
  List<Object?> get props => [priceOffers];
}

class PriceOfferError extends PriceOfferState {
  final String message;
  const PriceOfferError(this.message);

  @override
  List<Object?> get props => [message];
}
