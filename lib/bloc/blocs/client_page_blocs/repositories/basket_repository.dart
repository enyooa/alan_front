import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BasketRepository {
  final String baseUrl;

  BasketRepository({required this.baseUrl});

  /// Fetch token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Ensure you store the token with the key 'token'
  }

  Future<Map<String, Map<String, dynamic>>> getBasket() async {
  final token = await _getToken();

  if (token == null) {
    throw Exception('Authentication token not found');
  }

  final response = await http.get(
    Uri.parse(baseUrl+'basket'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);

    // Extract 'basket' as a List
    final basketList = List<Map<String, dynamic>>.from(jsonResponse['basket']);
    return {
      for (var item in basketList) item['id'].toString(): item,
    };
  } else {
    print('Failed to fetch basket. Response: ${response.body}');
    throw Exception('Failed to fetch basket');
  }
}

 Future<void> addToBasket(Map<String, dynamic> product) async {
  final token = await _getToken();

  if (token == null) {
    throw Exception('Authentication token not found');
  }

  final response = await http.post(
    Uri.parse(baseUrl+'basket/add'),
    body: jsonEncode(product),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 201) {
    final jsonResponse = jsonDecode(response.body);

    if (jsonResponse['success'] == true) {
      final basketItem = jsonResponse['basket'];
      print('Basket item added: $basketItem');
    } else {
      throw Exception('Failed to add product: ${jsonResponse['message']}');
    }
  } else {
    print('Failed Response: ${response.body}');
    throw Exception('Failed to add product. Status: ${response.statusCode}');
  }
}
 /// Remove item from the basket
  Future<void> removeFromBasket(String productId) async {
    final token = await _getToken();

    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await http.post(
      Uri.parse(baseUrl+'basket/remove'),
      body: jsonEncode({'product_id': productId}),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove product from basket');
    }
  }

  /// Clear the basket
  Future<void> clearBasket() async {
    final token = await _getToken();

    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await http.post(
      Uri.parse(baseUrl+'basket/clear'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to clear basket');
    }
  }

  Future<void> placeOrder(String address) async {
  final token = await _getToken();

  if (token == null) {
    throw Exception('Authentication token not found');
  }

  final response = await http.post(
    Uri.parse(baseUrl+'basket/place-order'),
    body: jsonEncode({'address': address}),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 201) {
    print('Order placed successfully: ${response.body}');
  } else {
    print('Failed to place order: ${response.body}');
    throw Exception('Failed to place order');
  }
}

Future<List<Map<String, dynamic>>> getPackerOrders() async {
  final token = await _getToken();

  final response = await http.get(
    Uri.parse(baseUrl+  'packer/orders'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    return List<Map<String, dynamic>>.from(jsonDecode(response.body)['orders']);
  } else {
    throw Exception('Failed to fetch packer orders');
  }
}


}
