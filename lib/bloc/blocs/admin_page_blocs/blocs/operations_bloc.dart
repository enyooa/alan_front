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
    EditOperationEvent event, 
    Emitter<OperationsState> emit
  ) async {
    emit(OperationsLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        emit(OperationsError(message: 'Authentication token not found.'));
        return;
      }

      // Suppose we do a patch with JSON (no file). 
      // If you need a file, do a multipart instead.
      final url = Uri.parse('${baseUrl}references/${event.type}/${event.id}');
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(event.updatedFields),
      );

      if (response.statusCode == 200) {
        // Re-fetch the list so the UI sees changes
        add(FetchOperationsHistoryEvent());
        emit(OperationsSuccess(message: 'Успешно обновлено!'));
      } else {
        final errorJson = jsonDecode(response.body);
        emit(OperationsError(message: errorJson['error'] ?? 'Edit failed.'));
      }
    } catch (err) {
      emit(OperationsError(message: err.toString()));
    }
  }

 Future<void> _deleteOperation(
  DeleteOperationEvent event,
  Emitter<OperationsState> emit
) async {
  emit(OperationsLoading());
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      emit(OperationsError(message: 'Authentication token not found.'));
      return;
    }

    // FIX: use "references/{type}/{id}"
    final url = Uri.parse('${baseUrl}references/${event.type}/${event.id}');
    
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      // On success
      emit(OperationsSuccess(message: 'Операция успешно выполнена!.'));
      // Re-fetch to update the table
      add(FetchOperationsHistoryEvent());
    } else {
      final errorData = jsonDecode(response.body);
      emit(OperationsError(
        message: errorData['message'] ?? 'Failed to delete operation.'
      ));
    }
  } catch (error) {
    emit(OperationsError(message: error.toString()));
  }
}

}
