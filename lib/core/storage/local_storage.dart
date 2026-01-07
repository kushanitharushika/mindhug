import 'package:shared_preferences/shared_preferences.dart';

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
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    await prefs.setString('user_phone', phone);
    if (avatarPath != null) {
      await prefs.setString('user_avatar', avatarPath);
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
    };
  }
}
