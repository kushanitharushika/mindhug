import '../models/exercise.dart';
import '../models/mood.dart';

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
    Mood? mood,
  }) {
    if (availableExercises.isEmpty) return [];

    final bool isLowStress = isManagingWell(userLevel);

    // We now work with indices into the availableExercises list
    // to avoid brittle hardcoded ID matching.
    final int total = availableExercises.length;

    // Helper: safely map a fraction (0.0–1.0) to a list index
    int idx(double fraction) => (fraction * (total - 1)).round().clamp(0, total - 1);

    // Define pools as fractions of the full list so they always resolve correctly
    List<int> pool = [];

    if (!isLowStress && stroopStressLevel == "Stressed") {
      // Both indicate high stress — grounding & calming exercises (early in list)
      pool = [idx(0.0), idx(0.1), idx(0.2), idx(0.5), idx(0.7), idx(0.8)];
    } else if (isLowStress && stroopStressLevel == "Stressed") {
      // Subconscious stress — resetting & relaxation
      pool = [idx(0.2), idx(0.5), idx(0.6), idx(0.7), idx(0.85), idx(0.95)];
    } else if (!isLowStress && stroopStressLevel == "Calm") {
      // Quiz says stressed but stroop says calm — reflective & mood-boosting
      pool = [idx(0.25), idx(0.45), idx(0.5), idx(0.75), idx(0.8), idx(0.95)];
    } else {
      // Both good — moderate activity / maintenance
      pool = [idx(0.3), idx(0.55), idx(0.65), idx(0.75), idx(0.85), idx(0.9)];
    }

    if (mood != null) {
      List<int> moodPool = [];
      switch (mood.type) {
        case MoodType.anxious:
        case MoodType.stressed:
          moodPool = [idx(0.0), idx(0.1), idx(0.4), idx(0.7), idx(0.85)];
          break;
        case MoodType.sad:
        case MoodType.tired:
          moodPool = [idx(0.2), idx(0.45), idx(0.5), idx(0.8), idx(0.95)];
          break;
        case MoodType.happy:
        case MoodType.energetic:
          moodPool = [idx(0.3), idx(0.55), idx(0.65), idx(0.75), idx(0.9)];
          break;
        case MoodType.calm:
        case MoodType.neutral:
          moodPool = [idx(0.25), idx(0.5), idx(0.55), idx(0.65), idx(0.85)];
          break;
      }
      // Combine and deduplicate
      pool = {...moodPool, ...pool}.toList();
    }

    pool.shuffle();
    final selectedIndices = pool.take(3).toSet(); // deduplicate in case of overlaps

    return selectedIndices
        .map((i) => availableExercises[i])
        .toList();
  }
}
