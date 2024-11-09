import 'dart:convert';
import 'package:cash_control/bloc/events/auth_event.dart';
import 'package:cash_control/bloc/events/register_event.dart';
import 'package:cash_control/bloc/states/auth_state.dart';
import 'package:cash_control/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>(_onLoginEvent);
    on<RegisterEvent>(_onRegisterEvent);
  }

  Future<void> _onLoginEvent(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await http.post(
        Uri.parse(baseUrl + 'login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'whatsapp_number': event.whatsapp_number,
          'password': event.password,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        final token = data['token'] as String?;
        final role = data['role'] as String?;

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('role', role ?? 'client');
          await prefs.setString('first_name', data['first_name'] ?? '');
          await prefs.setString('last_name', data['last_name'] ?? '');
          await prefs.setString('surname', data['surname'] ?? '');
          await prefs.setString('whatsapp_number', data['whatsapp_number'] ?? '');

          emit(AuthAuthenticated(role: role ?? 'client'));
        } else {
          emit(AuthError(message: "Authentication failed: Token not found."));
        }
      } else {
        emit(AuthError(message: data['message'] ?? "Login failed."));
      }
    } catch (error) {
      emit(AuthError(message: error.toString()));
    }
  }

  Future<void> _onRegisterEvent(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await http.post(
        Uri.parse(baseUrl + 'register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'first_name': event.firstName,
          'last_name': event.lastName,
          'surname': event.surname,
          'whatsapp_number': event.whatsappNumber,
          'password': event.password,
          'password_confirmation': event.passwordConfirmation,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 201) {
        final token = data['token'] as String?;
        final user = data['user'] as Map<String, dynamic>?;

        if (token != null && user != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('role', user['role'] ?? 'client');
          await prefs.setString('first_name', user['first_name'] ?? '');
          await prefs.setString('last_name', user['last_name'] ?? '');
          await prefs.setString('surname', user['surname'] ?? '');
          await prefs.setString('whatsapp_number', user['whatsapp_number'] ?? '');

          emit(AuthAuthenticated(role: user['role'] ?? 'client'));
        } else {
          emit(AuthError(message: "Registration failed: Token not found."));
        }
      } else {
        emit(AuthError(message: data['message'] ?? "Registration failed."));
      }
    } catch (error) {
      emit(AuthError(message: error.toString()));
    }
  }
}
