import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constant.dart';

class OrganizationService {
  Future<bool> createOrganization(String name, String currentAccounts) async {
    final response = await http.post(
      Uri.parse(baseUrl+'organizations'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'current_accounts': currentAccounts}),
    );

    if (response.statusCode == 201) {
      return true; // Organization created successfully
    } else {
      print('Error: ${response.body}');
      return false;
    }
  }
}
