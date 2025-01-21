
import 'package:equatable/equatable.dart';

abstract class InvoiceState extends Equatable {
  const InvoiceState();

  @override
  List<Object?> get props => [];
}

class InvoiceInitial extends InvoiceState {}

class InvoiceLoading extends InvoiceState {}

class InvoiceOrdersFetched extends InvoiceState {
  final List<dynamic> orders;

  const InvoiceOrdersFetched({required this.orders});

  @override
  List<Object?> get props => [orders];
}

class InvoiceSubmitting extends InvoiceState {}

class InvoiceSubmitted extends InvoiceState {}

class InvoiceError extends InvoiceState {
  final String error;

  const InvoiceError({required this.error});

  @override
  List<Object?> get props => [error];
}
