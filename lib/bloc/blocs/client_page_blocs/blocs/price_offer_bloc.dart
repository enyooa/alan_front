import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/price_offer_event.dart';
import 'package:alan/bloc/blocs/client_page_blocs/states/price_offer_state.dart';
import 'package:alan/constant.dart'; 
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PriceOfferBloc extends Bloc<PriceOfferEvent, PriceOfferState> {
  PriceOfferBloc() : super(PriceOfferInitial()) {
    on<FetchPriceOffersEvent>(_onFetchPriceOffers);
  }

  Future<void> _onFetchPriceOffers(
    FetchPriceOffersEvent event,
    Emitter<PriceOfferState> emit,
  ) async {
    emit(PriceOfferLoading());

    try {
      // If your API requires a token, fetch it from SharedPreferences:
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Or if no token is needed, you can skip this step.
      // We'll assume you do need it:
      if (token == null) {
        emit(const PriceOfferError("No authentication token found."));
        return;
      }

      // Call your endpoint, e.g. GET /api/getUserPriceOffers
      final response = await http.get(
        Uri.parse('${baseUrl}getUserPriceOffers'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          // "data" is your list of orders (id, client_id, price_offers, etc.)
          final List<dynamic> orders = data['data'];
          emit(PriceOffersFetched(priceOffers: orders));
        } else {
          final message = data['message'] ?? 'Failed to fetch price offers.';
          emit(PriceOfferError(message));
        }
      } else {
        emit(PriceOfferError('Network error: ${response.statusCode}'));
      }
    } catch (error) {
      emit(PriceOfferError('Error: $error'));
    }
  }
}
