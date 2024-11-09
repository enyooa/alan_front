// lib/bloc/blocs/product_bloc.dart
import 'dart:convert';

import 'package:cash_control/constant.dart';
import 'package:cash_control/ui/main/repositories/product_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cash_control/bloc/events/product_event.dart';
import 'package:cash_control/bloc/states/product_state.dart';
import 'package:http/http.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;

  ProductBloc(this.productRepository) : super(ProductInitial()) {
    on<CreateProductEvent>(_onCreateProductEvent);
  }

Future<void> _onCreateProductEvent(CreateProductEvent event, Emitter<ProductState> emit) async {
  emit(ProductLoading());
  try {
    final uri = Uri.parse(baseUrl+'basic-products-prices');
    final request = MultipartRequest('POST', uri);

    // Add text fields
    request.fields['name_of_products'] = event.name;
    request.fields['description'] = event.description ?? '';
    request.fields['country'] = event.country ?? '';
    request.fields['type'] = event.type ?? '';
    request.fields['brutto'] = event.brutto.toString();
    request.fields['netto'] = event.netto.toString();

    print("Creating product with: ");
    print("Name: ${event.name}");
    print("Description: ${event.description}");
    print("Country: ${event.country}");
    print("Type: ${event.type}");
    print("Brutto: ${event.brutto}");
    print("Netto: ${event.netto}");

    // Add file if available
    if (event.photo != null && event.photo!.existsSync()) {
      request.files.add(await MultipartFile.fromPath(
        'photo_product',
        event.photo!.path,
      ));
      print("Photo path: ${event.photo!.path}");
    } else {
      print("No photo selected");
    }

    // Send the request
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    print("Response status code: ${response.statusCode}");
    print("Response body: $responseBody");

    if (response.statusCode == 201) {
      emit(ProductCreated());
    } else {
      final data = jsonDecode(responseBody);
      emit(ProductError(message: data['message'] ?? "Product creation failed."));
    }
  } catch (error) {
    print("Error creating product: $error");
    emit(ProductError(message: error.toString()));
  }
}

}
