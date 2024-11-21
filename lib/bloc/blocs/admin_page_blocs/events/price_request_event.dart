import 'package:cash_control/ui/main/models/price_request.dart';
import 'package:equatable/equatable.dart';

class PriceRequestEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreatePriceRequestEvent extends PriceRequestEvent {
  final PriceRequest priceRequest; // Use the PriceRequest model

  CreatePriceRequestEvent({required this.priceRequest});

  @override
  List<Object?> get props => [priceRequest];
}
