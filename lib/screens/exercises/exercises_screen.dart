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
import 'exercise_detail_screen.dart'; // Import Detail Screen
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/storage/local_storage.dart';
import '../../services/recommendation_service.dart';
import '../../services/notification_service.dart';

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
    Exercise(
      id: '1', 
      title: 'Deep Breathing', 
      description: 'Slow, deep breaths to calm down.', 
      duration: '3 mins', 
      type: ExerciseType.breathing, 
      minScore: 0, 
      maxScore: 100,
      benefits: "Deep breathing activates your parasympathetic nervous system, effectively acting as a 'brake' for stress. It lowers cortisol levels, reduces blood pressure, and sends a signal to your brain that you are safe.",
      steps: [
        "Find a comfortable sitting position with your back straight.",
        "Place one hand on your chest and the other on your belly.",
        "Inhale deeply through your nose for 4 seconds, feeling your belly expand.",
        "Hold your breath gently for 2 seconds.",
        "Exhale slowly through your mouth for 6 seconds, like you're blowing out a candle.",
        "Repeat this cycle, focusing only on the rhythm of your breath."
      ]
    ),
    Exercise(
      id: '2', 
      title: 'Box Breathing', 
      description: 'Inhale 4s, hold 4s, exhale 4s, hold 4s.', 
      duration: '4 mins', 
      type: ExerciseType.breathing, 
      minScore: 0, 
      maxScore: 100,
      benefits: "Used by Navy SEALs, this technique heightens performance and concentration while being a powerful stress reliever. It regulates your autonomic nervous system and brings your mind to the present moment.",
      steps: [
        "Inhale through your nose for a count of 4.",
        "Hold that breath inside for a count of 4.",
        "Exhale smoothly through your mouth for a count of 4.",
        "Hold your lungs empty for a count of 4.",
        "Imagine tracing the sides of a square with each step.",
        "Continue for 4 minutes to reset your mind."
      ]
    ),
    Exercise(
      id: '3', 
      title: 'Body Scan', 
      description: 'Focus on each part of your body.', 
      duration: '10 mins', 
      type: ExerciseType.meditation, 
      minScore: 20, 
      maxScore: 80,
      benefits: "Reconnects your mind with your physical self, helping you identify where you hold tension. This practice reduces physical symptoms of stress and promotes a deep sense of relaxation.",
      steps: [
        "Lie down or sit comfortably and close your eyes.",
        "Take a few deep breaths to center yourself.",
        "Bring your attention to your toes. Notice any sensation there.",
        "Slowly move your focus up to your ankles, calves, and knees.",
        "Continue moving up through your thighs, hips, and stomach.",
        "Notice any tension and imagine releasing it with each exhale.",
        "Finish by focusing on your face, relaxing your jaw and forehead."
      ]
    ),
    Exercise(
      id: '4', 
      title: 'Quick Stretch', 
      description: 'Release tension in neck and shoulders.', 
      duration: '5 mins', 
      type: ExerciseType.physical, 
      minScore: 0, 
      maxScore: 100,
      benefits: "Physical tension often accumulates in the neck and shoulders during stress. Gentle stretching releases this stored energy, improves circulation to the brain, and provides an immediate mood boost.",
      steps: [
        "Sit or stand tall with your shoulders relaxed.",
        "Gently tilt your right ear toward your right shoulder. Hold for 15s.",
        "Return to center and repeat on the left side.",
        "Slowly roll your shoulders backward 5 times.",
        "Roll your shoulders forward 5 times.",
        "Clasp your hands behind your back and gently lift to open your chest.",
        "Shake out your hands and arms to release any lingering tension."
      ]
    ),
    Exercise(
      id: '5', 
      title: 'Jumping Jacks', 
      description: 'Get your heart rate up.', 
      duration: '2 mins', 
      type: ExerciseType.physical, 
      minScore: 50, 
      maxScore: 100,
      benefits: "A quick burst of cardio releases endorphins, the body's natural 'feel-good' chemicals. It breaks the cycle of lethargy and instantly boosts your energy and mental clarity.",
      steps: [
        "Stand upright with your legs together and arms at your sides.",
        "Bend your knees slightly and jump into the air.",
        "Spread your legs shoulder-width apart and stretch your arms out and over your head.",
        "Jump back to the starting position.",
        "Find a steady rhythm and keep going!",
        "Smile while you do it – it actually helps!"
      ]
    ),
    Exercise(
      id: '6', 
      title: 'Grounding 5-4-3-2-1', 
      description: 'Engage your five senses.', 
      duration: '5 mins', 
      type: ExerciseType.grounding, 
      minScore: 0, 
      maxScore: 50,
      benefits: "This is a classic anxiety-reduction technique. By engaging your five senses, you pull your brain out of spiraling thoughts and anchor yourself firmly in the present reality.",
      steps: [
        "Look around and name 5 things you can see.",
        "Notice 4 things you can physically feel (feet on floor, clothes on skin).",
        "Listen for 3 distinct sounds tailored to your environment.",
        "Identify 2 things you can smell (or recall 2 favorite scents).",
        "Name 1 thing you can taste (or a taste you like)."
      ]
    ),
    Exercise(
      id: '7', 
      title: 'Gratitude Journaling', 
      description: 'Write down 3 things you are grateful for.', 
      duration: '5 mins', 
      type: ExerciseType.other, 
      minScore: 30, 
      maxScore: 100,
      benefits: "Shift your focus from what's missing to what's present. Practicing gratitude is scientifically proven to improve sleep, mood, and immunity by rewiring your brain to scan for the positive.",
      steps: [
        "Grab a pen and paper or open a notes app.",
        "Take a moment to reflect on your day or week.",
        "Write down 3 things that made you smile or feel safe.",
        "They can be small: a warm coffee, a kind text, or the sunshine.",
        "Briefly write *why* you are grateful for each one.",
        "Read them back to yourself and feel the appreciation."
      ]
    ),
    Exercise(
      id: '8',
      title: 'Gentle Yoga',
      description: 'Slow movements to release body tension.',
      duration: '10 mins',
      type: ExerciseType.physical,
      minScore: 0,
      maxScore: 80,
      benefits: "Combines physical movement with breath awareness to lower cortisol levels. It releases stored physical tension, improves flexibility, and calms the nervous system.",
      steps: [
        "Start in Child's Pose: Kneel, sit back on heels, stretch arms forward.",
        "Move to Cat-Cow: On hands and knees, arch back (Cow) then round spine (Cat).",
        "Transition to Downward Dog: Lift hips high, pedal out your feet.",
        "Step forward into a gentle Forward Fold, letting your head hang heavy.",
        "Slowly roll up to standing and reach arms overhead.",
        "Finish with 1 minute of Savasana (corpse pose) lying flat on your back."
      ]
    ),
    Exercise(
      id: '9',
      title: 'Walking',
      description: 'A brisk walk to clear your mind.',
      duration: '15 mins',
      type: ExerciseType.physical,
      minScore: 0,
      maxScore: 100,
      benefits: "Walking, especially in nature, reduces rumination (repetitive negative thoughts). The rhythmic movement and optical flow processing help quiet the brain's detailed-oriented centers.",
      steps: [
        "Put on comfortable shoes.",
        "Step outside or find a clear path indoors.",
        "Start at a comfortable pace, noticing the sensation of your feet hitting the ground.",
        "Focus your eyes on the horizon or trees, rather than looking down.",
        "If thoughts intrude, gently bring your focus back to your footsteps.",
        "Pick up the pace slightly for the last 5 minutes to boost endorphins."
      ]
    ),
    Exercise(
      id: '10',
      title: '4-7-8 Breathing',
      description: 'Inhale 4s, hold 7s, exhale 8s.',
      duration: '5 mins',
      type: ExerciseType.breathing,
      minScore: 0,
      maxScore: 100,
      benefits: "A natural tranquilizer for the nervous system. The long exhale activates the vagus nerve, signaling your body to rest and digest, making it perfect for anxiety or sleep.",
      steps: [
        "Exhale completely through your mouth.",
        "Close your mouth and inhale quietly through your nose to a count of 4.",
        "Hold your breath for a count of 7.",
        "Exhale completely through your mouth, making a whoosh sound to a count of 8.",
        "This is one breath. Repeat the cycle 3 more times.",
        "Let your breath return to natural rhythm."
      ]
    ),
    Exercise(
      id: '11',
      title: 'Progressive Muscle Relaxation',
      description: 'Tense and relax muscle groups.',
      duration: '10 mins',
      type: ExerciseType.grounding,
      minScore: 0,
      maxScore: 60,
      benefits: "Teaches you to recognize the difference between tension and relaxation. By systematically tensing and releasing muscles, you can physically force your body into a state of calm.",
      steps: [
        "Lie down comfortably.",
        "Start with your feet: curl your toes tight for 5s, then release instantly.",
        "Move to calves: flex them hard for 5s, then let go.",
        "Continue up to your thighs, buttocks, and stomach.",
        "Clench your hands into fists, shrug shoulders to ears, then drop them.",
        "Scrunch your face tight, then relax your jaw and eyes.",
        "Feel the wave of heaviness and relaxation wash over you."
      ]
    ),
    Exercise(
      id: '12',
      title: 'Pilates Core Focus',
      description: 'Strengthen core and improve posture.',
      duration: '15 mins',
      type: ExerciseType.physical,
      minScore: 0,
      maxScore: 100,
      benefits: "Pilates builds a strong foundation for movement. It improves core stability, aligns the spine, and connects deep abdominal muscles, which boosts overall confidence and physical resilience.",
      steps: [
        "Lie on your back, knees bent, feet flat on the floor.",
        "Engage your core by drawing your belly button to your spine.",
        "Lift knees to tabletop position (90 degrees).",
        "Perform 'The Hundred': Pump arms by sides while breathing rhythmically.",
        "Extend legs to 45 degrees if comfortable.",
        "Transition to 'Single Leg Stretch', alternating hugging knees.",
        "Finish with a gentle spine stretch forward."
      ]
    ),
    Exercise(
      id: '13',
      title: 'Free Dance Flow',
      description: 'Move your body to the rhythm.',
      duration: '5 mins',
      type: ExerciseType.physical,
      minScore: 50,
      maxScore: 100,
      benefits: "Dancing releases dopamine and endorphins. Moving freely without judgment helps release trapped emotions, boosts creativity, and provides a powerful outlet for stress energy.",
      steps: [
        "Put on your favorite upbeat song.",
        "Stand in a clear space.",
        "Start by just swaying your hips.",
        "Let your arms move however they want.",
        "Don't worry about looking cool—focus on how it feels.",
        "Shake out your whole body at the end to release tension."
      ]
    ),
    Exercise(
      id: '14',
      title: 'Peaceful Visualization',
      description: 'Imagine a safe, calm place.',
      duration: '10 mins',
      type: ExerciseType.visualization,
      minScore: 0,
      maxScore: 100,
      benefits: "Visualization tricks the brain into believing you are actually in a calm environment. This mental escape lowers heart rate and blood pressure, providing a deep psychological rest.",
      steps: [
        "Find a quiet comfortable spot and close your eyes.",
        "Imagine a place where you feel perfectly safe (beach, forest, room).",
        "What do you see? (Colors, light, objects)",
        "What do you hear? (Waves, birds, silence)",
        "What do you smell? (Salt air, pine, rain)",
        "Stay in this place, soaking up the feeling of safety.",
        "Slowly bring yourself back when you are ready."
      ]
    ),
    Exercise(
      id: '15',
      title: 'Social Connection',
      description: 'Reach out to someone you trust.',
      duration: '10 mins',
      type: ExerciseType.social,
      minScore: 30,
      maxScore: 80,
      benefits: "Social connection triggers oxytocin, the 'love hormone'. Even a brief text or call can reduce feelings of isolation and remind you that you are supported and valued.",
      steps: [
        "Scroll through your contacts.",
        "Choose one friend or family member you haven't spoken to lately.",
        "Send a simple text: 'Thinking of you' or 'How are you?'.",
        "Or, make a quick 5-minute phone call.",
        "Focus on listening to their voice.",
        "Allow yourself to feel connected and less alone."
      ]
    ),
    Exercise(
      id: '16',
      title: 'Goal Setting Session',
      description: 'Plan your next small steps.',
      duration: '10 mins',
      type: ExerciseType.planning,
      minScore: 40,
      maxScore: 100,
      benefits: "Breaking undefined worries into concrete tasks reduces anxiety. Planning gives you a sense of control and agency, turning a mountain of stress into climbable steps.",
      steps: [
        "Open a notebook or your phone's calendar.",
        "Identify one main goal or stressor for the week.",
        "Break it down into 3 tiny, manageable steps.",
        "Schedule exactly when you will do step 1.",
        "Write down a potential obstacle and how you'll handle it.",
        "Close the book and trust the plan."
      ]
    ),
    Exercise(
      id: '17',
      title: 'Mindful Music Listening',
      description: 'Truly listen to a song.',
      duration: '5 mins',
      type: ExerciseType.music,
      minScore: 0,
      maxScore: 100,
      benefits: "Active listening serves as a meditation anchor. Music directly impacts the limbic system (emotional brain), capable of shifting your mood faster than almost any other stimulus.",
      steps: [
        "Put on headphones for the best experience.",
        "Choose a song that matches the mood you WANT to feel.",
        "Close your eyes and press play.",
        "Try to pick out individual instruments (bass, drums, melody).",
        "Notice how the music physically feels in your ears.",
        "If your mind wanders, come back to the bassline."
      ]
    ),
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
