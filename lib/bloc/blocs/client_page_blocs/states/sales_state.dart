import 'package:equatable/equatable.dart';

abstract class SalesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SalesInitial extends SalesState {}

class SalesLoading extends SalesState {}

class SalesLoadedWithDetails extends SalesState {
  final List<Map<String, dynamic>> salesDetails;

  SalesLoadedWithDetails({required this.salesDetails});

  @override
  List<Object?> get props => [salesDetails];
}

class SalesError extends SalesState {
  final String message;

  SalesError({required this.message});

  @override
  List<Object?> get props => [message];
}
