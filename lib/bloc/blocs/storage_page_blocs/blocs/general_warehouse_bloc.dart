import 'package:bloc/bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/events/general_warehouse_event.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/general_warehouse_state.dart';
import 'package:alan/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GeneralWarehouseBloc extends Bloc<GeneralWarehouseEvent, GeneralWarehouseState> {
  GeneralWarehouseBloc() : super(GeneralWarehouseInitial()) {
    on<FetchGeneralWarehouseEvent>(_fetchGeneralWarehouse);
    on<WriteOffGeneralWarehouseEvent>(_writeOffGeneralWarehouse);
  }

  Future<void> _fetchGeneralWarehouse(
  FetchGeneralWarehouseEvent event,
  Emitter<GeneralWarehouseState> emit,
) async {
  emit(GeneralWarehouseLoading());

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      emit(GeneralWarehouseError(error: 'Authorization token not found.'));
      return;
    }

    final response = await http.get(
      Uri.parse(baseUrl + 'general-warehouses'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      emit(GeneralWarehouseLoaded(
        warehouseData: data.map((e) => Map<String, dynamic>.from(e)).toList(),
      ));
    } else {
      emit(GeneralWarehouseError(error: 'Failed to fetch warehouse data.'));
    }
  } catch (e) {
    emit(GeneralWarehouseError(error: 'Error: $e'));
  }
}

  Future<void> _writeOffGeneralWarehouse(
    WriteOffGeneralWarehouseEvent event,
    Emitter<GeneralWarehouseState> emit,
  ) async {
    emit(GeneralWarehouseLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(GeneralWarehouseError(error: 'Authorization token not found.'));
        return;
      }

      final response = await http.post(
        Uri.parse(baseUrl+'general-warehouses/write-off'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'write_off': event.writeOffs}),
      );

      if (response.statusCode == 200) {
        emit(GeneralWarehouseWriteOffSuccess(message: 'Write-off successful!'));
      } else {
        final error = jsonDecode(response.body);
        emit(GeneralWarehouseError(error: error['message'] ?? 'Write-off failed.'));
      }
    } catch (e) {
      emit(GeneralWarehouseError(error: 'Error: $e'));
    }
  }
}
