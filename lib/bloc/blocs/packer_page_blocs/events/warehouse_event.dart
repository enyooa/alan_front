import 'package:equatable/equatable.dart';

abstract class WarehouseMovementEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchWarehouseMovementEvent extends WarehouseMovementEvent {
  final String dateFrom;
  final String dateTo;

  FetchWarehouseMovementEvent({required this.dateFrom, required this.dateTo});

  @override
  List<Object?> get props => [dateFrom, dateTo];
}
