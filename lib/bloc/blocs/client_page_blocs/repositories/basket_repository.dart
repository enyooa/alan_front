import 'package:cash_control/bloc/models/basket_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BasketRepository {
  final String baseUrl;

  BasketRepository({required this.baseUrl});

// Future<Map<String, dynamic>> getBasket() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');

//     if (token == null) {
//       throw Exception('Token not found');
//     }

//     final response = await http.get(
//       Uri.parse(baseUrl+'basket'),
//       headers: {'Authorization': 'Bearer $token'},
//     );

//     if (response.statusCode == 200) {
//       final basketList = List<Map<String, dynamic>>.from(jsonDecode(response.body)['basket']);
//       return {for (var item in basketList) item['id'].toString(): item};
//     } else {
//       throw Exception('Failed to fetch basket');
//     }
//   }

  /// Fetch token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Ensure you store the token with the key 'token'
  }

 Future<List<BasketItem>> getBasket() async {
    final token = await _getToken();
    if (token == null) throw Exception('Authentication token not found');

    final response = await http.get(
      Uri.parse(baseUrl+'basket'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final basketList = List<Map<String, dynamic>>.from(jsonResponse['basket']);
      return basketList.map((item) => BasketItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch basket');
    }
  }


 
  Future<void> addToBasket(Map<String, dynamic> product) async {
    final token = await _getToken();
    if (token == null) throw Exception('Authentication token not found');

    final response = await http.post(
      Uri.parse(baseUrl+'basket/add'),
      body: jsonEncode(product), // Include price in the payload
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add product to basket');
    }
  }



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

  Future<String> placeOrder(String address) async {
  final token = await _getToken(); // Fetch the token

  if (token == null) {
    throw Exception('Authentication token not found');
  }

  final url = Uri.parse(baseUrl + 'basket/place-order');
  final response = await http.post(
    url,
    body: jsonEncode({'address': address}),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    // Handle success for both 200 and 201
    final jsonResponse = jsonDecode(response.body);
    if (jsonResponse['success'] == true && jsonResponse.containsKey('order')) {
      final orderId = jsonResponse['order']['id'].toString(); // Adjust key as per API response
      return orderId;
    } else {
      throw Exception('Order ID not found in the response');
    }
  } else if (response.statusCode == 400 || response.statusCode == 422) {
    // Handle validation errors or bad requests
    final jsonResponse = jsonDecode(response.body);
    final errorMessage = jsonResponse['message'] ?? 'Invalid request';
    throw Exception('Failed to place order: $errorMessage');
  } else if (response.statusCode == 401) {
    throw Exception('Authentication failed. Please log in again.');
  } else {
    throw Exception('Unexpected response: ${response.statusCode}, ${response.body}');
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
