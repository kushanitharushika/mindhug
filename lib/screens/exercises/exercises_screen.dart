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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/storage/local_storage.dart';
import '../../services/recommendation_service.dart';

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
  
  String _userLevel = "Level 3 - Balanced & Resilient"; // Default

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // 1. Fetch User Level (Firestore -> Local -> Default)
    // ... existing level fetching code ...
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data()!.containsKey('latestQuizLevel')) {
           _userLevel = doc.data()!['latestQuizLevel'];
        } else {
           // Fallback to local storage if available
           final localData = await LocalStorage.getQuizResult();
           if (localData != null) {
             _userLevel = localData['level'];
           }
        }
      }
    } catch (e) {
      debugPrint("Error loading user level: $e");
    }

    // 2. Load Care Items
    final savedCareItems = await LocalStorage.getCareItems();

    // Simulate loading rest
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _allExercises = _repoExercises;
      if (savedCareItems.isNotEmpty) {
        _careItems = savedCareItems;
      } else {
        // Default items if none saved
        _careItems = [
          CareItem(id: 'c1', title: 'Drink Timer', description: 'Drink a glass of water', reminderTime: 'Hourly'),
          CareItem(id: 'c2', title: 'Screen Break', description: 'Look away from screen for 20s', reminderTime: 'Every 20m'),
          CareItem(id: 'c3', title: 'Posture Check', description: 'Sit up straight', reminderTime: 'Every 30m'),
        ];
      }
    });
  }

  void _onMoodSelected(Mood mood) {
    setState(() {
      _selectedMood = mood;
      _generateSmartPlan(mood);
      _selectMusicForMood(mood);
    });
  }

  Future<void> _generateSmartPlan(Mood mood) async {
    // 1. Get Recommendations from "ML" Engine (Async now)
    final recommendedTitles = await RecommendationService.getRecommendations(
      level: _userLevel, 
      mood: mood
    );

    if (!mounted) return;

    setState(() {
      // 2. Map Titles to Exercise Objects (Creating dynamic ones if not in repo)
      List<Exercise> plan = recommendedTitles.map((title) {
        // Find valid exercise in repo
        try {
          return _repoExercises.firstWhere((e) => e.title.toLowerCase() == title.toLowerCase());
        } catch (e) {
          // If not found in repo, create a placeholder dynamic exercise
          return Exercise(
            id: 'dyn_${title.hashCode}',
            title: title,
            description: 'Recommended for your current state.',
            duration: '5-10 mins',
            type: _guessType(title), // Helper to guess type
            minScore: 0, 
            maxScore: 100
          );
        }
      }).toList();
      
      // Take top 3 for the "Little Plan"
      _todayPlan = plan.take(3).toList();
    });
  }
  
  ExerciseType _guessType(String title) {
    final t = title.toLowerCase();
    
    // Breathing
    if (t.contains('breath')) return ExerciseType.breathing;
    
    // Physical
    if (t.contains('yoga') || t.contains('stretch') || t.contains('walk') || t.contains('run') || t.contains('cardio') || t.contains('workout') || t.contains('fitness') || t.contains('pilates') || t.contains('movement') || t.contains('dance')) return ExerciseType.physical;
    
    // Meditation / Mindfulness
    if (t.contains('medita') || t.contains('scan') || t.contains('mindful') || t.contains('awareness')) return ExerciseType.meditation;
    
    // Grounding
    if (t.contains('ground') || t.contains('5-4-3-2-1') || t.contains('senses')) return ExerciseType.grounding;
    
    // Journaling / Writing
    if (t.contains('journal') || t.contains('writ') || t.contains('list') || t.contains('note')) return ExerciseType.journaling;
    
    // Music / Audio
    if (t.contains('music') || t.contains('sound') || t.contains('listen') || t.contains('song') || t.contains('playlist')) return ExerciseType.music;
    
    // Visualization
    if (t.contains('visualiz') || t.contains('imagin')) return ExerciseType.visualization;
    
    // Social
    if (t.contains('social') || t.contains('connect') || t.contains('friend') || t.contains('shar')) return ExerciseType.social;
    
    // Planning
    if (t.contains('plan') || t.contains('goal') || t.contains('task') || t.contains('check-in')) return ExerciseType.planning;
    
    return ExerciseType.other;
  }

  void _selectMusicForMood(Mood mood) {
    // Map MoodType to MusicMood
    MusicMood targetMusicMood;
    switch (mood.type) {
      case MoodType.stressed:
      case MoodType.sad:
      case MoodType.calm:
      case MoodType.anxious:
      case MoodType.tired:
        targetMusicMood = MusicMood.calm;
        break;
      case MoodType.energetic:
      case MoodType.happy:
        targetMusicMood = MusicMood.uplifting;
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

  void _addCareItem(String title) {
    setState(() {
      _careItems.add(CareItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: '',
      ));
    });
    LocalStorage.saveCareItems(_careItems);
  }

  void _deleteCareItem(String id) {
    setState(() {
      _careItems.removeWhere((item) => item.id == id);
    });
    LocalStorage.saveCareItems(_careItems);
  }

  void _toggleCareItem(String id, bool val) {
    setState(() {
      final index = _careItems.indexWhere((item) => item.id == id);
      if (index != -1) {
        _careItems[index] = _careItems[index].copyWith(isCompleted: val);
      }
    });
    LocalStorage.saveCareItems(_careItems); // Save state
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
                  
                  // 2. Daily Care
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
                      onAdd: _addCareItem,
                      onDelete: _deleteCareItem,
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // 3. Your Plan
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

                  // 4. Explore Library
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
      case ExerciseType.journaling: return Icons.edit_note;
      case ExerciseType.music: return Icons.music_note;
      case ExerciseType.visualization: return Icons.visibility;
      case ExerciseType.social: return Icons.people;
      case ExerciseType.planning: return Icons.event_note;
      default: return Icons.play_circle_outline;
    }
  }
}

extension MoodTypeHelper on MoodType {
  // Helper to group moods for logic if needed
  static const stressOrSad = [MoodType.stressed, MoodType.sad, MoodType.tired];
}
