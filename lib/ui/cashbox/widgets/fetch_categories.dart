import 'package:alan/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Fetch categories from the API
Future<List<String>> fetchCategories() async {
  final response = await http.get(Uri.parse(baseUrl+'categories'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => item['name'].toString()).toList();
  } else {
    throw Exception('Failed to load categories');
  }
}
