import 'dart:convert';
import 'package:alan/bloc/blocs/admin_page_blocs/events/price_offer_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/price_offer_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:alan/constant.dart';
class PriceOfferBloc extends Bloc<PriceOfferEvent, PriceOfferState> {
  PriceOfferBloc() : super(PriceOfferInitial()) {
    on<SubmitPriceOfferEvent>(_onSubmitPriceOffer);
    on<FetchPriceOffersEvent>(_onFetchPriceOffers);
    on<UpdatePriceOfferEvent>(_onUpdatePriceOffer);
    on<DeletePriceOfferEvent>(_onDeletePriceOffer);
  }

  // Handle the FetchPriceOffersEvent to fetch all required data
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

    // Make the API call to fetch all the required data
    final response = await http.get(
      Uri.parse(baseUrl + 'fetch_data_of_price_offer'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Handle success response
      if (data['success'] == true) {
        // Parse the data and convert DateTime if needed
        List<Map<String, dynamic>> clientUsers = List<Map<String, dynamic>>.from(data['client_users']);
        List<Map<String, dynamic>> subCards = List<Map<String, dynamic>>.from(data['subcards']);
        List<Map<String, dynamic>> units = List<Map<String, dynamic>>.from(data['units']);

        // Emit the fetched data
        emit(PriceOffersFetched(
          clientUsers: clientUsers,
          subCards: subCards,
          units: units,
        ));
      } else {
        emit(PriceOfferError(message: data['message'] ?? "Error fetching data."));
      }
    } else {
      emit(PriceOfferError(message: "Network error."));
    }
  } catch (error) {
    emit(PriceOfferError(message: "Error: $error"));
  }
}
// Submit price offer data
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
          'totalsum': event.totalSum,
          'price_offers': event.priceOfferRows,
        }),
      );

      if (response.statusCode == 201) {
        emit(PriceOfferSubmitted(message: "Price offer successfully saved."));
      } else {
        final errorData = jsonDecode(response.body);
        emit(PriceOfferError(
            message: errorData['message'] ?? "Error saving price offer."));
      }
    } catch (error) {
      emit(PriceOfferError(message: "Error: $error"));
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
        emit(PriceOfferUpdated(message: "Price offer successfully updated."));
      } else {
        final errorData = jsonDecode(response.body);
        emit(PriceOfferError(message: errorData['message'] ?? "Error updating price offer."));
      }
    } catch (error) {
      emit(PriceOfferError(message: "Error: $error"));
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
        Uri.parse('${baseUrl}price-offers/${event.id}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        emit(PriceOfferDeleted(message: "Price offer successfully deleted."));
      } else {
        final errorData = jsonDecode(response.body);
        emit(PriceOfferError(message: errorData['message'] ?? "Error deleting price offer."));
      }
    } catch (error) {
      emit(PriceOfferError(message: "Error: $error"));
    }
  }
}
