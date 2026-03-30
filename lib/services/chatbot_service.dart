import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatbotService {
  // Replace with the actual URL of your Node.js backend that hosts the JWT code
  static const String _authUrl = 'http://192.168.8.114:8000/api/chatbase-auth'; 

  /// Fetches the Chatbase signed JWT token for the current user
  /// You use this if you migrate the WebView to use the standard script injection
  /// instead of iframe, or if you build your own chat UI using Chatbase API.
  Future<String?> getUserToken() async {
    try {
      final response = await http.get(
        Uri.parse(_authUrl),
        headers: {'Content-Type': 'application/json'},
        // You would likely pass your Firebase auth token here to authenticate
        // the request to your Node.js backend
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'] as String;
      } else {
        debugPrint('Error fetching token: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error connecting to backend: $e');
      return null;
    }
  }

  /// Sends user message to the ML engine backend and returns the response
  Future<String> getResponse(String message) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.8.114:8000/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] as String;
      } else {
        debugPrint('Error from ML engine: ${response.statusCode}');
        return "I'm having a bit of trouble connecting to my brain right now... 🌸";
      }
    } catch (e) {
      debugPrint('Error connecting to ML engine: $e');
      return "I can't seem to reach my thoughts. Maybe check your connection? 🌷";
    }
  }
}
