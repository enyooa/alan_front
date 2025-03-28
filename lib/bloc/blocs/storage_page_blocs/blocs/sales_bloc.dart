import 'dart:convert';
import 'package:alan/bloc/blocs/storage_page_blocs/events/sales_event.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/events/storage_sales_event.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/sales_state.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/storage_sales_state.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


// Import your constants (e.g. baseUrl)
import 'package:alan/constant.dart';

class StorageSalesBloc extends Bloc<StorageSalesEvent, StorageSalesState> {
  StorageSalesBloc() : super(StorageSalesInitial()) {
    on<FetchAllSalesEvent>(_fetchAllSales);
    on<CreateSalesEvent>(_createSales);
    on<UpdateSaleEvent>(_updateSale);
    on<DeleteSaleEvent>(_deleteSale);
  }

  // 1) FETCH ALL SALES
  Future<void> _fetchAllSales(
    FetchAllSalesEvent event,
    Emitter<StorageSalesState> emit,
  ) async {
    emit(StorageSalesLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('${baseUrl}getStorageSales'), // Your actual endpoint
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        emit(StorageSalesListLoaded(data));
      } else {
        final errData = jsonDecode(response.body);
        emit(StorageSalesError(
          errData['message'] ?? 'Ошибка при загрузке продаж.',
        ));
      }
    } catch (e) {
      emit(StorageSalesError(e.toString()));
    }
  }

  // 2) CREATE SALES
  Future<void> _createSales(
    CreateSalesEvent event,
    Emitter<StorageSalesState> emit,
  ) async {
    emit(StorageSalesLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      // Suppose your endpoint is 'storageSalesBulkStore' or 'createSale'
      final response = await http.post(
        Uri.parse('${baseUrl}storageSalesBulkStore'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'sales': event.sales, // or a single sale object, depending on your backend
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        emit(StorageSalesCreated("Продажа успешно сохранена!"));
      } else {
        final errorData = jsonDecode(response.body);
        emit(StorageSalesError(
          errorData['message'] ?? "Ошибка при сохранении продажи ед измерения не совпадают.",
        ));
      }
    } catch (e) {
      emit(StorageSalesError(e.toString()));
    }
  }

  // 3) UPDATE SALE
  Future<void> _updateSale(
    UpdateSaleEvent event,
    Emitter<StorageSalesState> emit,
  ) async {
    emit(StorageSalesLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.put(
        Uri.parse('${baseUrl}updateSale/${event.docId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(event.updatedData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(StorageSalesUpdated(data['message'] ?? 'Sale updated.'));
      } else {
        final err = jsonDecode(response.body);
        emit(StorageSalesError(err['error'] ?? 'Ошибка при обновлении.'));
      }
    } catch (e) {
      emit(StorageSalesError(e.toString()));
    }
  }

  // 4) DELETE SALE
  Future<void> _deleteSale(
    DeleteSaleEvent event,
    Emitter<StorageSalesState> emit,
  ) async {
    emit(StorageSalesLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.delete(
        Uri.parse('${baseUrl}deleteSale/${event.docId}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(StorageSalesDeleted(data['message'] ?? 'Sale deleted.'));
      } else {
        final err = jsonDecode(response.body);
        emit(StorageSalesError(err['error'] ?? 'Ошибка при удалении.'));
      }
    } catch (e) {
      emit(StorageSalesError(e.toString()));
    }
  }
}