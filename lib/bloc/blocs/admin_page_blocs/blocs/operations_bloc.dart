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
        Uri.parse(baseUrl+'operations-history'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        emit(OperationsLoaded(operations: data.cast<Map<String, dynamic>>()));
      } else {
        emit(OperationsError(
            message: 'Не удалось загрузить справки'));
      }
    } catch (error) {
      emit(OperationsError(message: error.toString()));
    }
  }
}
