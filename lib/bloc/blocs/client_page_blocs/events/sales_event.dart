import 'package:equatable/equatable.dart';

abstract class SalesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchSalesWithDetailsEvent extends SalesEvent {}

class ResetSalesEvent extends SalesEvent {}
