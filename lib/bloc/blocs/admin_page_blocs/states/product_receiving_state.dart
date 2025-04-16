import 'package:equatable/equatable.dart';

abstract class ProductReceivingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductReceivingInitial extends ProductReceivingState {}

class ProductReceivingLoading extends ProductReceivingState {}

class ProductReceivingCreated extends ProductReceivingState {
  final String message;

  ProductReceivingCreated({required this.message});

  @override
  List<Object?> get props => [message];
}

class ProductReceivingLoaded extends ProductReceivingState {
  final List<Map<String, dynamic>> productReceivingList; // Use your model here if you have one

  ProductReceivingLoaded({required this.productReceivingList});

  @override
  List<Object?> get props => [productReceivingList];
}

class ProductReceivingError extends ProductReceivingState {
  final String message;

  ProductReceivingError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ProductReceivingSingleLoaded extends ProductReceivingState {
  final Map<String, dynamic> document;
  final List<dynamic> providers;
  final List<dynamic> warehouses;
  final List<dynamic> productSubCards;
  final List<dynamic> unitMeasurements;
  final List<dynamic> expenses;

  ProductReceivingSingleLoaded({
    required this.document,
    required this.providers,
    required this.warehouses,
    required this.productSubCards,
    required this.unitMeasurements,
    required this.expenses,
  });

  @override
  List<Object?> get props =>
      [document, providers, warehouses, productSubCards, unitMeasurements, expenses];
}

class ProductReceivingUpdated extends ProductReceivingState {
  final String message;
  ProductReceivingUpdated(this.message);

  @override
  List<Object?> get props => [message];
}

