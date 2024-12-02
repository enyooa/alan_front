import 'package:equatable/equatable.dart';

abstract class PriceOfferEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubmitPriceOfferEvent extends PriceOfferEvent {
  final int clientId; // ID of the client
  final String startDate; // Start date
  final String endDate; // End date
  final List<Map<String, dynamic>> priceOfferRows; // Rows of price offers

  SubmitPriceOfferEvent({
    required this.clientId,
    required this.startDate,
    required this.endDate,
    required this.priceOfferRows,
  });

  @override
  List<Object?> get props => [clientId, startDate, endDate, priceOfferRows];
}
