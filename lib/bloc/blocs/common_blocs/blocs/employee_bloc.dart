  import 'dart:convert';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
  import '../../../../constant.dart';
  import 'package:alan/bloc/blocs/common_blocs/events/employee_event.dart';
  import 'package:alan/bloc/blocs/common_blocs/states/employee_state.dart';
  import 'package:alan/ui/main/models/user.dart';

  class UserBloc extends Bloc<UserEvent, UserState> {
      UserBloc() : super(UserInitial()) {
      on<FetchUsersEvent>(_onFetchUsers);
      on<AssignRoleEvent>(_onAssignRole);
      on<RemoveRoleEvent>(_onRemoveRole);
    }

   Future<void> _onFetchUsers(
    FetchUsersEvent event, Emitter<UserState> emit) async {
  emit(UserLoading());
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("Token is: $token"); // Debug

    if (token == null) {
      emit(UserError(message: "Token not found"));
      return;
    }

    final response = await http.get(
      Uri.parse(baseUrl + 'users'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('Fetch users status code: ${response.statusCode}');
    print('Fetch users body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<User> users = (data as List)
          .map((json) => User.fromJson(json))
          .toList();
      emit(UsersLoaded(users: users));
    } else {
      emit(UserError(
        message: "Failed to fetch users. Code: ${response.statusCode}",
      ));
    }
  } catch (e) {
    emit(UserError(message: e.toString()));
  }
}

  Future<void> _onAssignRole(AssignRoleEvent event, Emitter<UserState> emit) async {
  emit(UserLoading());
  try {
    print('Assigning role: ${event.role} to user ID: ${event.userId}'); // Debug

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.put(
      Uri.parse(baseUrl + 'users/${event.userId}/assign-roles'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Include the Bearer token
      },
      body: jsonEncode({'role': event.role}),
    );

    print('Response status: ${response.statusCode}'); // Debug
    print('Response body: ${response.body}'); // Debug

    if (response.statusCode == 200) {
      emit(UserRoleAssigned());
    } else {
      emit(UserError(message: "Failed to assign role"));
    }
  } catch (e) {
    print('Error: $e'); // Debug
    emit(UserError(message: e.toString()));
  }
}



  Future<void> _onRemoveRole(RemoveRoleEvent event, Emitter<UserState> emit) async {
  emit(UserLoading());
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      emit(UserError(message: "Authentication token is missing."));
      return;
    }

    final request = http.Request(
      'DELETE',
      Uri.parse(baseUrl + 'users/${event.userId}/remove-role'),
    )
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      })
      ..body = jsonEncode({'role': event.role});

    final response = await http.Client().send(request);
    final responseBody = await response.stream.bytesToString();

    print('Response status: ${response.statusCode}');
    print('Response body: $responseBody');

    if (response.statusCode == 200) {
      emit(UserRoleRemoved());
    } else {
      emit(UserError(message: "Failed to remove role. ${responseBody}"));
    }
  } catch (e) {
    print('Error: $e');
    emit(UserError(message: e.toString()));
  }
}

  }
