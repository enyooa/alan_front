import 'package:equatable/equatable.dart';

abstract class SalesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchSalesEvent extends SalesEvent {}

class CreateSalesEvent extends SalesEvent {
  final int productSubcardId;
  final String? unitMeasurement;
  final int amount;
  final int price;

  CreateSalesEvent({
    required this.productSubcardId,
    this.unitMeasurement,
    required this.amount,
    required this.price,
  });

  @override
  List<Object?> get props => [
        productSubcardId,
        unitMeasurement,
        amount,
        price,
      ];
}
class CreateMultipleSalesEvent extends SalesEvent {
  final List<Map<String, dynamic>> sales;

  CreateMultipleSalesEvent({required this.sales});

  @override
  List<Object?> get props => [sales];
}

