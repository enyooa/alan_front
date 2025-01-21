import 'package:alan/ui/main/models/user.dart';
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
  final String role; // Use String instead of Role

  AssignRoleEvent({required this.userId, required this.role});

  @override
  List<Object?> get props => [userId, role];
}

class RemoveRoleEvent extends UserEvent {
  final int userId;
  final String role; // Use String instead of Role

  RemoveRoleEvent({required this.userId, required this.role});

  @override
  List<Object?> get props => [userId, role];
}
