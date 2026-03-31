import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mindhug/services/recommendation_service.dart';
import 'package:mindhug/models/mood.dart';

void main() {
  group('RecommendationService Tests', () {

    group('mapLevelToInt', () {
      test('maps Level 0 terms to 0', () {
        expect(RecommendationService.mapLevelToInt("Priority required"), 0);
        expect(RecommendationService.mapLevelToInt("Level 0"), 0);
      });

      test('maps Level 1 terms to 1', () {
        expect(RecommendationService.mapLevelToInt("Needs attention"), 1);
        expect(RecommendationService.mapLevelToInt("Level 1"), 1);
      });

      test('maps Level 2 terms to 2', () {
        expect(RecommendationService.mapLevelToInt("Managing Well"), 2);
        expect(RecommendationService.mapLevelToInt("Level 2 - Managing well"), 2);
      });

      test('maps Level 3 terms to 3', () {
        expect(RecommendationService.mapLevelToInt("Balanced & Resilient"), 3);
        expect(RecommendationService.mapLevelToInt("Level 3"), 3);
      });

      test('defaults unknown terms to 2', () {
        expect(RecommendationService.mapLevelToInt("Unknown Level"), 2);
      });
    });

    group('mapMoodToInt', () {
      test('maps anxious/stressed to 0', () {
        expect(RecommendationService.mapMoodToInt(Mood(type: MoodType.anxious, label: 'Anxious', color: Colors.black, icon: Icons.waves)), 0);
        expect(RecommendationService.mapMoodToInt(Mood(type: MoodType.stressed, label: 'Stressed', color: Colors.black, icon: Icons.warning)), 0);
      });

      test('maps sad/tired to 1', () {
        expect(RecommendationService.mapMoodToInt(Mood(type: MoodType.sad, label: 'Sad', color: Colors.black, icon: Icons.mood_bad)), 1);
        expect(RecommendationService.mapMoodToInt(Mood(type: MoodType.tired, label: 'Tired', color: Colors.black, icon: Icons.bed)), 1);
      });

      test('maps neutral to 2', () {
        expect(RecommendationService.mapMoodToInt(Mood(type: MoodType.neutral, label: 'Neutral', color: Colors.black, icon: Icons.face)), 2);
      });

      test('maps calm to 3', () {
        expect(RecommendationService.mapMoodToInt(Mood(type: MoodType.calm, label: 'Calm', color: Colors.black, icon: Icons.spa)), 3);
      });

      test('maps happy/energetic to 4', () {
        expect(RecommendationService.mapMoodToInt(Mood(type: MoodType.happy, label: 'Happy', color: Colors.black, icon: Icons.mood)), 4);
        expect(RecommendationService.mapMoodToInt(Mood(type: MoodType.energetic, label: 'Energetic', color: Colors.black, icon: Icons.bolt)), 4);
      });
    });

    group('getLocalRules', () {
      test('returns specific exercises for Level 0 + Anxious', () {
        final rules = RecommendationService.getLocalRules(
          level: "Level 0", 
          mood: const Mood(type: MoodType.anxious, label: 'Anxious', color: Colors.black, icon: Icons.waves)
        );
        expect(rules, contains('Deep Breathing'));
        expect(rules, contains('Box Breathing'));
        expect(rules.length, greaterThan(2));
      });

      test('returns specific exercises for Level 3 + Happy', () {
        final rules = RecommendationService.getLocalRules(
          level: "Level 3", 
          mood: const Mood(type: MoodType.happy, label: 'Happy', color: Colors.black, icon: Icons.mood)
        );
        expect(rules, contains('HIIT'));
        expect(rules, contains('Dance Workout'));
        expect(rules.length, greaterThan(2));
      });
    });
  });
}
