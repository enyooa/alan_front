
import 'package:equatable/equatable.dart';

abstract class InvoiceEvent extends Equatable {
  const InvoiceEvent();

  @override
  List<Object?> get props => [];
}

class FetchInvoiceOrders extends InvoiceEvent {}

class SubmitCourierDocument extends InvoiceEvent {
  final int orderId;
  final List<Map<String, dynamic>> updatedProducts;

  const SubmitCourierDocument({
    required this.orderId,
    required this.updatedProducts,
  });

  @override
  List<Object?> get props => [orderId, updatedProducts];
}
