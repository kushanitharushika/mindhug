import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/storage/local_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../models/exercise.dart';
import '../../data/mock_exercises.dart';
import '../../services/cross_check_service.dart';
import '../../services/notification_service.dart';
import '../exercises/exercise_detail_screen.dart';
import 'stroop_game_screen.dart';

class StroopResultScreen extends StatefulWidget {
  final List<StroopRoundData> roundsData;
  final int totalRounds;

  const StroopResultScreen({
    super.key,
    required this.roundsData,
    required this.totalRounds,
  });

  @override
  State<StroopResultScreen> createState() => _StroopResultScreenState();
}

class _StroopResultScreenState extends State<StroopResultScreen> {
  String _crossCheckMessage = "Analyzing your cognitive metrics...";
  bool _isAnalyzing = true;
  Color _insightColor = AppColors.primary;
  List<Exercise> _recommendedExercises = [];

  // Calculated Metrics
  int _correctAnswers = 0;
  double _accuracy = 0.0;
  double _errorRate = 0.0;
  int _avgReactionTime = 0;
  int _stroopEffect = 0;
  int _avgCongruent = 0;
  int _avgIncongruent = 0;
  int _consistencyScore = 0;
  String _stressLevel = "Normal";

  @override
  void initState() {
    super.initState();
    _calculateMetrics();
    _processResults();
  }

  void _calculateMetrics() {
    if (widget.roundsData.isEmpty) return;

    int totalRT = 0;
    int congruentRT = 0;
    int congruentCount = 0;
    int incongruentRT = 0;
    int incongruentCount = 0;
    List<int> allRTs = [];

    for (var round in widget.roundsData) {
      if (round.isCorrect) _correctAnswers++;
      totalRT += round.reactionTimeMs;
      allRTs.add(round.reactionTimeMs);

      if (round.questionType == "congruent") {
        congruentRT += round.reactionTimeMs;
        congruentCount++;
      } else {
        incongruentRT += round.reactionTimeMs;
        incongruentCount++;
      }
    }

    _accuracy = (_correctAnswers / widget.totalRounds) * 100;
    _errorRate = ((widget.totalRounds - _correctAnswers) / widget.totalRounds) * 100;
    _avgReactionTime = (totalRT / widget.totalRounds).round();

    _avgCongruent = congruentCount > 0 ? (congruentRT / congruentCount).round() : 0;
    _avgIncongruent = incongruentCount > 0 ? (incongruentRT / incongruentCount).round() : 0;
    _stroopEffect = _avgIncongruent - _avgCongruent;

    // Consistency (Standard Deviation)
    double mean = _avgReactionTime.toDouble();
    double sumSquaredDiffs = allRTs.fold(0.0, (acc, rt) => acc + pow(rt - mean, 2));
    double stdDev = sqrt(sumSquaredDiffs / widget.totalRounds);
    _consistencyScore = (100 - (stdDev / 10)).clamp(0, 100).round();

    // Stress Level Classification
    if (_accuracy >= 90 && _stroopEffect <= 250) {
      _stressLevel = "Calm";
    } else if (_errorRate >= 20 || _stroopEffect > 450) {
      _stressLevel = "Stressed";
    } else {
      _stressLevel = "Normal";
    }
  }

  Future<void> _processResults() async {
    // 1. Fetch AI Prediction from the ML Engine
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/predict_stroop'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'reaction_time': _avgReactionTime.toDouble(),
          'error_rate': _errorRate,
          'stroop_effect': _stroopEffect.toDouble(),
        }),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['stress_level'] != null) {
          _stressLevel = data['stress_level'];
        }
      }
    } catch (e) {
      debugPrint("ML API Error, using local fallback calculation: $e");
    }

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Save detailed analytics payload
        await FirebaseFirestore.instance.collection('color_confution_test').add({
          'userId': user.uid,        // must match security rule field name
          'accuracy': _accuracy,
          'avg_reaction_time': _avgReactionTime,
          'stroop_effect': _stroopEffect,
          'error_rate': _errorRate,
          'consistency_score': _consistencyScore,
          'stress_level': _stressLevel,
          'time': FieldValue.serverTimestamp(),
          'detailed_rounds': widget.roundsData.map((e) => e.toMap()).toList(),
        });

        // Update user profile core stat
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'latestStroopScore': _accuracy.round(),
          'latestStroopAvgTime': _avgReactionTime,
          'lastStroopDate': FieldValue.serverTimestamp(),
          'latestStroopStressLevel': _stressLevel,
        }, SetOptions(merge: true));
      }

      // Cross-check
      String userLevel = "Unknown";
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data()!.containsKey('latestQuizLevel')) {
          userLevel = doc.data()!['latestQuizLevel'];
        } else {
          final localData = await LocalStorage.getQuizResult();
          if (localData != null) userLevel = localData['level'];
        }
      } else {
        final localData = await LocalStorage.getQuizResult();
        if (localData != null) userLevel = localData['level'];
      }

      final bool isLowStress = CrossCheckService.isManagingWell(userLevel);

      String finalMessage;
      Color finalColor = AppColors.primary;

      if (isLowStress && _stressLevel == "Stressed") {
        finalMessage = "Cognitive stress detected. Your self-reported check-in suggests you are managing well, but your reaction times (Stroop Effect: ${_stroopEffect}ms) and error rate indicate high cognitive load or fatigue. You may be subconsciously stressed.";
        finalColor = Colors.orange.shade700;
      } else if (!isLowStress && _stressLevel == "Stressed") {
        finalMessage = "Your cognitive fatigue aligns with your recent check-in. The high Stroop Effect (${_stroopEffect}ms) confirms you are under cognitive load. Please prioritize rest.";
        finalColor = AppColors.secondary;
      } else if (!isLowStress && _stressLevel == "Calm") {
        finalMessage = "Great job! Even though you reported some stress recently, your cognitive focus remains incredibly sharp and undisturbed (High consistency, low Stroop effect).";
        finalColor = AppColors.success;
      } else {
        finalMessage = "Excellent! Your cognitive focus is sharp, which aligns perfectly with your low stress levels. Your brain is efficiently processing conflicting information.";
        finalColor = AppColors.success;
      }

      // 4. Load full exercise list (local + Firebase) for recommendations
      List<Exercise> allExercises = List<Exercise>.from(mockExercises);
      try {
        final snapshot = await FirebaseFirestore.instance.collection('exercises').get();
        for (var doc in snapshot.docs) {
          final ex = Exercise.fromMap(doc.data(), doc.id);
          allExercises.removeWhere((e) => e.title.toLowerCase() == ex.title.toLowerCase());
          allExercises.add(ex);
        }
      } catch (_) {
        // Fall back to local mock exercises if Firebase fails
      }

      // 5. Generate Recommended Exercises using the pure logic service
      List<Exercise> recommended = CrossCheckService.getRecommendations(
        userLevel: userLevel,
        stroopStressLevel: _stressLevel,
        availableExercises: allExercises,
      );

      if (mounted) {
        setState(() {
          _crossCheckMessage = finalMessage;
          _insightColor = finalColor;
          _recommendedExercises = recommended;
          _isAnalyzing = false;
        });
      }

      // Save last played date and reschedule reminder
      await LocalStorage.saveLastStroopPlayedDate();
      await NotificationService().scheduleDailyStroopReminder();
    } catch (e) {
      debugPrint("Firebase Save Error: $e");
      if (mounted) {
        setState(() {
          _crossCheckMessage = "Could not complete cross-check analysis.";
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Cognitive Analytics"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Summary Cards
              Row(
                children: [
                  Expanded(child: _buildSummaryCard("Accuracy", "${_accuracy.toStringAsFixed(0)}%", Icons.check_circle_outline, Colors.teal, cardColor, isDark)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSummaryCard("Avg Time", "${_avgReactionTime}ms", Icons.speed, Colors.purple, cardColor, isDark)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSummaryCard("Stroop Eff", "${_stroopEffect}ms", Icons.psychology, Colors.orange, cardColor, isDark)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildSummaryCard("Stress State", _stressLevel, Icons.monitor_heart_outlined, _stressLevel == 'Calm' ? Colors.green : Colors.redAccent, cardColor, isDark)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSummaryCard("Consistency", "$_consistencyScore/100", Icons.track_changes, Colors.blue, cardColor, isDark)),
                ],
              ),

              const SizedBox(height: 32),

              // 2. Cross Check Analysis
              Text("Cross-Check Analysis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _insightColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _insightColor.withOpacity(0.3)),
                ),
                child: _isAnalyzing 
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline, color: _insightColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _crossCheckMessage,
                            style: TextStyle(fontSize: 15, height: 1.4, color: isDark ? Colors.white : AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
              ),

              const SizedBox(height: 32),

              // 3. Line Chart - Reaction Time Trend
              Text("Reaction Time Over Time", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 16),
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: LineChart(_buildReactionTimeChart()),
              ),

              const SizedBox(height: 32),

              // 4. Bar Chart - Congruent vs Incongruent
              Text("Cognitive Load (Stroop Effect)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 16),
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: BarChart(_buildStroopBarChart(isDark)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendItem("Congruent", Colors.blue),
                          const SizedBox(height: 8),
                          _buildLegendItem("Incongruent", Colors.orange),
                          const SizedBox(height: 16),
                          Text("Diff: ${_stroopEffect}ms", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              
               // 5. Pie Chart - Accuracy
              Text("Accuracy Breakdown", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 16),
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 30,
                          sections: [
                            PieChartSectionData(
                              color: Colors.teal,
                              value: _correctAnswers.toDouble(),
                              title: '${_accuracy.round()}%',
                              radius: 40,
                              titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            PieChartSectionData(
                              color: Colors.redAccent,
                              value: (widget.totalRounds - _correctAnswers).toDouble(),
                              title: '${_errorRate.round()}%',
                              radius: 40,
                              titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendItem("Correct", Colors.teal),
                          const SizedBox(height: 8),
                          _buildLegendItem("Incorrect", Colors.redAccent),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (_recommendedExercises.isNotEmpty) ...[
                const SizedBox(height: 40),
                Text("Recommended Exercises", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 8),
                Text("Based on your cross-check results", style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : AppColors.textSecondary)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _recommendedExercises.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final ex = _recommendedExercises[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ExerciseDetailScreen(exercise: ex)));
                        },
                        child: Container(
                          width: 200,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                            border: Border.all(color: _insightColor.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _insightColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(ex.duration, style: TextStyle(fontSize: 12, color: _insightColor, fontWeight: FontWeight.bold)),
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
              ],

              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Back to Home", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color iconColor, Color bg, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  LineChartData _buildReactionTimeChart() {
    List<FlSpot> spots = [];
    for (int i = 0; i < widget.roundsData.length; i++) {
        spots.add(FlSpot((i + 1).toDouble(), widget.roundsData[i].reactionTimeMs.toDouble()));
    }

    return LineChartData(
      gridData: const FlGridData(show: true, drawVerticalLine: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value % 5 == 0) {
                 return Text("Q${value.toInt()}", style: const TextStyle(fontSize: 10));
              }
              return const Text('');
            },
            interval: 1,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppColors.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: true, color: AppColors.primary.withOpacity(0.1)),
        ),
      ],
    );
  }

  BarChartData _buildStroopBarChart(bool isDark) {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: max(_avgCongruent, _avgIncongruent).toDouble() * 1.2,
      barTouchData: BarTouchData(enabled: false),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              String text = value == 0 ? "Congruent" : "Incongruent";
              return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(text, style: const TextStyle(fontSize: 10)));
            },
          ),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: [
        BarChartGroupData(
          x: 0,
          barRods: [BarChartRodData(toY: _avgCongruent.toDouble(), color: Colors.blue, width: 20, borderRadius: BorderRadius.circular(4))],
          showingTooltipIndicators: [0],
        ),
        BarChartGroupData(
          x: 1,
          barRods: [BarChartRodData(toY: _avgIncongruent.toDouble(), color: Colors.orange, width: 20, borderRadius: BorderRadius.circular(4))],
          showingTooltipIndicators: [0],
        ),
      ],
    );
  }
}
