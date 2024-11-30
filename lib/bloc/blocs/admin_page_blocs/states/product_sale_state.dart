import 'package:equatable/equatable.dart';

abstract class SalesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SalesInitial extends SalesState {}

class SalesLoading extends SalesState {}

class SalesLoaded extends SalesState {
  final List<Map<String, dynamic>> salesList;

  SalesLoaded({required this.salesList});

  @override
  List<Object?> get props => [salesList];
}

class SalesCreated extends SalesState {
  final String message;

  SalesCreated({required this.message});

  @override
  List<Object?> get props => [message];
}

class SalesError extends SalesState {
  final String message;

  SalesError({required this.message});

  @override
  List<Object?> get props => [message];
}
