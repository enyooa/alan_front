import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

/// We store `hasWhatsapp` to indicate if user’s phone is on WhatsApp
class AuthAuthenticated extends AuthState {
  final List<String> roles;
  final bool hasWhatsapp;

  AuthAuthenticated({required this.roles, required this.hasWhatsapp});

  @override
  List<Object> get props => [roles, hasWhatsapp];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

// Additional states for storage, client, courier
class StorageUsersLoaded extends AuthState {
  final List<Map<String, dynamic>> storageUsers;
  StorageUsersLoaded({required this.storageUsers});

  @override
  List<Object> get props => [storageUsers];
}

class ClientUsersLoaded extends AuthState {
  final List<Map<String, dynamic>> clientUsers;
  ClientUsersLoaded({required this.clientUsers});

  @override
  List<Object> get props => [clientUsers];
}

class CourierUsersLoaded extends AuthState {
  final List<Map<String, dynamic>> courierUsers;
  CourierUsersLoaded({required this.courierUsers});

  @override
  List<Object> get props => [courierUsers];
}
class AuthNotVerified extends AuthState {
  final List<String> roles;
  final bool hasWhatsapp;
  final String rawPhone; // the phone number from registration
  
  AuthNotVerified({
    required this.roles,
    required this.hasWhatsapp,
    required this.rawPhone,
  });
  
  @override
  List<Object> get props => [roles, hasWhatsapp, rawPhone];
}
