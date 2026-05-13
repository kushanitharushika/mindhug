import 'package:flutter/material.dart';
import '../../core/storage/local_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/mindhug_logo.dart';
import '../profile/profile_screen.dart';
import '../quiz/mental_health_quiz.dart';
import '../quiz/stroop_game_screen.dart';
import '../../services/notification_service.dart';
import '../chatbot/chatbase_screen.dart';

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
  DateTime _selectedMonth = DateTime.now(); // Track selected month
  
  static const List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  final NotificationService _notificationService = NotificationService();
  


  @override
  void initState() {
    super.initState();
    _initNotifications();
    _loadData();
  }

  Future<void> _initNotifications() async {
    await _notificationService.init();
    await _notificationService.scheduleDailyStroopReminder();
  }

  Future<void> _loadData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      String name = "Friend";
      
      final savedScore = await LocalStorage.getQuizScore();
      final savedLevel = await LocalStorage.getMentalHealthLevel();
      // List<Map<String, dynamic>> history = await LocalStorage.getQuizHistory(); // REMOVED: Using Firestore only
      
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

          // Fetch History
          await _fetchMonthData(user.uid);
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
          // _history = history; // REMOVED
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

  Future<void> _fetchMonthData(String uid) async {
    // Keep loading true only if we don't have existing data to show, or make it subtle
    // setState(() => _isLoading = true); 
    
    try {
      final start = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      final end = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);

      debugPrint("Fetching data for ${start.month}/${start.year}");

      final historySnapshot = await FirebaseFirestore.instance
           .collection('quiz_history')
           .where('userId', isEqualTo: uid)
           .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
           .where('timestamp', isLessThan: Timestamp.fromDate(end))
           .orderBy('timestamp', descending: false) // Oldest first for chart
           .get();

       List<Map<String, dynamic>> fetchedHistory = [];
       if (historySnapshot.docs.isNotEmpty) {
         fetchedHistory = historySnapshot.docs.map((doc) {
           final data = doc.data();
           return {
             'score': int.tryParse(data['quizscore'].toString()) ?? 0,
             'level': data['quizlevel'] ?? 'Unknown',
             'date': data['quizdate'] ?? DateTime.now().toIso8601String(),
           };
         }).toList();
       }
       
       if (mounted) {
         setState(() {
           _history = fetchedHistory;
           _isLoading = false;
         });
       }
    } catch (e) {
       debugPrint("Error fetching month data: $e");
       if (mounted) {
         // Show snackbar if it's an index error (common with composite queries)
         if (e.toString().contains('failed-precondition') || e.toString().contains('requires an index')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Index required! Check debug console for link."),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 10),
              ),
            );
         }
       }
    }
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + offset);
      // Don't clear history yet to minimize flicker
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _fetchMonthData(user.uid);
    }
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
            
            // Cognitive Games Section
            const Text(
              "Cognitive Assessments",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildCognitiveGameCard(isDark),

            const SizedBox(height: 32),

            // Monthly Progress Header
            const Text(
              "Mental Health Trends",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildAnalyticsChart(isDark),

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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatbaseScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.chat, color: Colors.white),
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

  Widget _buildAnalyticsChart(bool isDark) {
    // Sort chronologically (Oldest -> Newest)
    final sortedHistory = List<Map<String, dynamic>>.from(_history);
    sortedHistory.sort((a, b) => a['date'].compareTo(b['date']));
    
    // Use ALL data for the month
    final chartData = sortedHistory;
    final monthName = months[_selectedMonth.month - 1];

    List<FlSpot> spots = [];
    for (int i = 0; i < chartData.length; i++) {
        spots.add(FlSpot(i.toDouble(), (chartData[i]['score'] as int).toDouble()));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        children: [
           // Month Selector
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               IconButton(
                 icon: const Icon(Icons.chevron_left),
                 onPressed: () => _changeMonth(-1),
               ),
               Text(
                 "$monthName ${_selectedMonth.year}",
                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
               ),
               IconButton(
                 icon: const Icon(Icons.chevron_right),
                 onPressed: () => _changeMonth(1),
               ),
             ],
           ),
           const SizedBox(height: 10),

           if (chartData.isEmpty)
             SizedBox(
               height: 150,
               child: Center(
                 child: Text(
                   "No check-ins in $monthName",
                   style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                 ),
               ),
             )
           else
             SizedBox(
               height: 180,
               child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < chartData.length) {
                            final date = DateTime.parse(chartData[index]['date']);
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                "${date.day}",
                                style: TextStyle(
                                  fontSize: 10, 
                                  color: isDark ? Colors.white54 : Colors.grey.shade600
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                        interval: 1,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (chartData.length - 1).toDouble(),
                  minY: 0,
                  maxY: 50,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.purple.shade400,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: Colors.purple.shade400
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.purple.withOpacity(0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                         return touchedSpots.map((spot) {
                            final d = chartData[spot.x.toInt()];
                            return LineTooltipItem(
                              "${spot.y.toInt()}\n",
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              children: [TextSpan(text: d['level'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal))]
                            );
                         }).toList();
                      },
                       tooltipPadding: const EdgeInsets.all(8),
                    ),
                  ),
                ),
              ),
             ),
        ],
      ),
    );
  }

  Widget _buildCognitiveGameCard(bool isDark) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const StroopGameScreen()));
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Color Confusion Test",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Check your cognitive focus level",
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.white54 : AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

}
