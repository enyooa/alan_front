import 'package:equatable/equatable.dart';

abstract class ClientOrderState extends Equatable {
  const ClientOrderState();

  @override
  List<Object?> get props => [];
}

class ClientOrderInitial extends ClientOrderState {}

class ClientOrderLoading extends ClientOrderState {}

/// Once fetched, we store the list of orders (each order has order_items, etc.)
class ClientOrdersFetched extends ClientOrderState {
  final List<Map<String, dynamic>> orders; 
  // "orders" might be a JSON array with [ { "id":..., "status_id":..., "order_items":[...] }, ... ]

  const ClientOrdersFetched(this.orders);

  @override
  List<Object?> get props => [orders];
}

class ClientOrderError extends ClientOrderState {
  final String message;

  const ClientOrderError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Once confirmed, we can store a message or fetch an updated list
class ClientOrderConfirmed extends ClientOrderState {
  final String message;
  const ClientOrderConfirmed(this.message);

  @override
  List<Object?> get props => [message];
}
