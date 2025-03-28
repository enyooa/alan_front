import 'package:equatable/equatable.dart';

abstract class ClientOrderEvent extends Equatable {
  const ClientOrderEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch all orders for the client
class FetchClientOrdersEvent extends ClientOrderEvent {}

/// Confirm (set status to "исполнено") for a specific order
class ConfirmClientOrderEvent extends ClientOrderEvent {
  final int orderId;

  const ConfirmClientOrderEvent({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}
