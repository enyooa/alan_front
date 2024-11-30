import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final List<String> roles;

  AuthAuthenticated({required this.roles});

  @override
  List<Object> get props => [roles];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

// для склад 
class StorageUsersLoaded extends AuthState {
  final List<Map<String, dynamic>> storageUsers;

  StorageUsersLoaded({required this.storageUsers});

  @override
  List<Object> get props => [storageUsers];
}

// для ценовое предложения
class ClientUsersLoaded extends AuthState {
  final List<Map<String, dynamic>> clientUsers;

  ClientUsersLoaded({required this.clientUsers});

  @override
  List<Object> get props => [clientUsers];
}
