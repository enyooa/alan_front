// product_transfer_bloc.dart
import 'dart:convert';

import 'package:alan/bloc/blocs/admin_page_blocs/events/transfer_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/transfer_state.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:alan/constant.dart';


class ProductTransferBloc extends Bloc<ProductTransferEvent, ProductTransferState> {
  ProductTransferBloc() : super(ProductTransferInitial()) {
    on<CreateBulkProductTransferEvent>(_createBulkProductTransfer);
  }

  Future<void> _createBulkProductTransfer(
    CreateBulkProductTransferEvent event,
    Emitter<ProductTransferState> emit,
  ) async {
    emit(ProductTransferLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        emit(ProductTransferError(message: "Authentication token not found."));
        return;
      }

      final response = await http.post(
        Uri.parse(baseUrl + 'transfer/store'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(event.payload),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        emit(ProductTransferCreated(message: data['message'] ?? "Transfer completed."));
      } else {
        final errorData = jsonDecode(response.body);
        emit(ProductTransferError(
          message: errorData['error'] ?? "Error saving transfer.",
        ));
      }
    } catch (err) {
      emit(ProductTransferError(message: err.toString()));
    }
  }
}
