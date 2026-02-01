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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _name = "Friend";
  String _level = "Not Checked";
  int _score = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      String name = "Friend";
      
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          name = doc.data()?['Name'] ?? "Friend";
        }
      }

      // Fallback or legacy load
      final savedScore = await LocalStorage.getQuizScore();
      final savedLevel = await LocalStorage.getMentalHealthLevel();

      if (mounted) {
        setState(() {
          _name = name;
          // Extract first name
          if (_name.contains(' ')) {
            _name = _name.split(' ')[0];
          }
          _score = savedScore;
          _level = savedLevel ?? "Not Checked";
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
              child: const Icon(Icons.person, color: AppColors.primary, size: 20),
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
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                "Feelings change. You’re not stuck like this.",
                style: TextStyle(
                  fontSize: 14,
                  color: subTextColor.withOpacity(0.8),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            _buildMoodCard(isDark),

            const SizedBox(height: 32),

            // Quick Actions Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            // Quick Actions Grid
            GridView.count(
              shrinkWrap: true,
              padding: const EdgeInsets.all(6),
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _actionCard(
                  "Exercises",
                  Icons.self_improvement,
                  Colors.orange.shade400,
                  Colors.orange.shade50,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExercisesScreen())),
                  isDark
                ),
                _actionCard(
                  "Journal",
                  Icons.book,
                  Colors.blue.shade400,
                  Colors.blue.shade50,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JournalScreen())),
                  isDark
                ),
                _actionCard(
                  "Chat with Melo",
                  Icons.chat_bubble_outline,
                  Colors.purple.shade400,
                  Colors.purple.shade50,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MindHugChatbot())),
                  isDark
                ),
                _actionCard(
                  "Support",
                  Icons.favorite_border,
                  Colors.red.shade400,
                  Colors.red.shade50,
                  () {}, // TODO: Add support screen
                  isDark
                ),
              ],
            ),

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
            onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (_) => const MentalHealthQuiz()));
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

  Widget _actionCard(String title, IconData icon, Color color, Color bgLight, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isDark ? Border.all(color: Colors.white10) : null,
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? color.withOpacity(0.15) : bgLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

