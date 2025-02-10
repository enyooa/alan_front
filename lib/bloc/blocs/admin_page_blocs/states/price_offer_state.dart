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

class PriceOffersFetched extends PriceOfferState {
  final List<Map<String, dynamic>> clientUsers;
  final List<Map<String, dynamic>> subCards;
  final List<Map<String, dynamic>> units;

  PriceOffersFetched({
    required this.clientUsers,
    required this.subCards,
    required this.units,
  });

  @override
  List<Object?> get props => [clientUsers, subCards, units];
}



class PriceOfferUpdated extends PriceOfferState {
  final String message;

  PriceOfferUpdated({required this.message});

  @override
  List<Object?> get props => [message];
}

class PriceOfferDeleted extends PriceOfferState {
  final String message;

  PriceOfferDeleted({required this.message});

  @override
  List<Object?> get props => [message];
}
