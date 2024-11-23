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
