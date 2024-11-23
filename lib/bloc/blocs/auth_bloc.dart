import 'dart:convert';
import 'package:cash_control/bloc/events/auth_event.dart';
import 'package:cash_control/bloc/events/register_event.dart';
import 'package:cash_control/bloc/states/auth_state.dart';
import 'package:cash_control/constant.dart';
import 'package:cash_control/ui/main/models/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>(_onLoginEvent);
    on<RegisterEvent>(_onRegisterEvent);
    on<LogoutEvent>(_onLogoutEvent);
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
        final userId = data['id'] as int?; // If id is directly in the response
        final roles = List<String>.from(data['roles'] ?? []);

        if (token != null && userId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setInt('user_id', userId);
          await prefs.setStringList('roles', roles);

          emit(AuthAuthenticated(roles: roles));
        } else {
          emit(AuthError(message: "Authentication failed: Missing token or user ID."));
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
        final userId = data['id'] as int?; // If id is directly in the response
        final roles = List<String>.from(data['roles'] ?? []);

        if (token != null && userId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setInt('user_id', userId);
          await prefs.setStringList('roles', roles);

          emit(AuthAuthenticated(roles: roles));
        } else {
          emit(AuthError(message: "Registration failed: Missing token or user ID."));
        }
      } else {
        emit(AuthError(message: data['message'] ?? "Registration failed."));
      }
    } catch (error) {
      emit(AuthError(message: error.toString()));
    }
  }

  Future<void> _onLogoutEvent(LogoutEvent event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    emit(AuthUnauthenticated());
  }
}
