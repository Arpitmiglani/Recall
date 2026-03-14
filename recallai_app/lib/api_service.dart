import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  // Change this if using Android emulator
  final String baseUrl = "http://127.0.0.1:8000";

  Future<String> sendCommand(String text) async {

    try {

      final response = await http.post(
        Uri.parse("$baseUrl/command"),
        headers: {
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "text": text
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {

        final Map<String, dynamic> data = jsonDecode(response.body);

        return data["response"] ?? "No response from server";

      } else {

        return "Server error: ${response.statusCode}";

      }

    } catch (e) {

      return "Connection error: $e";

    }
  }
}