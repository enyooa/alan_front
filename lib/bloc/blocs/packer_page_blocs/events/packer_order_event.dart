import 'package:equatable/equatable.dart';

abstract class PackerOrdersEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchPackerOrdersEvent extends PackerOrdersEvent {}

class FetchSingleOrderEvent extends PackerOrdersEvent {
  final int orderId;
  FetchSingleOrderEvent({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class UpdateOrderDetailsEvent extends PackerOrdersEvent {
  final int orderId;
  final List<Map<String, dynamic>> updatedProducts;

  UpdateOrderDetailsEvent({required this.orderId, required this.updatedProducts});

  @override
  List<Object?> get props => [orderId, updatedProducts];
}

/// NEW EVENT for submitting an order
class SubmitOrderEvent extends PackerOrdersEvent {
  final int orderId;
  final List<Map<String, dynamic>> products; 
  // e.g. [ { "order_item_id": 33, "packer_quantity": 2 }, ... ]

  SubmitOrderEvent({required this.orderId, required this.products});

  @override
  List<Object?> get props => [orderId, products];
}
