import 'package:equatable/equatable.dart';

abstract class AccountState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
  final String fullName;
  final String whatsappNumber;
  final bool isNotificationEnabled;

  AccountLoaded({
    required this.fullName,
    required this.whatsappNumber,
    required this.isNotificationEnabled,
  });

  AccountLoaded copyWith({
    String? fullName,
    String? whatsappNumber,
    bool? isNotificationEnabled,
  }) {
    return AccountLoaded(
      fullName: fullName ?? this.fullName,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      isNotificationEnabled: isNotificationEnabled ?? this.isNotificationEnabled,
    );
  }

  @override
  List<Object?> get props => [fullName, whatsappNumber, isNotificationEnabled];
}

class AccountError extends AccountState {
  final String message;

  AccountError(this.message);

  @override
  List<Object?> get props => [message];
}

class AccountLoggedOut extends AccountState {}
