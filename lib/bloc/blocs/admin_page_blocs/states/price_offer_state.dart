import 'package:equatable/equatable.dart';

abstract class PriceOfferState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PriceOfferInitial extends PriceOfferState {}

class PriceOfferLoading extends PriceOfferState {}

class PriceOfferSubmitted extends PriceOfferState {
  final String message;

  PriceOfferSubmitted({required this.message});

  @override
  List<Object?> get props => [message];
}

class PriceOfferError extends PriceOfferState {
  final String message;

  PriceOfferError({required this.message});

  @override
  List<Object?> get props => [message];
}
