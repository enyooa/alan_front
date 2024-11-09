import 'dart:convert';
import 'package:cash_control/constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrganizationService {
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<http.Response> createOrganization({required String name, required String currentAccounts}) async {
    final token = await getToken();
    return await http.post(
      Uri.parse('$baseUrl/organizations'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name, 'current_accounts': currentAccounts}),
    );
  }
}
