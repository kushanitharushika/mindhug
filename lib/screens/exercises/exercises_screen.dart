import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/mindhug_logo.dart';
import '../../models/mood.dart';
import '../../models/exercise.dart';
import '../../models/care_item.dart';
import 'widgets/mood_check_in.dart';
import 'widgets/daily_plan_card.dart';
import 'widgets/care_list_widget.dart';
import 'widgets/exercise_library.dart';
import 'exercise_detail_screen.dart'; // Import Detail Screen
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/storage/local_storage.dart';
import '../../services/recommendation_service.dart';
import '../../services/notification_service.dart';
import '../../services/cross_check_service.dart';
import '../../data/mock_exercises.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  Mood? _selectedMood;
  List<Exercise> _todayPlan = [];
  List<CareItem> _careItems = [];
  List<Exercise> _allExercises = [];
  
  // Data from mock_exercises.dart will be used
  final List<Exercise> _repoExercises = mockExercises;

  String _userLevel = "Level 3 - Balanced & Resilient"; // Default
  String? _latestStroopStressLevel;
  List<Exercise> _crossCheckExercises = [];

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
        if (doc.exists) {
           if (doc.data()!.containsKey('latestQuizLevel')) {
             _userLevel = doc.data()!['latestQuizLevel'];
           }
           if (doc.data()!.containsKey('latestStroopStressLevel')) {
             _latestStroopStressLevel = doc.data()!['latestStroopStressLevel'];
           }
        } else {
           // Fallback to local storage if available
           final localData = await LocalStorage.getQuizResult();
           if (localData != null) {
             _userLevel = localData['level'];
           }
        }
      }
    } catch (e) {
      debugPrint("Error loading user level or stroop stress: $e");
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
          CareItem(id: 'c1', title: 'Drink Timer', description: '8 glasses daily for mental wellbeing', reminderTime: 'Every 2 hours', type: 'counter', maxProgress: 8),
          CareItem(id: 'c2', title: 'Screen Break', description: 'Look away from screen for 20s', reminderTime: 'Every 20m'),
          CareItem(id: 'c3', title: 'Posture Check', description: 'Sit up straight', reminderTime: 'Every 30m'),
        ];
      }
      
      // Schedule reminder if Drink Timer is active
      if (_careItems.any((c) => c.title == 'Drink Timer' && !c.isCompleted)) {
        NotificationService().scheduleTwoHourNotification(
          id: 1001, 
          title: "Stay Hydrated 💧", 
          body: "Time for a glass of water to support your mental wellbeing!"
        );
      } else if (_careItems.any((c) => c.title == 'Drink Timer' && c.isCompleted)) {
        NotificationService().cancelNotification(1001); // Cancel if target met
      }
      
      _generateCrossCheckPlan();
    });
  }

  void _generateCrossCheckPlan() {
    if (_latestStroopStressLevel == null) return;

    _crossCheckExercises = CrossCheckService.getRecommendations(
       userLevel: _userLevel, 
       stroopStressLevel: _latestStroopStressLevel!, 
       availableExercises: _repoExercises
    );
  }

  void _onMoodSelected(Mood mood) {
    setState(() {
      _selectedMood = mood;
      _generateSmartPlan(mood);
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
        final match = _findExerciseInRepo(title);
        if (match != null) return match;

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
      }).toList();
      
      // Take top 3 for the "Little Plan"
      _todayPlan = plan.take(3).toList();
      
      // Update Drink Target based on Mood & Plan
      _recalculateDrinkTarget(mood, _todayPlan);
    });
  }

  void _recalculateDrinkTarget(Mood mood, List<Exercise> plan) {
    int target = 8; // Base target
    
    // 1. Mood rules
    if (mood.type == MoodType.stressed || mood.type == MoodType.anxious) {
      target += 1; // +1 for stress/anxiety
    }
    
    // 2. Physical activity rules
    bool hasPhysical = plan.any((ex) => ex.type == ExerciseType.physical);
    if (hasPhysical) {
      target += 1; // +1-2 for exercise, leaning conservative with +1
    }
    
    // Update the CareItem
    setState(() {
      final idx = _careItems.indexWhere((item) => item.title == 'Drink Timer');
      if (idx != -1) {
        // Only update if the logic changed the target
        if (_careItems[idx].maxProgress != target) {
          _careItems[idx] = _careItems[idx].copyWith(
            maxProgress: target,
            description: '$target glasses today 💧',
          );
          LocalStorage.saveCareItems(_careItems);
        }
      }
    });
  }

  Exercise? _findExerciseInRepo(String title) {
    final t = title.toLowerCase();
    try {
      return _repoExercises.firstWhere((e) {
        final r = e.title.toLowerCase();
        
        // 1. Exact match
        if (r == t) return true;
        
        // 2. Comprehensive Fuzzy Matching
        
        // Yoga / Stretching
        if ((t.contains('yoga') || t.contains('stretch') || t.contains('mobility') || t.contains('cat-cow') || t.contains('fold') || t.contains('twist')) && r == 'gentle yoga') return true;
        
        // Walking / Nature
        if ((t.contains('walk') || t.contains('nature') || t.contains('sun')) && r == 'walking') return true;
        
        // Breathing (Specifics first, then general)
        if (t.contains('box') && r == 'box breathing') return true;
        if (t.contains('4-7-8') && r == '4-7-8 breathing') return true;
        if ((t.contains('breath') || t.contains('respira')) && r == 'deep breathing') return true;
        
        // Body Scan / Relaxation
        if ((t.contains('scan') || t.contains('warm')) && r == 'body scan') return true;
        if ((t.contains('muscle') && t.contains('relax')) && r == 'progressive muscle relaxation') return true;
        
        // Grounding
        if ((t.contains('ground') || t.contains('senses')) && r == 'grounding 5-4-3-2-1') return true;
        
        // Journaling / Mental
        if ((t.contains('journal') || t.contains('writ') || t.contains('gratitude') || t.contains('affirmation') || t.contains('reflection') || t.contains('intention')) && r == 'gratitude journaling') return true;
        
        // Physical / Core / Strength
        if ((t.contains('pilates') || t.contains('core') || t.contains('strength') || t.contains('balance') || t.contains('posture')) && r == 'pilates core focus') return true;
        
        // High Energy / Dance / Cardio
        if ((t.contains('dance') || t.contains('cardio') || t.contains('hiit') || t.contains('run') || t.contains('workout') || t.contains('fitness')) && r == 'free dance flow') return true;
        
        // Visualization / Meditation / Calm
        if ((t.contains('visualiz') || t.contains('imagin') || t.contains('meditat') || t.contains('sitting') || t.contains('detox') || t.contains('rest')) && r == 'peaceful visualization') return true;
        
        // Social
        if ((t.contains('social') || t.contains('connect') || t.contains('friend') || t.contains('shar') || t.contains('talk')) && r == 'social connection') return true;
        
        // Planning
        if ((t.contains('plan') || t.contains('goal') || t.contains('task') || t.contains('check-in') || t.contains('prep')) && r == 'goal setting session') return true;
        
        // Music
        if ((t.contains('music') || t.contains('sound') || t.contains('listen') || t.contains('song') || t.contains('playlist') || t.contains('noise')) && r == 'mindful music listening') return true;

        return false;
      });
    } catch (_) {
      return null;
    }
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

  void _updateCareItemProgress(String id, int progress) {
    setState(() {
      final index = _careItems.indexWhere((item) => item.id == id);
      if (index != -1) {
        final item = _careItems[index];
        final newProgress = progress.clamp(0, item.maxProgress);
        final isNowDone = newProgress >= item.maxProgress;
        
        _careItems[index] = item.copyWith(
          currentProgress: newProgress,
          isCompleted: isNowDone,
        );

        // Cancel the water reminder if done
        if (item.title == 'Drink Timer' && isNowDone) {
          NotificationService().cancelNotification(1001);
        } else if (item.title == 'Drink Timer' && !isNowDone) {
          // Re-enable if they undo the action
          NotificationService().scheduleTwoHourNotification(
            id: 1001, 
            title: "Stay Hydrated 💧", 
            body: "Time for a glass of water to support your mental wellbeing!"
          );
        }
      }
    });
    LocalStorage.saveCareItems(_careItems);
  }

  void _navigateToExercise(Exercise exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseDetailScreen(exercise: exercise),
      ),
    );
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
                      onProgressUpdate: _updateCareItemProgress,
                      onAdd: _addCareItem,
                      onDelete: _deleteCareItem,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 2.5 Cross-Check Recommendations
                  if (_crossCheckExercises.isNotEmpty) ...[
                    Row(
                      children: [
                        Text(
                          "Cross-Check Insights",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.psychology, color: AppColors.primary, size: 20),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _crossCheckExercises.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final ex = _crossCheckExercises[index];
                          return GestureDetector(
                            onTap: () => _navigateToExercise(ex),
                            child: Container(
                              width: 200,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceDark : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(ex.duration, style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                                  ),
                                  const Spacer(),
                                  Text(ex.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text(ex.description, style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  
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
                              onTap: () => _navigateToExercise(ex), // Changed to navigation
                              onSkip: () {
                                 setState(() {
                                   _todayPlan.remove(ex);
                                 });
                              },
                            ),
                          )),
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
                    onExerciseTap: (ex) => _navigateToExercise(ex), // Changed to navigation
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
