import 'dart:convert';
import 'package:cash_control/constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UnitService {
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<http.Response> createUnit(String name) async {
    final token = await getToken();
    return await http.post(
      Uri.parse('$baseUrl/unit-measurements'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name}),
    );
  }
}
