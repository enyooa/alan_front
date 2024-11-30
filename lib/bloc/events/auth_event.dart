import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginEvent extends AuthEvent {
  final String whatsapp_number;
  final String password;

  LoginEvent({required this.whatsapp_number, required this.password});

  @override
  List<Object> get props => [whatsapp_number, password];
}
// для склада и ценового предложения
class FetchStorageUsersEvent extends AuthEvent {}
class FetchClientUsersEvent extends AuthEvent {}
// для склада и ценового предложения

class LogoutEvent extends AuthEvent {}
