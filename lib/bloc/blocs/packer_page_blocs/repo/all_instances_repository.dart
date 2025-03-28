// all_instances_repository.dart

import 'dart:convert';
import 'package:alan/constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AllInstancesRepository {

  AllInstancesRepository();

  /// Fetch all instances from the server
  Future<Map<String, dynamic>> fetchAllInstances() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token not found. Please log in again.');
    }

    final response = await http.get(
      Uri.parse(baseUrl+'getAllPackerInstances'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',  // optional, but often helpful
      },
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch all instances (status: ${response.statusCode}).');
    }
  }

  /// Helper to get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
