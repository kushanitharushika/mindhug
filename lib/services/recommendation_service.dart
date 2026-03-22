
import '../models/mood.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class RecommendationService {
  
  // 1. Try to get from ML Engine (Python API)
  static Future<List<String>> getRecommendations({required String level, required Mood mood}) async {
    try {
      // Determine base URL based on platform
      String apiUrl = 'http://127.0.0.1:8000/recommend';
      try {
        if (defaultTargetPlatform == TargetPlatform.android) {
          apiUrl = 'http://10.0.2.2:8000/recommend';
        }
      } catch (_) {
        // Fallback or ignore if platform check fails
      }

      // Map Inputs to Integers (as expected by ML Model)
      final int levelInt = _mapLevelToInt(level);
      final int moodInt = _mapMoodToInt(mood);

      debugPrint("Calling ML API: $apiUrl with Level: $levelInt, Mood: $moodInt");

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'level': levelInt,
          'mood': moodInt,
        }),
      ).timeout(const Duration(seconds: 2)); // Short timeout to fallback quickly

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> exercises = data['recommendations'];
        debugPrint("ML ENGINE SUCCESS: ${exercises.length} recommendations");
        return exercises.cast<String>();
      } else {
        debugPrint("ML ENGINE ERROR: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("ML ENGINE UNAVAILABLE (Using Local Rules): $e");
    }

    // 2. Fallback to Local Rules
    return _getLocalRules(level: level, mood: mood);
  }

  static int _mapLevelToInt(String level) {
    final l = level.toLowerCase();
    if (l.contains("level 0") || l.contains("priority")) return 0;
    if (l.contains("level 1") || l.contains("attention")) return 1;
    if (l.contains("level 2") || l.contains("managing")) return 2;
    if (l.contains("level 3") || l.contains("balanced")) return 3;
    return 2; // Default to 'Managing Well'
  }

  static int _mapMoodToInt(Mood mood) {
    switch (mood.type) {
      case MoodType.anxious: return 0;
      case MoodType.stressed: return 0; // Map stressed to anxious
      
      case MoodType.sad: return 1;
      case MoodType.tired: return 1; // Map tired to sad/low energy
      
      case MoodType.neutral: return 2;
      
      case MoodType.calm: return 3;
      
      case MoodType.happy: return 4;
      case MoodType.energetic: return 4; // Map energetic to happy
    }
  }

  // Mapping of Level -> Mood -> Exercise Types (or specific titles)
  static List<String> _getLocalRules({required String level, required Mood mood}) {
    // Normalize level string to handle potential formatting diffs
    final cleanLevel = level.toLowerCase();
    
    // Level 0 - Priority Support Needed
    if (cleanLevel.contains("priority") || cleanLevel.contains("level 0")) {
      switch (mood.type) {
        case MoodType.anxious:
          return ['Deep Breathing', '4-7-8 Breathing', 'Box Breathing', 'Progressive Muscle Relaxation', 'Gentle Neck & Shoulder Stretches', 'Seated Forward Fold', '5-4-3-2-1 Grounding', 'Guided Body Scan', 'Holding a warm object', 'Listening to calming nature sounds', 'Watching slow visual patterns'];
        case MoodType.sad:
          return ['Gentle Yoga', 'Deep Breathing', 'Stretching (full body)', 'Slow Walking', 'Seated Cat-Cow', 'Guided Meditation', 'Gratitude journaling', 'Listening to soft instrumental music', 'Sitting near sunlight', 'Self-compassion affirmations'];
        case MoodType.neutral:
        case MoodType.tired:
          return ['Gentle Yoga', 'Stretching', 'Slow Walking', 'Seated Mobility Exercises', 'Arm Circles & Ankle Rolls', 'Mindful Sitting', 'Breathing Awareness', 'Listening to white noise', 'Light body scan', 'Minimal to-do planning'];
        case MoodType.calm:
          return ['Gentle Yoga', 'Stretching', 'Body Scan Movement', 'Light Walking', 'Supine Twists', 'Mindful Breathing', 'Journaling feelings', 'Soft background music', 'Tea / hydration reminder', 'Digital detox'];
        case MoodType.happy:
        case MoodType.energetic:
          return ['Light Walking', 'Gentle Yoga', 'Stretching', 'Seated Balance Exercises', 'Mobility Flow', 'Gratitude list', 'Light dancing (slow tempo)', 'Sharing positive thoughts', 'Music listening', 'Visualization exercises'];
        default:
          return ['Deep Breathing', 'Grounding Exercises'];
      }
    }
    
    // Level 1 - Needs Attention
    if (cleanLevel.contains("needs attention") || cleanLevel.contains("level 1")) {
      switch (mood.type) {
        case MoodType.anxious:
           return ['Breathing Exercises', 'Progressive Muscle Relaxation', 'Gentle Yoga', 'Stretching', 'Mindful Walking', 'Seated Forward Fold', 'Grounding with senses', 'Writing worries -> release', 'Nature sounds', 'Calm breathing timer', 'Posture check'];
        case MoodType.sad:
           return ['Walking', 'Gentle Yoga', 'Light Stretching', 'Seated Mobility', 'Slow Dance Movement', 'Mindful Movement', 'Music with positive tone', 'Journaling emotions', 'Gratitude notes', 'Sun exposure'];
        case MoodType.neutral:
        case MoodType.tired:
           return ['Yoga', 'Stretching', 'Walking', 'Light Cardio', 'Balance Exercises', 'Body awareness scan', 'Daily intention setting', 'Breathing focus', 'Minimal task planning', 'Calm playlist'];
        case MoodType.calm:
           return ['Yoga Flow', 'Stretching', 'Walking', 'Light Cardio', 'Core Activation (gentle)', 'Mindful Breathing', 'Light journaling', 'Visualization', 'Hydration reminder', 'Music-based relaxation'];
        case MoodType.happy:
        case MoodType.energetic:
           return ['Light Cardio', 'Dance Workout', 'Yoga', 'Walking', 'Mobility Flow', 'Mood reflection', 'Gratitude journaling', 'Music engagement', 'Short creative activity', 'Social connection reminder'];
        default:
           return ['Walking', 'Stretching'];
      }
    }

    // Level 2 - Managing Well
    if (cleanLevel.contains("managing well") || cleanLevel.contains("level 2")) {
      switch (mood.type) {
        case MoodType.anxious:
          return ['Yoga', 'Controlled Breathing', 'Walking', 'Stretching', 'Light Cardio', 'Mobility Flow', 'Breath pacing', 'Mindful journaling', 'Relaxing music', 'Nature exposure', 'Goal reflection'];
        case MoodType.sad:
          return ['Brisk Walking', 'Light Cardio', 'Yoga', 'Dance Workout', 'Stretching', 'Mood journaling', 'Positive music', 'Self-talk exercises', 'Visualization', 'Short creative task'];
        case MoodType.neutral:
        case MoodType.tired:
          return ['Pilates', 'Yoga', 'Walking', 'Light Cardio', 'Core Training', 'Mindful planning', 'Breathing reset', 'Focus timer', 'Body posture check', 'Music break'];
        case MoodType.calm:
          return ['Light Strength Training', 'Yoga', 'Mobility Exercises', 'Walking', 'Stretching', 'Goal setting', 'Reflection journaling', 'Breath awareness', 'Music with rhythm', 'Hydration habit'];
        case MoodType.happy:
        case MoodType.energetic:
          return ['Cardio Workout', 'Dance Workout', 'Strength Training', 'Yoga', 'Walking', 'Achievement reflection', 'Social engagement', 'Creative expression', 'Music flow', 'Positive affirmation'];
        default:
          return ['Walking', 'Yoga'];
      }
    }

    // Level 3 - Balanced & Resilient (Default fallback too)
    // if (cleanLevel.contains("balanced") || cleanLevel.contains("level 3")) 
    switch (mood.type) {
      case MoodType.anxious:
        return ['Cardio', 'Yoga', 'Stretching', 'Mobility Exercises', 'Cool-down Breathing', 'Balance Training', 'Breath control', 'Visualization', 'Focus training', 'Music regulation', 'Stress-release journaling'];
      case MoodType.sad:
        return ['Strength Training', 'Cardio', 'Walking', 'Yoga', 'Stretching', 'Mood tracking', 'Positive self-talk', 'Gratitude journaling', 'Music motivation', 'Short social activity'];
      case MoodType.neutral:
      case MoodType.tired:
        return ['Mixed Workout', 'Strength Training', 'Cardio', 'Yoga', 'Core Training', 'Goal planning', 'Productivity reflection', 'Focus breathing', 'Energy check-in', 'Music boost'];
      case MoodType.calm:
        return ['Strength Training', 'Mobility Training', 'Yoga', 'Walking', 'Stretching', 'Long-term planning', 'Deep breathing', 'Reflection writing', 'Music immersion', 'Habit tracking'];
      case MoodType.happy:
      case MoodType.energetic:
        return ['HIIT', 'Running', 'Strength Training', 'Dance Workout', 'Cardio', 'Performance tracking', 'Celebration reflection', 'Music motivation', 'Social sharing', 'Confidence affirmations'];
      default:
        return ['Cardio', 'Strength Training'];
    }
  }
}
