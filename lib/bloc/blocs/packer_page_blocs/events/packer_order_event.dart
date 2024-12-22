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
