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
        Uri.parse(baseUrl + 'bulkPriceOffers'), // Endpoint for bulk price offers
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'client_id': event.clientId,
          'start_date': event.startDate,
          'end_date': event.endDate,
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
}
