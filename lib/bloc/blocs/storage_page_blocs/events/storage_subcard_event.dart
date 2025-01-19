import 'package:equatable/equatable.dart';

abstract class ProductSubCardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchProductSubCardsEvent extends ProductSubCardEvent {}
