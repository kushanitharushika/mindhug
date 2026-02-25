import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatbotService {
  // Using user provided local IP for access from physical device
  static const String _baseUrl = 'http://192.168.8.117:8000'; 

  Future<String> getResponse(String input) async {
    if (input.trim().isEmpty) return "I didn't quite catch that. Could you say it again?";

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': input}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] as String;
      } else {
        debugPrint('Error fetching response: ${response.statusCode}');
        return "I'm having a bit of trouble connecting right now. Can we try again later?";
      }
    } catch (e) {
      debugPrint('Error connecting to chatbot backend: $e');
      return "I seem to be offline. Please check your connection.";
    }
  }
}
