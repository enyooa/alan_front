// lib/repository/product_repository.dart
import 'dart:io';
import 'package:cash_control/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductRepository {
  Future<bool> createProduct({
    required String name,
    String? description,
    String? country,
    String? type,
    required double brutto,
    required double netto,
    File? photo,
  }) async {
    final uri = Uri.parse('$baseUrl/basic-products-prices');
    final request = http.MultipartRequest('POST', uri);

    request.fields['name_of_products'] = name;
    request.fields['description'] = description ?? '';
    request.fields['country'] = country ?? '';
    request.fields['type'] = type ?? '';
    request.fields['brutto'] = brutto.toString();
    request.fields['netto'] = netto.toString();

    if (photo != null) {
      request.files.add(await http.MultipartFile.fromPath('photo_product', photo.path));
    }

    final response = await request.send();
    return response.statusCode == 201;
  }
}
