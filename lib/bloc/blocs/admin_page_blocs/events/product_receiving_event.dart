// априходование товара
import 'package:equatable/equatable.dart';

abstract class ProductReceivingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchProductReceivingEvent extends ProductReceivingEvent {
  @override
  List<Object?> get props => [];
}
class FetchSingleProductReceivingEvent extends ProductReceivingEvent {
  final int docId;
  FetchSingleProductReceivingEvent(this.docId);

  @override
  List<Object?> get props => [docId];
}


class UpdateProductReceivingEvent extends ProductReceivingEvent {
  final int docId;
  final Map<String, dynamic> updatedData;
  UpdateProductReceivingEvent({required this.docId, required this.updatedData});

  @override
  List<Object?> get props => [docId, updatedData];
}
class CreateProductReceivingEvent extends ProductReceivingEvent {
  final int productCardId;
  final String? unitMeasurement;
  final double quantity;
  final int price;
  final int totalSum;
  final String? date; // Optional date field

  CreateProductReceivingEvent({
    required this.productCardId,
    this.unitMeasurement,
    required this.quantity,
    required this.price,
    required this.totalSum,
    this.date,
  });

  @override
  List<Object?> get props => [
        productCardId,
        unitMeasurement,
        quantity,
        price,
        totalSum,
        date,
      ];
}

class CreateBulkProductReceivingEvent extends ProductReceivingEvent {
  final List<Map<String, dynamic>> receivings;

  CreateBulkProductReceivingEvent({required this.receivings});

  @override
  List<Object?> get props => [receivings];
}
