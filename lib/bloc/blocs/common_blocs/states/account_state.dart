import 'package:equatable/equatable.dart';

abstract class AccountState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
  final Map<String, dynamic> userData;

  AccountLoaded(this.userData);

  AccountLoaded copyWith({
    String? photoUrl,
    bool? notifications,
  }) {
    return AccountLoaded({
      ...userData,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (notifications != null) 'notifications': notifications,
    });
  }

  @override
  List<Object?> get props => [userData];
}

class AccountError extends AccountState {
  final String message;

  AccountError(this.message);

  @override
  List<Object?> get props => [message];
}

class AccountLoggedOut extends AccountState {}
