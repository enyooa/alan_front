import 'package:equatable/equatable.dart';
import 'auth_event.dart';

class RegisterEvent extends AuthEvent {
  final String firstName;
  final String lastName;
  final String surname;
  final String whatsappNumber;
  final String password;
  final String passwordConfirmation;

  RegisterEvent({
    required this.firstName,
    required this.lastName,
    required this.surname,
    required this.whatsappNumber,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object> get props => [
    firstName,
    lastName,
    surname,
    whatsappNumber,
    password,
    passwordConfirmation,
  ];
}
