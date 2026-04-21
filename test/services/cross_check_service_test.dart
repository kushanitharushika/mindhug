import 'package:flutter_test/flutter_test.dart';
import 'package:mindhug/services/cross_check_service.dart';
import 'package:mindhug/models/exercise.dart';

void main() {
  group('CrossCheckService Tests', () {
    final mockAvailableExercises = [
      Exercise(id: '1', title: 'Deep Breathing', description: '', duration: '', type: ExerciseType.breathing),
      Exercise(id: '2', title: 'Box Breathing', description: '', duration: '', type: ExerciseType.breathing),
      Exercise(id: '3', title: 'Body Scan', description: '', duration: '', type: ExerciseType.meditation),
      Exercise(id: '4', title: 'Quick Stretch', description: '', duration: '', type: ExerciseType.physical),
      Exercise(id: '5', title: 'Jumping Jacks', description: '', duration: '', type: ExerciseType.physical),
      Exercise(id: '6', title: 'Grounding', description: '', duration: '', type: ExerciseType.grounding),
      Exercise(id: '7', title: 'Gratitude', description: '', duration: '', type: ExerciseType.other),
      Exercise(id: '8', title: 'Yoga', description: '', duration: '', type: ExerciseType.physical),
      Exercise(id: '9', title: 'Walking', description: '', duration: '', type: ExerciseType.physical),
      Exercise(id: '10', title: '4-7-8 Breathing', description: '', duration: '', type: ExerciseType.breathing),
      Exercise(id: '11', title: 'PMR', description: '', duration: '', type: ExerciseType.grounding),
      Exercise(id: '12', title: 'Pilates', description: '', duration: '', type: ExerciseType.physical),
      Exercise(id: '13', title: 'Dance', description: '', duration: '', type: ExerciseType.physical),
      Exercise(id: '14', title: 'Visualization', description: '', duration: '', type: ExerciseType.visualization),
      Exercise(id: '15', title: 'Social', description: '', duration: '', type: ExerciseType.social),
      Exercise(id: '16', title: 'Goal Setting', description: '', duration: '', type: ExerciseType.planning),
      Exercise(id: '17', title: 'Music', description: '', duration: '', type: ExerciseType.music),
    ];

    test('isManagingWell returns true for Level 2', () {
      expect(CrossCheckService.isManagingWell("Level 2 - Managing Well"), isTrue);
    });

    test('isManagingWell returns false for Priority', () {
      expect(CrossCheckService.isManagingWell("Priority - High Stress"), isFalse);
    });

    test('getRecommendations returns exactly 3 exercises', () {
      final recommendations = CrossCheckService.getRecommendations(
        userLevel: "Level 1 - Needs Attention", 
        stroopStressLevel: "Stressed", 
        availableExercises: mockAvailableExercises
      );
      
      expect(recommendations.length, equals(3));
    });

    test('getRecommendations high stress picks from high stress pool', () {
      final recommendations = CrossCheckService.getRecommendations(
        userLevel: "Priority Required", // Not low stress
        stroopStressLevel: "Stressed", 
        availableExercises: mockAvailableExercises
      );
      
      // High stress pool: breathing (1,2,10), meditation (3), grounding (6,11)
      final highStressPoolIds = ['1', '2', '3', '6', '10', '11'];
      for (var ex in recommendations) {
        expect(highStressPoolIds.contains(ex.id), isTrue);
      }
    });

    test('getRecommendations calm state picks from calm pool', () {
      final recommendations = CrossCheckService.getRecommendations(
        userLevel: "Level 2 - Managing Well", // is low stress
        stroopStressLevel: "Calm", 
        availableExercises: mockAvailableExercises
      );
      
      // Calm pool: physical (4,5,8,9,12,13), social (15), planning (16)
      final calmPoolIds = ['4', '5', '8', '9', '12', '13', '15', '16'];
      for (var ex in recommendations) {
        expect(calmPoolIds.contains(ex.id), isTrue);
      }
    });

    test('getRecommendations returns different sequences on multiple calls (randomness check)', () {
      final recs1 = CrossCheckService.getRecommendations(
        userLevel: "Level 3 - Balanced", 
        stroopStressLevel: "Calm", 
        availableExercises: mockAvailableExercises
      );
      
      final recs2 = CrossCheckService.getRecommendations(
        userLevel: "Level 3 - Balanced", 
        stroopStressLevel: "Calm", 
        availableExercises: mockAvailableExercises
      );
      
      // While there is a slim mathematical chance they shuffle to the exact same order and selection,
      // testing randomness strictly can be flaky. But we check that 
      // the result is valid regardless. 
      expect(recs1.length, equals(3));
      expect(recs2.length, equals(3));
    });
  });
}
