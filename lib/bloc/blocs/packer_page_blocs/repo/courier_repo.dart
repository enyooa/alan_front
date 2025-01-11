import 'package:http/http.dart' as http;
import 'dart:convert';

class CourierRepository {
  final String baseUrl;

  CourierRepository({required this.baseUrl});

  Future<List<Map<String, dynamic>>> fetchCouriers() async {
    final response = await http.get(Uri.parse(baseUrl+'getCourierUsers'));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch couriers');
    }
  }
}
