enum ExerciseType {
  breathing,
  physical,
  meditation,
  grounding,
  journaling,
  music,
  visualization,
  social,
  planning,
  other
}

class ExerciseStep {
  final String text;
  final String? imageUrl;
  
  ExerciseStep({required this.text, this.imageUrl});
}

class Exercise {
  final String id;
  final String title;
  final String description;
  final String duration; // e.g., "5 mins"
  final ExerciseType type;
  final String? videoUrl;
  final String? imageUrl;
  final int minScore; // For mental health score filtering
  final int maxScore;
  final List<ExerciseStep> steps;
  final String benefits;

  Exercise({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.type,
    this.videoUrl,
    this.imageUrl,
    this.minScore = 0,
    this.maxScore = 100,
    List<dynamic> steps = const [], // Accepts String or ExerciseStep
    this.benefits = '',
  }) : steps = steps.map((s) {
          if (s is ExerciseStep) return s;
          if (s is Map) {
             return ExerciseStep(
               text: s['text'] ?? '', 
               imageUrl: s['imageUrl']
             );
          }
          return ExerciseStep(text: s.toString());
        }).toList();

  factory Exercise.fromMap(Map<String, dynamic> map, String id) {
    return Exercise(
      id: id,
      title: map['title'] ?? '',
      description: map['desc'] ?? '',
      duration: map['duration'] ?? '5 mins',
      type: _parseType(map['type']),
      videoUrl: map['videoUrl'],
      imageUrl: map['imageUrl'],
      minScore: map['minScore'] ?? 0,
      maxScore: map['maxScore'] ?? 100,
      steps: (map['steps'] as List<dynamic>?)?.map((s) {
         if (s is Map) {
           return ExerciseStep(
             text: s['text'] ?? '', 
             imageUrl: s['imageUrl']
           );
         }
         return s.toString(); // Handled by constructor
      }).toList() ?? [],
      benefits: map['benefits'] ?? '',
    );
  }
  
  static ExerciseType _parseType(String? typeStr) {
     if (typeStr == null) return ExerciseType.other;
     switch (typeStr.toLowerCase()) {
       case 'breathing': return ExerciseType.breathing;
       case 'physical': return ExerciseType.physical;
       case 'meditation': return ExerciseType.meditation;
       case 'grounding': return ExerciseType.grounding;
       case 'journaling': return ExerciseType.journaling;
       case 'music': return ExerciseType.music;
       case 'visualization': return ExerciseType.visualization;
       case 'social': return ExerciseType.social;
       case 'planning': return ExerciseType.planning;
       default: return ExerciseType.other;
     }
  }
}
