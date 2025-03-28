import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AppStartedEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String whatsapp_number;
  final String password;

  LoginEvent({required this.whatsapp_number, required this.password});

  @override
  List<Object> get props => [whatsapp_number, password];
}

// For storage & client/courier
class FetchStorageUsersEvent extends AuthEvent {}
class FetchClientUsersEvent extends AuthEvent {}
class FetchCourierUsersEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}
