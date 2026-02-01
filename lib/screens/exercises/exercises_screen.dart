import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/mindhug_logo.dart';
import '../../models/mood.dart';
import '../../models/exercise.dart';
import '../../models/music_track.dart';
import '../../models/care_item.dart';
import 'widgets/mood_check_in.dart';
import 'widgets/daily_plan_card.dart';
import 'widgets/music_player_widget.dart';
import 'widgets/care_list_widget.dart';
import 'widgets/exercise_library.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  Mood? _selectedMood;
  List<Exercise> _todayPlan = [];
  MusicTrack? _currentTrack;
  List<CareItem> _careItems = [];
  List<Exercise> _allExercises = [];
  
  // Mock Data Repositories (Ideally these would be in a service)
  final List<Exercise> _repoExercises = [
    Exercise(id: '1', title: 'Deep Breathing', description: 'Slow, deep breaths to calm down.', duration: '3 mins', type: ExerciseType.breathing, minScore: 0, maxScore: 100),
    Exercise(id: '2', title: 'Box Breathing', description: 'Inhale 4s, hold 4s, exhale 4s, hold 4s.', duration: '4 mins', type: ExerciseType.breathing, minScore: 0, maxScore: 100),
    Exercise(id: '3', title: 'Body Scan', description: 'Focus on each part of your body.', duration: '10 mins', type: ExerciseType.meditation, minScore: 20, maxScore: 80),
    Exercise(id: '4', title: 'Quick Stretch', description: 'Release tension in neck and shoulders.', duration: '5 mins', type: ExerciseType.physical, minScore: 0, maxScore: 100),
    Exercise(id: '5', title: 'Jumping Jacks', description: 'Get your heart rate up.', duration: '2 mins', type: ExerciseType.physical, minScore: 50, maxScore: 100),
    Exercise(id: '6', title: 'Grounding 5-4-3-2-1', description: 'Engage your five senses.', duration: '5 mins', type: ExerciseType.grounding, minScore: 0, maxScore: 50),
    Exercise(id: '7', title: 'Gratitude Journaling', description: 'Write down 3 things you are grateful for.', duration: '5 mins', type: ExerciseType.other, minScore: 30, maxScore: 100),
  ];

  final List<MusicTrack> _repoMusic = [
    MusicTrack(id: 'm1', title: 'Forest Rain', artist: 'Nature Sounds', url: '', mood: MusicMood.calm, duration: '10:00'),
    MusicTrack(id: 'm2', title: 'Upbeat Lo-Fi', artist: 'Chill Beats', url: '', mood: MusicMood.uplifting, duration: '3:00'),
    MusicTrack(id: 'm3', title: 'Ocean Waves', artist: 'Deep Sleep', url: '', mood: MusicMood.sleep, duration: '15:00'),
    MusicTrack(id: 'm4', title: 'Piano Focus', artist: 'Study Time', url: '', mood: MusicMood.focus, duration: '45:00'),
  ];
  
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Simulate loading
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _allExercises = _repoExercises;
      _careItems = [
        CareItem(id: 'c1', title: 'Drink Timer', description: 'Drink a glass of water', reminderTime: 'Hourly'),
        CareItem(id: 'c2', title: 'Screen Break', description: 'Look away from screen for 20s', reminderTime: 'Every 20m'),
        CareItem(id: 'c3', title: 'Posture Check', description: 'Sit up straight', reminderTime: 'Every 30m'),
      ];
    });
  }

  void _onMoodSelected(Mood mood) {
    setState(() {
      _selectedMood = mood;
      _generateLittlePlan(mood);
      _selectMusicForMood(mood);
    });
  }

  void _generateLittlePlan(Mood mood) {
    // Simple logic: Pick 1 breathing, 1 physical based on mood
    // For "Sad" or "Stressed", prioritize calming/grounding
    // For "Happy" or "Energetic", prioritize physical/other
    
    List<Exercise> plan = [];
    
    if (MoodTypeHelper.stressOrSad.contains(mood.type)) { // pseudo-grouping
       plan.add(_repoExercises.firstWhere((e) => e.type == ExerciseType.breathing, orElse: () => _repoExercises[0]));
       plan.add(_repoExercises.firstWhere((e) => e.type == ExerciseType.grounding || e.type == ExerciseType.meditation, orElse: () => _repoExercises[2]));
    } else if (mood.type == MoodType.energetic || mood.type == MoodType.happy) {
       plan.add(_repoExercises.firstWhere((e) => e.type == ExerciseType.physical, orElse: () => _repoExercises[4]));
       plan.add(_repoExercises.firstWhere((e) => e.type == ExerciseType.other, orElse: () => _repoExercises[6]));
    } else {
       // Default mix
       plan.add(_repoExercises.firstWhere((e) => e.type == ExerciseType.breathing, orElse: () => _repoExercises[1]));
       plan.add(_repoExercises.firstWhere((e) => e.type == ExerciseType.physical, orElse: () => _repoExercises[3]));
    }
    
    _todayPlan = plan;
  }

  void _selectMusicForMood(Mood mood) {
    // Map MoodType to MusicMood
    MusicMood targetMusicMood;
    switch (mood.type) {
      case MoodType.stressed:
      case MoodType.sad:
      case MoodType.calm:
        targetMusicMood = MusicMood.calm;
        break;
      case MoodType.energetic:
      case MoodType.happy:
        targetMusicMood = MusicMood.uplifting;
        break;
      case MoodType.tired:
        targetMusicMood = MusicMood.sleep;
        break;
      default:
        targetMusicMood = MusicMood.focus;
    }
    
    try {
      _currentTrack = _repoMusic.firstWhere((m) => m.mood == targetMusicMood);
    } catch (_) {
      _currentTrack = _repoMusic.first;
    }
  }

  void _toggleCareItem(String id, bool val) {
    setState(() {
      final index = _careItems.indexWhere((item) => item.id == id);
      if (index != -1) {
        _careItems[index] = _careItems[index].copyWith(isCompleted: val);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;

    return Scaffold(
      extendBodyBehindAppBar: true, 
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF121212), Color(0xFF000000)],
                )
              : AppColors.bgGradient,
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverAppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent, // Transparent for gradient
                floating: true,
                elevation: 0,
                toolbarHeight: 70,
                title: Row(
                  children: [
                    MindHugLogo(size: 32),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 10),
                  
                  // 1. Mood Check-in
                  MoodCheckIn(
                    selectedMood: _selectedMood,
                    onMoodSelected: _onMoodSelected,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 2. Today's Little Plan
                  if (_selectedMood != null) ...[
                    FadeTransition(
                      opacity: const AlwaysStoppedAnimation(1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Your Plan",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _selectedMood!.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "Based on ${_selectedMood!.label}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedMood!.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          ..._todayPlan.map((ex) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: DailyPlanCard(
                              title: ex.title,
                              description: "${ex.duration} • ${ex.type.name.toUpperCase()}",
                              icon: _getIconForType(ex.type),
                              color: _selectedMood!.color,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Starting ${ex.title}...")));
                              },
                              onSkip: () {
                                 setState(() {
                                   _todayPlan.remove(ex);
                                 });
                              },
                            ),
                          )),
                          
                          if (_currentTrack != null) ...[
                             const SizedBox(height: 12),
                             MusicPlayerWidget(track: _currentTrack!),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // 3. Care List
                  Text(
                    "Daily Care",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                         BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CareListWidget(
                      items: _careItems,
                      onToggle: _toggleCareItem,
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // 4. Exercise Library
                  Text(
                    "Explore Library",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                   const SizedBox(height: 16),
                  ExerciseLibraryWidget(
                    exercises: _allExercises,
                    onExerciseTap: (ex) {
                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Selected ${ex.title}")));
                    },
                  ),
                  const SizedBox(height: 100), // Bottom padding for nav bar
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
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

extension MoodTypeHelper on MoodType {
  // Helper to group moods for logic if needed
  static const stressOrSad = [MoodType.stressed, MoodType.sad, MoodType.tired];
}
