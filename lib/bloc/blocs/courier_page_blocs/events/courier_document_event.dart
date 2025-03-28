import 'package:equatable/equatable.dart';

abstract class CourierDocumentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// We keep the same event name (SubmitCourierDocumentEvent),
/// but we'll interpret it as "submit courier data" to the order.
class SubmitCourierDocumentEvent extends CourierDocumentEvent {
  final int orderId;
  /// This is a list of { "order_item_id": int, "courier_quantity": int }
  final List<Map<String, dynamic>> orderProducts;

  SubmitCourierDocumentEvent({
    required this.orderId,
    required this.orderProducts,
  });

  @override
  List<Object?> get props => [orderId, orderProducts];
}

/// If you still want to fetch something later, keep this
class FetchCourierDocumentsEvent extends CourierDocumentEvent {}
