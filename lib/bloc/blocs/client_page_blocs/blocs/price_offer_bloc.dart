import 'dart:convert';

import 'package:alan/bloc/blocs/client_page_blocs/events/price_offer_event.dart';
import 'package:alan/bloc/blocs/client_page_blocs/states/price_offer_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:alan/constant.dart';

class PriceOfferBloc extends Bloc<PriceOfferEvent, PriceOfferState> {
  PriceOfferBloc() : super(PriceOfferInitial()) {
    on<FetchPriceOffersEvent>(_onFetchPriceOffers);// Add delete event handler
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

}
