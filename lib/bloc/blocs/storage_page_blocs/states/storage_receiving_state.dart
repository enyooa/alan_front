
import 'package:equatable/equatable.dart';

abstract class StorageReceivingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StorageReceivingInitial extends StorageReceivingState {}

class StorageReceivingLoading extends StorageReceivingState {}

class StorageReceivingCreated extends StorageReceivingState {
  final String message;

  StorageReceivingCreated({required this.message});

  @override
  List<Object?> get props => [message];
}

class StorageReceivingError extends StorageReceivingState {
  final String message;

  StorageReceivingError({required this.message});

  @override
  List<Object?> get props => [message];
}
