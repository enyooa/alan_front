import 'dart:convert';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/price_offer_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/price_offer_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:cash_control/constant.dart';

class PriceOfferBloc extends Bloc<PriceOfferEvent, PriceOfferState> {
  PriceOfferBloc() : super(PriceOfferInitial()) {
    on<SubmitPriceOfferEvent>(_onSubmitPriceOffer);
    on<FetchPriceOffersEvent>(_onFetchPriceOffers);
    on<UpdatePriceOfferEvent>(_onUpdatePriceOffer);
    on<DeletePriceOfferEvent>(_onDeletePriceOffer); // Add delete event handler
  }

 Future<void> _onSubmitPriceOffer(
    SubmitPriceOfferEvent event, Emitter<PriceOfferState> emit) async {
  emit(PriceOfferLoading());

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      emit(PriceOfferError(message: "Authentication token not found."));
      return;
    }

    final response = await http.post(
      Uri.parse(baseUrl + 'bulkPriceOffers'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'client_id': event.clientId,
        'start_date': event.startDate,
        'end_date': event.endDate,
        'totalsum': event.totalSum, // Add totalsum here
        'price_offers': event.priceOfferRows,
      }),
    );

    if (response.statusCode == 201) {
      emit(PriceOfferSubmitted(message: "Ценовое предложение успешно сохранено."));
    } else {
      final errorData = jsonDecode(response.body);
      emit(PriceOfferError(
          message: errorData['message'] ?? "Ошибка при сохранении ценового предложения."));
    }
  } catch (error) {
    emit(PriceOfferError(message: "Ошибка: $error"));
  }
}

  Future<void> _onFetchPriceOffers(
      FetchPriceOffersEvent event, Emitter<PriceOfferState> emit) async {
    emit(PriceOfferLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(PriceOfferError(message: "Authentication token not found."));
        return;
      }

      final response = await http.get(
        Uri.parse(baseUrl + 'getUserPriceRequests'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          emit(PriceOffersFetched(priceOffers: List<Map<String, dynamic>>.from(data['data'])));
        } else {
          emit(PriceOfferError(message: data['message'] ?? "Ошибка при получении предложений."));
        }
      } else {
        emit(PriceOfferError(message: "Ошибка сети."));
      }
    } catch (error) {
      emit(PriceOfferError(message: "Ошибка: $error"));
    }
  }

  Future<void> _onUpdatePriceOffer(
      UpdatePriceOfferEvent event, Emitter<PriceOfferState> emit) async {
    emit(PriceOfferLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(PriceOfferError(message: "Authentication token not found."));
        return;
      }

      final response = await http.put(
        Uri.parse('${baseUrl}price-offers/${event.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(event.updatedFields),
      );

      if (response.statusCode == 200) {
        emit(PriceOfferUpdated(message: "Ценовое предложение успешно обновлено."));
      } else {
        final errorData = jsonDecode(response.body);
        emit(PriceOfferError(message: errorData['message'] ?? "Ошибка обновления."));
      }
    } catch (error) {
      emit(PriceOfferError(message: "Ошибка: $error"));
    }
  }

  Future<void> _onDeletePriceOffer(
      DeletePriceOfferEvent event, Emitter<PriceOfferState> emit) async {
    emit(PriceOfferLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(PriceOfferError(message: "Authentication token not found."));
        return;
      }

      final response = await http.delete(
        Uri.parse('{$baseUrl}price-offers/${event.id}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        emit(PriceOfferDeleted(message: "Ценовое предложение успешно удалено."));
      } else {
        final errorData = jsonDecode(response.body);
        emit(PriceOfferError(message: errorData['message'] ?? "Ошибка удаления."));
      }
    } catch (error) {
      emit(PriceOfferError(message: "Ошибка: $error"));
    }
  }
}
