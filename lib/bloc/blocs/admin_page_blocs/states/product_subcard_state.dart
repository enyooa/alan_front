import 'package:cash_control/ui/main/models/product_subcard.dart';
import 'package:equatable/equatable.dart';

abstract class ProductSubCardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductSubCardInitial extends ProductSubCardState {}

class ProductSubCardLoading extends ProductSubCardState {}

class ProductSubCardsLoaded extends ProductSubCardState {
  final List<ProductSubCard> subcards;

  ProductSubCardsLoaded(this.subcards);

  @override
  List<Object?> get props => [subcards];
}


class ProductSubCardSuccess extends ProductSubCardState {
  final String message;

  ProductSubCardSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductSubCardError extends ProductSubCardState {
  final String error;

  ProductSubCardError(this.error);

  @override
  List<Object?> get props => [error];
}
