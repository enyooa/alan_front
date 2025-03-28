// product_writeoff_bloc.dart

import 'dart:convert';
import 'package:alan/bloc/blocs/admin_page_blocs/events/write_off_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/write_off_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:alan/constant.dart'; // your baseUrl, etc.

class ProductWriteOffBloc extends Bloc<ProductWriteOffEvent, ProductWriteOffState> {
  ProductWriteOffBloc() : super(ProductWriteOffInitial()) {
    on<CreateBulkProductWriteOffEvent>(_createBulkProductWriteOff);
  }

  Future<void> _createBulkProductWriteOff(
    CreateBulkProductWriteOffEvent event,
    Emitter<ProductWriteOffState> emit,
  ) async {
    emit(ProductWriteOffLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        emit(ProductWriteOffError(message: "Authentication token not found."));
        return;
      }

      final response = await http.post(
        Uri.parse(baseUrl + 'storeWriteOff'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'write_offs': event.writeOffs}),
      );

      if (response.statusCode == 201) {
        emit(ProductWriteOffCreated(message: "Списание успешно выполнено!"));
      } else {
        final errorData = jsonDecode(response.body);
        emit(ProductWriteOffError(
          message: errorData['error'] ?? "Error saving write-off.",
        ));
      }
    } catch (error) {
      emit(ProductWriteOffError(message: error.toString()));
    }
  }
}
