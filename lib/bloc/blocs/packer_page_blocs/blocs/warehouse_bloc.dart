import 'dart:convert';
import 'package:alan/bloc/blocs/packer_page_blocs/events/warehouse_event.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/states/warehouse_state.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:alan/constant.dart';

class WarehouseMovementBloc
    extends Bloc<WarehouseMovementEvent, WarehouseMovementState> {
  WarehouseMovementBloc() : super(WarehouseMovementInitial()) {
    on<FetchWarehouseMovementEvent>(_onFetchWarehouseMovement);
  }

  Future<void> _onFetchWarehouseMovement(
    FetchWarehouseMovementEvent event,
    Emitter<WarehouseMovementState> emit,
  ) async {
    emit(WarehouseMovementLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(WarehouseMovementError(
            error: "Токен не найден (не авторизованы)."));
        return;
      }

      // We'll call getPackerReportPage?date_from=...&date_to=...
      final url = Uri.parse(baseUrl+'getPackerReportPage'
          '?date_from=${event.dateFrom}&date_to=${event.dateTo}');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        final List<Map<String, dynamic>> tableData =
            data.map((item) => Map<String, dynamic>.from(item)).toList();

        emit(WarehouseMovementLoaded(reportData: tableData));
      } else {
        emit(WarehouseMovementError(
            error: "Ошибка сервера: ${response.body}"));
      }
    } catch (e) {
      emit(WarehouseMovementError(error: "Ошибка загрузки: $e"));
    }
  }
}
