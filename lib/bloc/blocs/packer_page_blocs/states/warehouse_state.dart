import 'package:equatable/equatable.dart';

abstract class PackagingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PackagingInitial extends PackagingState {}

class PackagingLoading extends PackagingState {}

class PackagingLoaded extends PackagingState {
  final List<Map<String, dynamic>> tableData;

  PackagingLoaded({required this.tableData});

  @override
  List<Object?> get props => [tableData];
}

class PackagingError extends PackagingState {
  final String error;

  PackagingError({required this.error});

  @override
  List<Object?> get props => [error];
}
