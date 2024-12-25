import 'package:equatable/equatable.dart';

abstract class PriceOfferState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PriceOfferInitial extends PriceOfferState {}

class PriceOfferLoading extends PriceOfferState {}

class PriceOfferError extends PriceOfferState {
  final String message;

  PriceOfferError({required this.message});

  @override
  List<Object?> get props => [message];
}

class PriceOffersFetched extends PriceOfferState {
  final List<Map<String, dynamic>> priceOffers;

  PriceOffersFetched({required this.priceOffers});

  @override
  List<Object?> get props => [priceOffers];
}