import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  final String baseUrl;

  ChatService({required this.baseUrl});

  Future<List<Map<String, dynamic>>> fetchMessages() async {
    final response = await http.get(Uri.parse(baseUrl+'messages'));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load messages');
    }
  }

  Future<void> sendMessage(String userId, String message) async {
    final response = await http.post(
      Uri.parse(baseUrl+'send-message'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'message': message}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send message');
    }
  }
}
