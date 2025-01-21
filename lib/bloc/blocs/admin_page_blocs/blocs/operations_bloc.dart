import 'dart:convert';
import 'package:alan/bloc/blocs/admin_page_blocs/events/operations_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/operations_state.dart';
import 'package:alan/bloc/models/operation.dart';
import 'package:alan/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class OperationsBloc extends Bloc<OperationsEvent, OperationsState> {
  OperationsBloc() : super(OperationsInitial()) {
    on<FetchOperationsHistoryEvent>(_fetchOperationsHistory);
    on<EditOperationEvent>(_editOperation);
    on<DeleteOperationEvent>(_deleteOperation);
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
      final List<dynamic> data = jsonDecode(response.body);
      final List<Operation> operations = data.map((item) {
        return Operation.fromJson(item as Map<String, dynamic>);
      }).toList();

      emit(OperationsLoaded(operations: operations));
    } else {
      emit(OperationsError(message: 'Failed to fetch operations.'));
    }
  } catch (error) {
    emit(OperationsError(message: error.toString()));
  }
}


  Future<void> _editOperation(
      EditOperationEvent event, Emitter<OperationsState> emit) async {
    emit(OperationsLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        emit(OperationsError(message: 'Authentication token not found.'));
        return;
      }

      final response = await http.put(
        Uri.parse('${baseUrl}operations/${event.id}/${event.type}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(event.updatedFields),
      );

      if (response.statusCode == 200) {
        emit(OperationsSuccess(message: 'Операция успешно выполнена!'));
        add(FetchOperationsHistoryEvent()); // Refresh operations
      } else {
        final errorData = jsonDecode(response.body);
        emit(OperationsError(message: errorData['message'] ?? 'Failed to update operation.'));
      }
    } catch (error) {
      emit(OperationsError(message: error.toString()));
    }
  }

 Future<void> _deleteOperation(
    DeleteOperationEvent event, Emitter<OperationsState> emit) async {
  emit(OperationsLoading());
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      emit(OperationsError(message: 'Authentication token not found.'));
      return;
    }

    final response = await http.delete(
      Uri.parse('${baseUrl}operations/${event.id}/${event.type}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      emit(OperationsSuccess(message: 'Операция успешно выполнена!.'));
      // Fetch the updated list
      add(FetchOperationsHistoryEvent());
    } else {
      final errorData = jsonDecode(response.body);
      emit(OperationsError(
          message: errorData['message'] ?? 'Failed to delete operation.'));
    }
  } catch (error) {
    emit(OperationsError(message: error.toString()));
  }
}

}
