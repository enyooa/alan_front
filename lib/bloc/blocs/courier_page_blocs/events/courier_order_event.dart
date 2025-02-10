import 'package:equatable/equatable.dart';

abstract class CourierOrdersEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchCourierOrdersEvent extends CourierOrdersEvent {}
class FetchSingleOrderEvent extends CourierOrdersEvent {
  final int orderId;

  FetchSingleOrderEvent({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}
class UpdateOrderDetailsEvent extends CourierOrdersEvent {
  final int orderId;
  final List<Map<String, dynamic>> updatedProducts;

  UpdateOrderDetailsEvent({required this.orderId, required this.updatedProducts});

  @override
  List<Object?> get props => [orderId, updatedProducts];
}
