import 'package:equatable/equatable.dart';

abstract class AccountEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadUserData extends AccountEvent {}

class ToggleNotification extends AccountEvent {
  final bool isEnabled;

  ToggleNotification(this.isEnabled);

  @override
  List<Object?> get props => [isEnabled];
}

class Logout extends AccountEvent {}
