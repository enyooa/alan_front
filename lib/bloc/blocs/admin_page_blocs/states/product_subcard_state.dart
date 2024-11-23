import 'package:equatable/equatable.dart';

abstract class ProductSubCardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductSubCardInitial extends ProductSubCardState {}

class ProductSubCardLoading extends ProductSubCardState {}

class ProductSubCardCreated extends ProductSubCardState {
  final String message;

  ProductSubCardCreated(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductSubCardError extends ProductSubCardState {
  final String error;

  ProductSubCardError(this.error);

  @override
  List<Object?> get props => [error];
}
