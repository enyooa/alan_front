import 'dart:convert';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/inventory_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/inventory_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:cash_control/constant.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  InventoryBloc() : super(InventoryInitial()) {
    on<FetchInventoryEvent>(_onFetchInventory);
    on<SubmitInventoryEvent>(_onSubmitInventory);
  }

  Future<void> _onFetchInventory(
      FetchInventoryEvent event, Emitter<InventoryState> emit) async {
    emit(InventoryLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(InventoryError(message: "Authentication token not found."));
        return;
      }

      final response = await http.get(
        Uri.parse(baseUrl + 'getInventory'), // Replace with your endpoint
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        emit(InventoryLoaded(
          inventoryList: data.map((item) => item as Map<String, dynamic>).toList(),
        ));
      } else {
        emit(InventoryError(message: "Failed to fetch inventory data."));
      }
    } catch (e) {
      emit(InventoryError(message: e.toString()));
    }
  }

  Future<void> _onSubmitInventory(
      SubmitInventoryEvent event, Emitter<InventoryState> emit) async {
    emit(InventoryLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(InventoryError(message: "Authentication token not found."));
        return;
      }

      final response = await http.post(
        Uri.parse(baseUrl + 'bulkStoreInventory'), // Replace with your endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'storager_id': event.storageUserId,
          'inventory': event.inventoryRows,
        }),
      );

      if (response.statusCode == 201) {
        emit(InventorySubmitted(message: "Инвентаризация успешно сохранена."));
      } else {
        final errorData = jsonDecode(response.body);
        emit(InventoryError(
            message: errorData['message'] ?? "Ошибка при сохранении инвентаризации."));
      }
    } catch (error) {
      emit(InventoryError(message: "Ошибка: $error"));
    }
  }
}
