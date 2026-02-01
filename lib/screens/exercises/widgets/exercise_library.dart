import 'package:flutter/material.dart';
import '../../../models/exercise.dart';
import '../../../core/theme/app_colors.dart';

class ExerciseLibraryWidget extends StatelessWidget {
  final List<Exercise> exercises;
  final Function(Exercise) onExerciseTap;

  const ExerciseLibraryWidget({
    super.key,
    required this.exercises,
    required this.onExerciseTap,
  });

  @override
  Widget build(BuildContext context) {
     final isDark = Theme.of(context).brightness == Brightness.dark;

     if (exercises.isEmpty) {
       return Center(
         child: Padding(
           padding: const EdgeInsets.all(24.0),
           child: Text("No exercises found", style: TextStyle(color: Colors.grey)),
         ),
       );
     }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
             color: isDark ? AppColors.surfaceDark : Colors.white,
             borderRadius: BorderRadius.circular(16),
               boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconForType(exercise.type),
                color: Colors.blue.shade400,
                size: 22,
              ),
            ),
            title: Text(
              exercise.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                 color: isDark ? Colors.white : const Color(0xFF2D3142),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                children: [
                   Text(
                    exercise.duration,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 8),
                  Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.grey.shade400, shape: BoxShape.circle)),
                   const SizedBox(width: 8),
                    Text(
                    exercise.type.name.toUpperCase(),
                     style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            onTap: () => onExerciseTap(exercise),
            trailing: Icon(Icons.chevron_right, color: Colors.grey.shade300),
          ),
        );
      },
    );
  }

  IconData _getIconForType(ExerciseType type) {
    switch (type) {
      case ExerciseType.breathing: return Icons.air;
      case ExerciseType.physical: return Icons.fitness_center;
      case ExerciseType.meditation: return Icons.self_improvement;
      case ExerciseType.grounding: return Icons.nature;
      default: return Icons.play_circle_outline;
    }
  }
}
