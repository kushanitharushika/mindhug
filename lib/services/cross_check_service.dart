import 'dart:math';
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

  /// Returns a filtered sub-list of exercises whose type is in [types].
  static List<Exercise> _byTypes(
      List<Exercise> exercises, List<ExerciseType> types) {
    return exercises.where((e) => types.contains(e.type)).toList();
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

    List<Exercise> pool;

    if (!isLowStress && stroopStressLevel == "Stressed") {
      // Both indicate high stress → grounding & calming exercises
      pool = _byTypes(availableExercises, [
        ExerciseType.breathing,
        ExerciseType.meditation,
        ExerciseType.grounding,
      ]);
    } else if (isLowStress && stroopStressLevel == "Stressed") {
      // Subconscious stress → resetting & relaxation
      pool = _byTypes(availableExercises, [
        ExerciseType.meditation,
        ExerciseType.grounding,
        ExerciseType.visualization,
        ExerciseType.journaling,
        ExerciseType.music,
      ]);
    } else if (!isLowStress && stroopStressLevel == "Calm") {
      // Quiz says stressed but stroop says calm → reflective & mood-boosting
      pool = _byTypes(availableExercises, [
        ExerciseType.visualization,
        ExerciseType.journaling,
        ExerciseType.social,
        ExerciseType.planning,
        ExerciseType.music,
        ExerciseType.other,
      ]);
    } else {
      // Both calm/low-stress → moderate activity / maintenance
      pool = _byTypes(availableExercises, [
        ExerciseType.physical,
        ExerciseType.social,
        ExerciseType.planning,
      ]);
    }

    if (mood != null) {
      List<ExerciseType> moodTypes;
      switch (mood.type) {
        case MoodType.anxious:
        case MoodType.stressed:
          moodTypes = [ExerciseType.breathing, ExerciseType.grounding, ExerciseType.meditation];
          break;
        case MoodType.sad:
        case MoodType.tired:
          moodTypes = [ExerciseType.meditation, ExerciseType.visualization, ExerciseType.music, ExerciseType.social];
          break;
        case MoodType.happy:
        case MoodType.energetic:
          moodTypes = [ExerciseType.physical, ExerciseType.social, ExerciseType.planning];
          break;
        case MoodType.calm:
        case MoodType.neutral:
          moodTypes = [ExerciseType.meditation, ExerciseType.visualization, ExerciseType.journaling];
          break;
      }
      final moodPool = _byTypes(availableExercises, moodTypes);
      // Merge and deduplicate by id
      final seen = <String>{};
      pool = [...pool, ...moodPool]
          .where((e) => seen.add(e.id))
          .toList();
    }

    // Fallback: if pool is still empty, use entire list
    if (pool.isEmpty) pool = List.of(availableExercises);

    pool.shuffle(Random());
    return pool.take(3).toList();
  }
}

