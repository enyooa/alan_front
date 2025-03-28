import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/events/storage_receiving_event.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/storage_receiving_state.dart';
import 'package:http/http.dart' as http;
import 'package:alan/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageReceivingBloc extends Bloc<StorageReceivingEvent, StorageReceivingState> {
  StorageReceivingBloc() : super(StorageReceivingInitial()) {
    on<CreateBulkStorageReceivingEvent>(_createBulkStorageReceiving);
    on<FetchAllReceiptsEvent>(_fetchAllReceipts);
    on<UpdateIncomeEvent>(_updateIncome);
    on<DeleteIncomeEvent>(_deleteIncome);

    // ОДИН метод _fetchSingleReceipt:
    on<FetchSingleReceiptEvent>(_fetchSingleReceipt);
  }

  /// 1) Создание
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
          message: errorData['message'] ?? "Ошибка сохранения поступления.",
        ));
      }
    } catch (error) {
      emit(StorageReceivingError(message: error.toString()));
    }
  }

  /// 2) Получение списка
  Future<void> _fetchAllReceipts(
    FetchAllReceiptsEvent event,
    Emitter<StorageReceivingState> emit,
  ) async {
    emit(StorageReceivingLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse(baseUrl + 'getAllReceipts'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(StorageReceivingListLoaded(receipts: data));
      } else {
        final errorData = jsonDecode(response.body);
        emit(StorageReceivingError(
          message: errorData['message'] ?? "Ошибка при загрузке receipts.",
        ));
      }
    } catch (e) {
      emit(StorageReceivingError(message: e.toString()));
    }
  }

  /// 3) Обновление
  Future<void> _updateIncome(
    UpdateIncomeEvent event,
    Emitter<StorageReceivingState> emit,
  ) async {
    emit(StorageReceivingLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        emit(StorageReceivingError(message: "No token found."));
        return;
      }

      final url = Uri.parse(baseUrl + 'updateReceipt/${event.docId}');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(event.updatedData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(StorageReceivingUpdated(message: data['message'] ?? 'Updated!'));
      } else {
        final err = jsonDecode(response.body);
        emit(StorageReceivingError(
          message: err['error'] ?? 'Ошибка при обновлении.',
        ));
      }
    } catch (e) {
      emit(StorageReceivingError(message: e.toString()));
    }
  }

  /// 4) Удаление
  /// 4) Удаление (DELETE)
Future<void> _deleteIncome(
  DeleteIncomeEvent event,
  Emitter<StorageReceivingState> emit,
) async {
  emit(StorageReceivingLoading());
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      emit(StorageReceivingError(message: "No token found."));
      return;
    }

    final url = Uri.parse(baseUrl + 'deleteReceipt/${event.docId}');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Emit a state that indicates deletion succeeded.
      emit(StorageReceivingDeleted(message: data['message'] ?? 'Deleted!'));
    } else {
      final err = jsonDecode(response.body);
      emit(StorageReceivingError(
        message: err['error'] ?? 'Ошибка при удалении.',
      ));
    }
  } catch (e) {
    emit(StorageReceivingError(message: e.toString()));
  }
}

  /// 5) Загрузка одного документа + справочников
  /// 5) Загрузка одного документа + справочников
Future<void> _fetchSingleReceipt(
  FetchSingleReceiptEvent event,
  Emitter<StorageReceivingState> emit,
) async {
  emit(StorageReceivingLoading());
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    if (token.isEmpty) {
      emit(StorageReceivingError(message: "Authentication token not found."));
      return;
    }

    // 1) Документ
    final docResponse = await http.get(
      Uri.parse(baseUrl + 'documents/${event.docId}'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (docResponse.statusCode != 200) {
      final err = jsonDecode(docResponse.body);
      throw Exception(err['message'] ?? 'Ошибка загрузки документа.');
    }
    final docData = jsonDecode(docResponse.body);

    // Print the document data to verify status 200
    print("Single receipt fetched successfully: $docData");

    // 2) Справочники
    final refResponse = await http.get(
      Uri.parse(baseUrl + 'getWarehouseDetails'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (refResponse.statusCode != 200) {
      throw Exception('Ошибка загрузки справочников.');
    }
    final refData = jsonDecode(refResponse.body);

    // 3) объединяем в state
    emit(StorageReceivingSingleLoaded(
      document: docData,
      providers: refData['providers'] ?? [],
      warehouses: refData['warehouses'] ?? [],
      productSubCards: refData['product_sub_cards'] ?? [],
      unitMeasurements: refData['unit_measurements'] ?? [],
      expenses: refData['expenses'] ?? [],
    ));
  } catch (e) {
    emit(StorageReceivingError(message: e.toString()));
  }
}
}
