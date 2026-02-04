import 'package:flutter/material.dart';
import '../../core/storage/local_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/mindhug_logo.dart';
import '../profile/profile_screen.dart';
import '../quiz/mental_health_quiz.dart';
import '../exercises/exercises_screen.dart';
import '../journal/journal_screen.dart';
import '../chatbot/melo_chat_screen.dart';
import '../../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _name = "Friend";
  String _level = "Not Checked";
  String? _avatarPath;
  int _score = 0;
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  final NotificationService _notificationService = NotificationService();
  


  @override
  void initState() {
    super.initState();
    _notificationService.init();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      String name = "Friend";
      
      final savedScore = await LocalStorage.getQuizScore();
      final savedLevel = await LocalStorage.getMentalHealthLevel();
      List<Map<String, dynamic>> history = await LocalStorage.getQuizHistory();
      
      int displayScore = savedScore;
      String displayLevel = savedLevel ?? "Not Checked";

      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          name = data['Name'] ?? "Friend";
          
          // Use Firestore data if available (cloud sync)
          if (data.containsKey('latestQuizScore')) {
             displayScore = data['latestQuizScore'];
             displayLevel = data['latestQuizLevel'] ?? displayLevel;
          }
           // Load avatar if available
          if (data.containsKey('Avatar')) {
             _avatarPath = data['Avatar'];
          } else {
             _avatarPath = user.photoURL;
          }

          // Fetch History from 'quiz_history' root collection
          try {
             final historySnapshot = await FirebaseFirestore.instance
                 .collection('quiz_history')
                 .where('userId', isEqualTo: user.uid)
                 .orderBy('timestamp', descending: true)
                 .limit(20)
                 .get();

             if (historySnapshot.docs.isNotEmpty) {
               history = historySnapshot.docs.map((doc) {
                 final data = doc.data();
                 // Map user's schema to UI expectation
                 return {
                   'score': int.tryParse(data['quizscore'].toString()) ?? 0,
                   'level': data['quizlevel'] ?? 'Unknown',
                   'date': data['quizdate'] ?? DateTime.now().toIso8601String(),
                 };
               }).toList();
             }
          } catch (e) {
             debugPrint("Error fetching history: $e");
          }
        }
      }

      if (mounted) {
        setState(() {
          _name = name;
          // Extract first name
          if (_name.contains(' ')) {
            _name = _name.split(' ')[0];
          }
          _score = displayScore;
          _level = displayLevel;
          _history = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading home data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  String _getDateString() {
    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final weekdays = [
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
    ];
    return "${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}";
  }

  Color _getMoodColor() {
    if (_score >= 40) return Colors.teal.shade600;
    if (_score >= 32) return Colors.blue.shade600;
    if (_score >= 24) return Colors.amber.shade600;
    if (_score > 0) return Colors.deepOrange.shade400;
    return Colors.grey; // Not checked
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subTextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        toolbarHeight: 90,
        elevation: 0,
        title: const MindHugLogo(size: 40),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () async {
               // Navigate to Profile via BottomNav convention or direct push
               // For now, let's push strictly for the avatar action
               await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
               // Reload data when returning in case profile changed
               _loadData();
            },
            icon: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              backgroundImage: _avatarPath != null 
                  ? NetworkImage(_avatarPath!) 
                  : null,
              child: _avatarPath == null 
                ? const Icon(Icons.person, color: AppColors.primary, size: 20)
                : null,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
          children: [
            // Greeting Section
            Text(
              _getDateString().toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
                color: subTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  _getGreeting(),
                  style: TextStyle(
                    fontSize: 24,
                    color: subTextColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
            
            // Hero Mood Card
            const SizedBox(height: 6),
            const SizedBox(height: 6),
            

            const SizedBox(height: 32),

            _buildMoodCard(isDark),

            const SizedBox(height: 32),

            // Monthly Progress Header
            const Text(
              "Monthly Mental Health",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildMonthlyProgress(isDark),

            const SizedBox(height: 32),

            // Daily Quote
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                   if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                ],
                border: isDark ? Border.all(color: Colors.white10) : null,
              ),
              child: Column(
                children: [
                  const Icon(Icons.format_quote_rounded, color: AppColors.primary, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    "You don't have to control your thoughts. You just have to stop letting them control you.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "- Dan Millman",
                    style: TextStyle(
                      fontSize: 12,
                      color: subTextColor,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildMoodCard(bool isDark) {
    bool hasCheckedIn = _score > 0;
    Color moodColor = _getMoodColor();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: hasCheckedIn
              ? [moodColor, moodColor.withOpacity(0.8)]
              : [const Color(0xFF6C63FF), const Color(0xFF8B85FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: (hasCheckedIn ? moodColor : const Color(0xFF6C63FF)).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  hasCheckedIn ? "Wellbeing Tracker" : "Daily Check-in",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.spa, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            hasCheckedIn ? "Current State" : "How are you today?",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hasCheckedIn ? _level : "Check your wellbeing",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
               await Navigator.push(context, MaterialPageRoute(builder: (_) => const MentalHealthQuiz()));
               _loadData(); // Refresh home data after returning
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: hasCheckedIn ? moodColor : const Color(0xFF6C63FF),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              hasCheckedIn ? "Retake Check-in" : "Start Check-in",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyProgress(bool isDark) {
    // Filter for current month
    final now = DateTime.now();
    final currentMonthHistory = _history.where((entry) {
      final date = DateTime.parse(entry['date']);
      return date.month == now.month && date.year == now.year;
    }).toList();

    // Sort by date descending
    currentMonthHistory.sort((a, b) => b['date'].compareTo(a['date']));

    if (currentMonthHistory.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Icon(Icons.history_edu, size: 40, color: Colors.grey),
            const SizedBox(height: 10),
            Text(
              "No check-ins yet this month",
              style: TextStyle(
                 color: isDark ? Colors.white70 : Colors.grey.shade600,
                 fontWeight: FontWeight.w500
              ),
            ),
            TextButton(
              onPressed: () async {
                 await Navigator.push(context, MaterialPageRoute(builder: (_) => const MentalHealthQuiz()));
                 _loadData();
              }, 
              child: const Text("Start your first check-in")
            )
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: currentMonthHistory.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = currentMonthHistory[index];
        final date = DateTime.parse(entry['date']);
        final score = entry['score'] as int;
        
        Color scoreColor;
        if (score >= 40) scoreColor = Colors.teal;
        else if (score >= 32) scoreColor = Colors.blue;
        else if (score >= 24) scoreColor = Colors.amber;
        else scoreColor = Colors.deepOrange;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.grey.shade100
            ),
            boxShadow: [
              if (!isDark)
                 BoxShadow(
                   color: Colors.black.withOpacity(0.03),
                   blurRadius: 10,
                   offset: const Offset(0, 4)
                 )
            ]
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    score.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry['level'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${date.day}/${date.month} • ${_formatTime(date)}",
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return "$hour:$minute $period";
  }


}

