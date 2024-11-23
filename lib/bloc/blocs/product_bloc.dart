// import 'dart:convert';
// import 'package:cash_control/ui/main/models/product_card.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:cash_control/bloc/events/product_event.dart';
// import 'package:cash_control/bloc/states/product_state.dart';
// import 'package:http/http.dart' as http;
// import 'package:cash_control/constant.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ProductBloc extends Bloc<ProductEvent, ProductState> {
//   ProductBloc() : super(ProductInitial()) {
//     on<FetchProductsEvent>(_onFetchProductsEvent);
//   }

//   Future<void> _onFetchProductsEvent(FetchProductsEvent event, Emitter<ProductState> emit) async {
//     emit(ProductLoading());

//     try {
//       // Get the stored token from SharedPreferences
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');

//       if (token == null) {
//         emit(ProductError(message: "Authentication token not found."));
//         return;
//       }

//       // Make the request with the Authorization header
//       final response = await http.get(
//         Uri.parse(baseUrl+'product_cards'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         final products = data.map((json) => ProductCard.fromJson(json)).toList();
//         emit(ProductsLoaded(products: products));
//       } else {
//         emit(ProductError(message: "Failed to load products. Status code: ${response.statusCode}"));
//       }
//     } catch (error) {
//       emit(ProductError(message: error.toString()));
//     }
//   }
// }
