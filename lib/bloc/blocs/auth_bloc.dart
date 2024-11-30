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

    // для склада и ценового предложения
    on<FetchStorageUsersEvent>(_onFetchStorageUsers);
    on<FetchClientUsersEvent>(_onFetchClientUsers);
    // для склада и ценового предложения

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

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final token = data['token'] as String?;
      final userId = data['id'] as int?;
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
      // Handle API errors with a proper message
      final errorMessage = jsonDecode(response.body)['message'] ?? "Registration failed.";
      emit(AuthError(message: errorMessage));
    }
  } catch (error) {
    // Catch and emit any unexpected errors
    emit(AuthError(message: "Error: ${error.toString()}"));
  }
}

  Future<void> _onLogoutEvent(LogoutEvent event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    emit(AuthUnauthenticated());
  }



  Future<void> _onFetchStorageUsers(FetchStorageUsersEvent event, Emitter<AuthState> emit) async {
  emit(AuthLoading());
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      emit(AuthError(message: "Authentication token not found."));
      return;
    }

    final response = await http.get(
      Uri.parse(baseUrl + 'getStorageUsers'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> users = jsonDecode(response.body);
      emit(StorageUsersLoaded(storageUsers: users.map((user) {
        return {
          'id': user['id'],
          'name': '${user['first_name']} ${user['last_name']}',
          'address': '${user['address']}',
        };
      }).toList()));
          // print(users);

    } else {
      emit(AuthError(message: "Failed to fetch storage users."));
    }
  } catch (e) {
    emit(AuthError(message: e.toString()));
  }
}

Future<void> _onFetchClientUsers(FetchClientUsersEvent event, Emitter<AuthState> emit) async {
  emit(AuthLoading());
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      emit(AuthError(message: "Authentication token not found."));
      return;
    }

    final response = await http.get(
      Uri.parse(baseUrl + 'client-users'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> users = jsonDecode(response.body);
      emit(ClientUsersLoaded(clientUsers: users.map((user) {
        return {
          'id': user['id'],
          'name': '${user['first_name']} ${user['last_name']}',
        };
      }).toList()));
    } else {
      emit(AuthError(message: "Failed to fetch client users."));
    }
  } catch (e) {
    emit(AuthError(message: e.toString()));
  }
}
}
