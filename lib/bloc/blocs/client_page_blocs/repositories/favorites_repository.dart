import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesRepository {
  final String baseUrl;

  FavoritesRepository({required this.baseUrl});

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(baseUrl+'getFavorites'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body)['favorites']);
    } else {
      throw Exception('Failed to fetch favorites');
    }
  }

  Future<void> addToFavorites(Map<String, dynamic> product) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse(baseUrl+'addToFavorites'),
      body: jsonEncode(product),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add to favorites');
    }
  }

  Future<void> removeFromFavorites(String productId) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse(baseUrl+'removeFromFavorites'),
      body: jsonEncode({'product_id': productId}),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove from favorites');
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
