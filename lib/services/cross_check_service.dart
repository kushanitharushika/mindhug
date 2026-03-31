import '../models/exercise.dart';

class CrossCheckService {
  /// Evaluates if the user's self-reported state is generally 'low stress'.
  static bool isManagingWell(String userLevel) {
    final lowerLevel = userLevel.toLowerCase();
    return lowerLevel.contains("level 1") || 
           lowerLevel.contains("level 2") || 
           lowerLevel.contains("low") ||
           lowerLevel.contains("managing well");
  }

  /// Calculates the final list of recommended exercises based on the cross-referenced stats.
  static List<Exercise> getRecommendations({
    required String userLevel,
    required String stroopStressLevel,
    required List<Exercise> availableExercises,
  }) {
    final bool isLowStress = isManagingWell(userLevel);
    List<String> pool = [];

    if (!isLowStress && stroopStressLevel == "Stressed") {
       // Both indicate high stress - grounding & direct calming
       pool = ['1', '2', '3', '6', '10', '11'];
    } else if (isLowStress && stroopStressLevel == "Stressed") {
       // Subconscious stress - resetting & relaxation
       pool = ['3', '8', '10', '11', '14', '17'];
    } else if (!isLowStress && stroopStressLevel == "Calm") {
       // Quiz says stressed, but stroop says calm - reflective & mood-boosting
       pool = ['4', '7', '8', '14', '15', '17'];
    } else {
       // Both indicate good state - moderate activity/maintenance
       pool = ['5', '9', '12', '13', '15', '16'];
    }

    pool.shuffle();
    final selectedIds = pool.take(3).toList();
    
    // Safely map IDs to actual Exercise objects
    List<Exercise> recommended = [];
    for (var id in selectedIds) {
      try {
        recommended.add(availableExercises.firstWhere((e) => e.id == id));
      } catch (e) {
        // Ignore if exercise ID is not found in the provided list
      }
    }

    return recommended;
  }
}
