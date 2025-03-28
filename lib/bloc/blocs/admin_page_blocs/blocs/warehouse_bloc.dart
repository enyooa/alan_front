import 'dart:convert';
import 'package:alan/bloc/blocs/admin_page_blocs/events/warehouse_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/warehouse_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';



// If you have a baseUrl in constant.dart, import it:
import 'package:alan/constant.dart';

class WarehouseBloc extends Bloc<WarehouseEvent, WarehouseState> {
  WarehouseBloc() : super(WarehouseInitial()) {
    on<FetchWarehousesEvent>(_onFetchWarehouses);
  }

  Future<void> _onFetchWarehouses(
    FetchWarehousesEvent event,
    Emitter<WarehouseState> emit,
  ) async {
    emit(WarehouseLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse(baseUrl + 'getWarehouses'), // or your actual route
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // data could be a list of warehouses: e.g. [{"id":1,"name":"Main"},{"id":2,"name":"Second"}]
        emit(WarehouseLoaded(warehouses: data));
      } else {
        emit(WarehouseError(message: 'Failed to fetch warehouses'));
      }
    } catch (err) {
      emit(WarehouseError(message: err.toString()));
    }
  }
}
