
import 'package:alan/bloc/blocs/storage_page_blocs/events/storage_references_event.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/storage_references_state.dart';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alan/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StorageReferencesBloc extends Bloc<StorageReferencesEvent, StorageReferencesState> {
  StorageReferencesBloc() : super(StorageReferencesInitial()) {
    on<FetchAllInstancesEvent>(_handleFetchAllInstances);
    on<CreateStoreIncomeEvent>(_handleCreateStoreIncome);
  }

  // 1) Fetch references
  Future<void> _handleFetchAllInstances(
    FetchAllInstancesEvent event,
    Emitter<StorageReferencesState> emit,
  ) async {
    emit(StorageReferencesLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('${baseUrl}getAllInstances'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        final providers = responseData['providers'] as List<dynamic>? ?? [];
        final clients = responseData['clients'] as List<dynamic>? ?? [];
        final productSubCards = responseData['product_sub_cards'] as List<dynamic>? ?? [];
        final unitMeasurements = responseData['unit_measurements'] as List<dynamic>? ?? [];
        final expenses = responseData['expenses'] as List<dynamic>? ?? [];

        emit(StorageReferencesLoaded(
          providers: providers,
          clients: clients,
          productSubCards: productSubCards,
          unitMeasurements: unitMeasurements,
          expenses: expenses,
        ));
      } else {
        emit(StorageReferencesError('Failed to load references.'));
      }
    } catch (e) {
      emit(StorageReferencesError('Error: $e'));
    }
  }

  // 2) Store Income
  Future<void> _handleCreateStoreIncome(
    CreateStoreIncomeEvent event,
    Emitter<StorageReferencesState> emit,
  ) async {
    // We could optionally emit a loading state again
    emit(StorageReferencesLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        emit(StorageReferencesError("No auth token found"));
        return;
      }

      // event.payload = { provider_id, document_date, products, expenses, ... }
      final url = Uri.parse('${baseUrl}storeIncomeAsWarehouseManager');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(event.payload),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final msg = data['message'] ?? 'Документ (Приход) сохранён!';
        emit(StoreIncomeCreated(msg));
      } else {
        final data = jsonDecode(response.body);
        final errorMsg = data['error'] ?? data['message'] ?? 'Ошибка при сохранении.';
        emit(StorageReferencesError(errorMsg));
      }
    } catch (e) {
      emit(StorageReferencesError('Store Income Error: $e'));
    }
  }
}
