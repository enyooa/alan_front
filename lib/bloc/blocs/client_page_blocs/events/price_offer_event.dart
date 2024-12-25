import 'package:equatable/equatable.dart';

abstract class PriceOfferEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchPriceOffersEvent extends PriceOfferEvent {}
