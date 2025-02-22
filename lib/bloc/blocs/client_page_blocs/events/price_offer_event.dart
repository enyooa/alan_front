import 'package:equatable/equatable.dart';

abstract class PriceOfferEvent extends Equatable {
  const PriceOfferEvent();

  @override
  List<Object?> get props => [];
}

class FetchPriceOffersEvent extends PriceOfferEvent {
  // If needed, you can pass parameters here (e.g., clientId)
  const FetchPriceOffersEvent();
}
