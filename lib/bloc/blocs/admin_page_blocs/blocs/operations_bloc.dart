import 'dart:convert';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/operations_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/operations_state.dart';
import 'package:cash_control/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OperationsBloc extends Bloc<OperationsEvent, OperationsState> {
  OperationsBloc() : super(OperationsInitial()) {
    on<FetchOperationsHistoryEvent>(_fetchOperationsHistory);

    on<UpdateOperationEvent>((event, emit) async {
  emit(OperationsLoading());
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.put(
      Uri.parse('$baseUrl/operations/${event.id}/edit'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({'operation': event.operation, 'type': event.type}),
    );

    if (response.statusCode == 200) {
      add(FetchOperationsHistoryEvent());
    } else {
      emit(OperationsError(message: 'Failed to update operation.'));
    }
  } catch (e) {
    emit(OperationsError(message: e.toString()));
  }
});

on<DeleteOperationEvent>((event, emit) async {
  emit(OperationsLoading());
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.delete(
      Uri.parse('$baseUrl/operations/${event.id}/delete'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      add(FetchOperationsHistoryEvent());
    } else {
      emit(OperationsError(message: 'Failed to delete operation.'));
    }
  } catch (e) {
    emit(OperationsError(message: e.toString()));
  }
});

  }

  Future<void> _fetchOperationsHistory(
      FetchOperationsHistoryEvent event, Emitter<OperationsState> emit) async {
    emit(OperationsLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(OperationsError(message: 'Authentication token not found.'));
        return;
      }

      final response = await http.get(
        Uri.parse('${baseUrl}operations-history'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        emit(OperationsLoaded(operations: data.cast<Map<String, dynamic>>()));
      } else {
        emit(OperationsError(message: 'Failed to load operations.'));
      }
    } catch (error) {
      emit(OperationsError(message: error.toString()));
    }
  }


  
}
