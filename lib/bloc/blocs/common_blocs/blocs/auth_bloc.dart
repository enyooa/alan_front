import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Local imports
import 'package:alan/constant.dart'; // e.g. baseUrl
import 'package:alan/bloc/blocs/common_blocs/events/auth_event.dart';
import 'package:alan/bloc/blocs/common_blocs/events/register_event.dart';
import 'package:alan/bloc/blocs/common_blocs/states/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AppStartedEvent>(_onAppStarted);
    on<LoginEvent>(_onLoginEvent);
    on<RegisterEvent>(_onRegisterEvent);
    on<LogoutEvent>(_onLogoutEvent);

    // For storage
    on<FetchStorageUsersEvent>(_onFetchStorageUsers);
    // For client
    on<FetchClientUsersEvent>(_onFetchClientUsers);
    // For courier
    on<FetchCourierUsersEvent>(_onFetchCourierUsers);
  }

  /// On App Start
  Future<void> _onAppStarted(AppStartedEvent event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final roles = prefs.getStringList('roles');
    if (token != null && token.isNotEmpty) {
      // We do not know hasWhatsapp from local, default false
      emit(AuthAuthenticated(roles: roles ?? [], hasWhatsapp: false));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  /// Login
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
        final token  = data['token'] as String?;
        final userId = data['id']    as int?;
        final roles  = List<String>.from(data['roles'] ?? []);

        if (token != null && userId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setInt('user_id', userId);
          await prefs.setStringList('roles', roles);

          // No "hasWhatsapp" from login
          emit(AuthAuthenticated(roles: roles, hasWhatsapp: false));
        } else {
          emit(AuthError(message: "Authentication failed: Missing token or user ID."));
        }
      } else {
        final msg = data['message'] ?? "Login failed.";
        emit(AuthError(message: msg.toString()));
      }
    } catch (error) {
      emit(AuthError(message: error.toString()));
    }
  }

  /// Register
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

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      final token       = data['token'] as String?;
      final userId      = data['id'] as int?;
      final isVerified  = data['is_verified'] as bool? ?? false;
      final hasWhatsapp = data['has_whatsapp'] as bool? ?? false;

      final userMap = data['user'] as Map<String, dynamic>?;
      final roles   = (userMap != null && userMap['roles'] != null)
          ? List<String>.from(userMap['roles'])
          : <String>[];
      final whatsappNumber = userMap != null && userMap['whatsapp_number'] != null
          ? userMap['whatsapp_number'] as String
          : '';

      if (token != null && userId != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setInt('user_id', userId);
        await prefs.setStringList('roles', roles);

        if (!isVerified) {
          emit(AuthNotVerified(roles: roles, hasWhatsapp: hasWhatsapp, rawPhone: whatsappNumber));
        } else {
          emit(AuthAuthenticated(roles: roles, hasWhatsapp: hasWhatsapp));
        }
      } else {
        emit(AuthError(message: "Registration failed: Missing token or user ID."));
      }
    } else {
      final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
      String errorMessage = "Registration failed.";
      final msgField = errorJson['message'];
      if (msgField is String) {
        errorMessage = msgField;
      } else if (msgField is Map) {
        final firstKey = msgField.keys.first;
        final possibleList = msgField[firstKey];
        if (possibleList is List && possibleList.isNotEmpty) {
          errorMessage = possibleList.first.toString();
        }
      }
      emit(AuthError(message: errorMessage));
    }
  } catch (error) {
    emit(AuthError(message: error.toString()));
  }
}

  /// Logout
  Future<void> _onLogoutEvent(LogoutEvent event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    emit(AuthUnauthenticated());
  }

  /// Fetch Storage Users
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
        final storageUsers = users.map((u) => {
          'id': u['id'],
          'name': '${u['first_name']} ${u['last_name']}',
          'address': '${u['address']}',
        }).toList();

        emit(StorageUsersLoaded(storageUsers: storageUsers));
      } else {
        emit(AuthError(message: "Failed to fetch storage users."));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Fetch Client Users
  Future<void> _onFetchClientUsers(FetchClientUsersEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(AuthError(message: "Токен авторизации отсутствует."));
        return;
      }

      final response = await http.get(
        Uri.parse(baseUrl + 'client-users'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> users = jsonDecode(response.body);

        final clientUsers = users.map((user) {
          return {
            'id': user['id'],
            'name': '${user['first_name']} ${user['last_name']}',
          };
        }).toList();

        emit(ClientUsersLoaded(clientUsers: clientUsers));
      } else {
        final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMsg = errorBody['message'] ?? "Не удалось загрузить клиентов.";
        emit(AuthError(message: errorMsg.toString()));
      }
    } catch (e) {
      emit(AuthError(message: "Ошибка: ${e.toString()}"));
    }
  }

  /// Fetch Courier Users
  Future<void> _onFetchCourierUsers(FetchCourierUsersEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(AuthError(message: "Authentication token not found."));
        return;
      }

      final response = await http.get(
        Uri.parse(baseUrl + 'getCourierUsers'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> users = jsonDecode(response.body);
        final courierUsers = users.map((user) {
          return {
            'id': user['id'],
            'name': '${user['first_name']} ${user['last_name']}',
            'whatsapp_number': user['whatsapp_number'],
          };
        }).toList();

        emit(CourierUsersLoaded(courierUsers: courierUsers));
      } else {
        emit(AuthError(message: "Failed to fetch courier users."));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
