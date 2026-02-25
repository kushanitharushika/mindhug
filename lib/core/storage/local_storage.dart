import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/journal_entry.dart';
import '../../models/care_item.dart';

class LocalStorage {
  /// Save quiz result
  static Future<void> saveQuizResult({
    required int score,
    required String level,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quiz_score', score);
    await prefs.setString('mental_health_level', level);
    await prefs.setBool('quiz_completed', true);
    
    // Save to history
    await saveQuizHistory(score, level);
  }

  /// Get quiz result
  static Future<Map<String, dynamic>?> getQuizResult() async {
    final prefs = await SharedPreferences.getInstance();
    final score = prefs.getInt('quiz_score');
    final level = prefs.getString('mental_health_level');
    
    if (score != null && level != null) {
      return {'score': score, 'level': level};
    }
    return null;
  }

  /// Save quiz history entry
  static Future<void> saveQuizHistory(int score, String level) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList('quiz_history') ?? [];
    
    final entry = {
      'date': DateTime.now().toIso8601String(),
      'score': score,
      'level': level,
    };
    
    history.add(jsonEncode(entry));
    await prefs.setStringList('quiz_history', history);
  }

  /// Get quiz history
  static Future<List<Map<String, dynamic>>> getQuizHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList('quiz_history') ?? [];
    
    return history.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  /// Get notification preference
  static Future<bool> getNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? false;
  }

  /// Save notification preference
  static Future<void> saveNotificationPreference(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
  }

  /// Get stored mental health level
  static Future<String?> getMentalHealthLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('mental_health_level');
  }

  /// Check if quiz was completed
  static Future<bool> isQuizCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('quiz_completed') ?? false;
  }

  /// Check if quiz is due (older than 7 days or not taken yet)
  static Future<bool> isQuizDue() async {
    final history = await getQuizHistory();
    if (history.isEmpty) {
      return true; // Never taken
    }
    
    // History is stored chronologically, so last item is the most recent
    final lastEntry = history.last;
    final dateStr = lastEntry['date'] as String?;
    
    if (dateStr == null) return true;

    try {
      final lastTakeDate = DateTime.parse(dateStr);
      final difference = DateTime.now().difference(lastTakeDate);
      return difference.inDays >= 7;
    } catch (e) {
      debugPrint("Error parsing quiz date in isQuizDue: $e");
      return true; // Fallback to forcing it if data is corrupt
    }
  }

  /// Get stored quiz score
  static Future<int> getQuizScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('quiz_score') ?? 0;
  }

  /// Clear quiz data (optional, for testing or retake)
  static Future<void> clearQuizData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('quiz_score');
    await prefs.remove('mental_health_level');
    await prefs.remove('quiz_completed');
  }
  /// Save user profile
  static Future<void> saveUserProfile({
    required String name,
    required String email,
    required String phone,
    String? avatarPath,
    String? birthday,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    await prefs.setString('user_phone', phone);
    if (avatarPath != null) {
      await prefs.setString('user_avatar', avatarPath);
    }
    if (birthday != null) {
      await prefs.setString('user_birthday', birthday);
    }
  }

  /// Get user profile
  static Future<Map<String, String>> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('user_name') ?? 'John Doe',
      'email': prefs.getString('user_email') ?? 'john.doe@example.com',
      'phone': prefs.getString('user_phone') ?? '+1 234 567 890',
      'avatar': prefs.getString('user_avatar') ?? '',
      'birthday': prefs.getString('user_birthday') ?? '',
    };
  }

  /// Save journal entries
  static Future<void> saveJournalEntries(List<JournalEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString('journal_entries', jsonString);
  }

  /// Get journal entries
  static Future<List<JournalEntry>> getJournalEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('journal_entries');
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((e) => JournalEntry.fromJson(e)).toList();
  }

  /// Save care items
  static Future<void> saveCareItems(List<CareItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString('care_items', jsonString);
  }

  /// Get care items
  static Future<List<CareItem>> getCareItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('care_items');
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((e) => CareItem.fromJson(e)).toList();
  }
}
