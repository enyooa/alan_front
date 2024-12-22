import 'package:equatable/equatable.dart';

abstract class SalesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchSalesWithDetailsEvent extends SalesEvent {}

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
class UpdateSalesEvent extends SalesEvent {
  final int id;
  final Map<String, dynamic> updatedFields;

  UpdateSalesEvent({required this.id, required this.updatedFields});

  @override
  List<Object?> get props => [id, updatedFields];
}

class DeleteSalesEvent extends SalesEvent {
  final int id;

  DeleteSalesEvent({required this.id});

  @override
  List<Object?> get props => [id];
}