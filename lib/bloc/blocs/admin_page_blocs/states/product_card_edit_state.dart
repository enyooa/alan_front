import 'package:equatable/equatable.dart';

abstract class ProductCardEditState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductCardEditInitial extends ProductCardEditState {}

class ProductCardEditLoading extends ProductCardEditState {}

class ProductCardEditSuccess extends ProductCardEditState {
  final String message;
  final Map<String, dynamic>? updatedData; 
  // If you want to store the updated record

  ProductCardEditSuccess({required this.message, this.updatedData});

  @override
  List<Object?> get props => [message, updatedData ?? {}];
}

class ProductCardEditError extends ProductCardEditState {
  final String error;
  ProductCardEditError(this.error);

  @override
  List<Object?> get props => [error];
}
