import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchUsersEvent extends UserEvent {
  @override
  List<Object?> get props => [];
}

class AssignRoleEvent extends UserEvent {
  final int userId;
  final String role;

  AssignRoleEvent({required this.userId, required this.role});

  @override
  List<Object?> get props => [userId, role];
}

// Event to remove a role from a user (optional)
class RemoveRoleEvent extends UserEvent {
  final int userId;
  final String role;

  RemoveRoleEvent({required this.userId, required this.role});

  @override
  List<Object?> get props => [userId, role];
}
