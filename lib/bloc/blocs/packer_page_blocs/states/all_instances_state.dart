import 'package:equatable/equatable.dart';

abstract class AllInstancesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AllInstancesInitial extends AllInstancesState {}

class AllInstancesLoading extends AllInstancesState {}

/// data will hold { "users": [...], "unit_measurements": [...], "couriers": [...] }
class AllInstancesLoaded extends AllInstancesState {
  final Map<String, dynamic> data;

  AllInstancesLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class AllInstancesError extends AllInstancesState {
  final String message;

  AllInstancesError(this.message);

  @override
  List<Object?> get props => [message];
}
