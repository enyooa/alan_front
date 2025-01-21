import 'package:equatable/equatable.dart';
import 'package:alan/ui/main/models/user.dart';

abstract class UserState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UsersLoaded extends UserState {
  final List<User> users;

  UsersLoaded({required this.users});

  @override
  List<Object?> get props => [users];
}

class UserRoleAssigned extends UserState {}

class UserRoleRemoved extends UserState {}

class UserError extends UserState {
  final String message;

  UserError({required this.message});

  @override
  List<Object?> get props => [message];
}
