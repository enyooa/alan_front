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
  final double totalSum;


  SubmitPriceOfferEvent({
    required this.clientId,
    required this.startDate,
    required this.endDate,
    required this.priceOfferRows,
    required this.totalSum,

  });

  @override
  List<Object?> get props => [clientId, startDate, endDate, priceOfferRows,totalSum];
}
class FetchPriceOffersEvent extends PriceOfferEvent {}

class UpdatePriceOfferEvent extends PriceOfferEvent {
  final int id;
  final Map<String, dynamic> updatedFields;

  UpdatePriceOfferEvent({required this.id, required this.updatedFields});

  @override
  List<Object?> get props => [id, updatedFields];
}

class DeletePriceOfferEvent extends PriceOfferEvent {
  final int id;

  DeletePriceOfferEvent({required this.id});

  @override
  List<Object?> get props => [id];
}
