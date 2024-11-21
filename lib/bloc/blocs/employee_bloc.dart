import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../constant.dart';
import 'package:cash_control/bloc/events/employee_event.dart';
import 'package:cash_control/bloc/states/employee_state.dart';
import 'package:cash_control/ui/main/models/user.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<FetchUsersEvent>(_onFetchUsers);
    on<AssignRoleEvent>(_onAssignRole);
    on<RemoveRoleEvent>(_onRemoveRole);
  }

  Future<void> _onFetchUsers(FetchUsersEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final response = await http.get(Uri.parse(baseUrl + 'users'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<User> users = (data as List).map((json) => User.fromJson(json)).toList();
        emit(UsersLoaded(users: users));
      } else {
        emit(UserError(message: "Failed to fetch users"));
      }
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }
Future<void> _onAssignRole(AssignRoleEvent event, Emitter<UserState> emit) async {
  emit(UserLoading());
  try {
    final response = await http.put(
      Uri.parse(baseUrl + 'users/${event.userId}/assign-role'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'role': event.role}),
    );

    if (response.statusCode == 200) {
      emit(UserRoleAssigned());
    } else {
      emit(UserError(message: "Failed to assign role"));
    }
  } catch (e) {
    emit(UserError(message: e.toString()));
  }
}

Future<void> _onRemoveRole(RemoveRoleEvent event, Emitter<UserState> emit) async {
  emit(UserLoading());
  try {
    final response = await http.delete(
      Uri.parse(baseUrl + 'users/${event.userId}/remove-role'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'role': event.role}),
    );

    if (response.statusCode == 200) {
      emit(UserRoleRemoved());
    } else {
      emit(UserError(message: "Failed to remove role"));
    }
  } catch (e) {
    emit(UserError(message: e.toString()));
  }
}
}
