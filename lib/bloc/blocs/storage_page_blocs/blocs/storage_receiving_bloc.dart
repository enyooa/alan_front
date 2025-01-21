import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/events/storage_receiving_event.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/storage_receiving_state.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:alan/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageReceivingBloc extends Bloc<StorageReceivingEvent, StorageReceivingState> {
  StorageReceivingBloc() : super(StorageReceivingInitial()) {
    on<CreateBulkStorageReceivingEvent>(_createBulkStorageReceiving);
  }

  Future<void> _createBulkStorageReceiving(
    CreateBulkStorageReceivingEvent event,
    Emitter<StorageReceivingState> emit,
  ) async {
    emit(StorageReceivingLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(StorageReceivingError(message: "Authentication token not found."));
        return;
      }

      final response = await http.post(
        Uri.parse(baseUrl + 'storageReceivingBulkStore'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'receivings': event.receivings}),
      );

      if (response.statusCode == 201) {
        emit(StorageReceivingCreated(message: "ТМЗ успешно добавлены в склад!"));
      } else {
        final errorData = jsonDecode(response.body);
        emit(StorageReceivingError(
            message: errorData['message'] ?? "Ошибка сохранения поступления."));
      }
    } catch (error) {
      emit(StorageReceivingError(message: error.toString()));
    }
  }
}
