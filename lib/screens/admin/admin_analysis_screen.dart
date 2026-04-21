import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';

class AdminAnalysisScreen extends StatefulWidget {
  const AdminAnalysisScreen({super.key});

  @override
  State<AdminAnalysisScreen> createState() => _AdminAnalysisScreenState();
}

class _AdminAnalysisScreenState extends State<AdminAnalysisScreen> {
  bool _isLoading = true;

  // Quiz analytics
  int _totalQuizSessions = 0;
  double _avgQuizScore = 0;
  Map<String, int> _levelDistribution = {};

  // Stroop analytics
  int _totalStroopSessions = 0;
  double _avgAccuracy = 0;
  double _avgStroopEffect = 0;
  Map<String, int> _stressDistribution = {};

  // User analytics
  int _totalUsers = 0;
  int _activeUsers = 0; // users with at least one quiz result

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      // 1. Quiz history
      final quizSnap =
          await FirebaseFirestore.instance.collection('quiz_history').get();
      _totalQuizSessions = quizSnap.docs.length;

      double totalScore = 0;
      final Map<String, int> levelMap = {};
      for (final doc in quizSnap.docs) {
        final data = doc.data();
        final score = double.tryParse(data['quizscore']?.toString() ?? '0') ?? 0;
        totalScore += score;
        final level = _simplifyLevel(data['quizlevel'] ?? 'Unknown');
        levelMap[level] = (levelMap[level] ?? 0) + 1;
      }
      _avgQuizScore =
          _totalQuizSessions > 0 ? totalScore / _totalQuizSessions : 0;
      _levelDistribution = levelMap;

      // 2. Stroop test history
      final stroopSnap = await FirebaseFirestore.instance
          .collection('color_confution_test')
          .get();
      _totalStroopSessions = stroopSnap.docs.length;

      double totalAcc = 0;
      double totalEffect = 0;
      final Map<String, int> stressMap = {};
      for (final doc in stroopSnap.docs) {
        final data = doc.data();
        totalAcc += (data['accuracy'] as num?)?.toDouble() ?? 0;
        totalEffect += (data['stroop_effect'] as num?)?.toDouble() ?? 0;
        final stress = data['stress_level'] ?? 'Unknown';
        stressMap[stress] = (stressMap[stress] ?? 0) + 1;
      }
      _avgAccuracy =
          _totalStroopSessions > 0 ? totalAcc / _totalStroopSessions : 0;
      _avgStroopEffect =
          _totalStroopSessions > 0 ? totalEffect / _totalStroopSessions : 0;
      _stressDistribution = stressMap;

      // 3. Users
      final usersSnap =
          await FirebaseFirestore.instance.collection('users').get();
      _totalUsers = usersSnap.docs.length;
      _activeUsers = usersSnap.docs
          .where((d) => d.data().containsKey('latestQuizScore'))
          .length;
    } catch (e) {
      debugPrint('AdminAnalysis load error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _simplifyLevel(String level) {
    if (level.contains('Balanced')) return 'Balanced';
    if (level.contains('Managing')) return 'Managing';
    if (level.contains('Attention')) return 'Needs Attention';
    if (level.contains('Priority')) return 'Priority Support';
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subColor = isDark ? Colors.white60 : AppColors.textSecondary;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _isLoading = true);
        await _loadAnalytics();
      },
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Overall Analysis',
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: textColor)),
                            const SizedBox(height: 4),
                            Text('Platform-wide mental health insights',
                                style:
                                    TextStyle(fontSize: 13, color: subColor)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          setState(() => _isLoading = true);
                          await _loadAnalytics();
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        color: AppColors.primary,
                        tooltip: 'Refresh',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Top stat row ────────────────────────────────────────
                  Row(
                    children: [
                      _statTile('Total Users', '$_totalUsers',
                          Icons.people_alt_rounded, Colors.blueAccent, cardColor, isDark),
                      const SizedBox(width: 12),
                      _statTile('Active Users', '$_activeUsers',
                          Icons.verified_user_rounded, Colors.green, cardColor, isDark),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _statTile('Quiz Sessions', '$_totalQuizSessions',
                          Icons.quiz_rounded, Colors.orangeAccent, cardColor, isDark),
                      const SizedBox(width: 12),
                      _statTile('Stroop Tests', '$_totalStroopSessions',
                          Icons.psychology_rounded, Colors.purpleAccent, cardColor, isDark),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Quiz Analytics ──────────────────────────────────────
                  _sectionHeader('Quiz Analytics', Icons.bar_chart_rounded,
                      Colors.orangeAccent, textColor),
                  const SizedBox(height: 12),

                  // Avg score card
                  _buildAvgScoreCard(cardColor, isDark, textColor),
                  const SizedBox(height: 16),

                  // Level distribution
                  if (_levelDistribution.isNotEmpty) ...[
                    Text('Wellbeing Level Distribution',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textColor)),
                    const SizedBox(height: 10),
                    _buildLevelDistributionChart(cardColor, isDark),
                    const SizedBox(height: 16),
                    _buildLevelLegend(isDark),
                  ] else
                    _emptyState('No quiz data yet', isDark),

                  const SizedBox(height: 28),

                  // ── Stroop Analytics ────────────────────────────────────
                  _sectionHeader('Cognitive Test Analytics',
                      Icons.track_changes_rounded, Colors.purpleAccent, textColor),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _metricCard('Avg Accuracy',
                          '${_avgAccuracy.toStringAsFixed(1)}%',
                          Icons.check_circle_outline, Colors.teal, cardColor, isDark),
                      const SizedBox(width: 12),
                      _metricCard('Avg Stroop\nEffect',
                          '${_avgStroopEffect.toStringAsFixed(0)}ms',
                          Icons.compare_arrows_rounded, Colors.deepOrange,
                          cardColor, isDark),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_stressDistribution.isNotEmpty) ...[
                    Text('Stress Level Distribution (Stroop)',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textColor)),
                    const SizedBox(height: 10),
                    _buildStressDistributionChart(cardColor, isDark, textColor),
                  ] else
                    _emptyState('No Stroop test data yet', isDark),

                  const SizedBox(height: 28),

                  // ── User engagement ─────────────────────────────────────
                  _sectionHeader('User Engagement',
                      Icons.insights_rounded, Colors.blueAccent, textColor),
                  const SizedBox(height: 12),
                  _buildEngagementCard(cardColor, isDark, textColor, subColor),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  // ─────────────────────── Builders ───────────────────────────────────────────

  Widget _sectionHeader(
      String title, IconData icon, Color color, Color textColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor)),
      ],
    );
  }

  Widget _statTile(String title, String value, IconData icon, Color color,
      Color cardColor, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                  color: color.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
          ],
          border: isDark ? Border.all(color: Colors.white10) : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary)),
                Text(title,
                    style: TextStyle(
                        fontSize: 11,
                        color:
                            isDark ? Colors.white54 : AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricCard(String title, String value, IconData icon, Color color,
      Color cardColor, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
          ],
          border: isDark ? Border.all(color: Colors.white10) : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildAvgScoreCard(Color cardColor, bool isDark, Color textColor) {
    final pct = (_avgQuizScore / 50).clamp(0.0, 1.0);
    Color barColor;
    if (_avgQuizScore >= 40) {
      barColor = Colors.teal;
    } else if (_avgQuizScore >= 32) {
      barColor = Colors.blue;
    } else if (_avgQuizScore >= 24) {
      barColor = Colors.amber;
    } else {
      barColor = Colors.deepOrange;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
        ],
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Average Quiz Score',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: textColor)),
              Text(_avgQuizScore.toStringAsFixed(1),
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: barColor)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor:
                  isDark ? Colors.white12 : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 8),
          Text('Out of 50 points · $_totalQuizSessions total sessions',
              style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildLevelDistributionChart(Color cardColor, bool isDark) {
    final colors = {
      'Balanced': Colors.teal,
      'Managing': Colors.blue,
      'Needs Attention': Colors.amber.shade700,
      'Priority Support': Colors.deepOrange,
      'Unknown': Colors.grey,
    };

    final total = _levelDistribution.values.fold(0, (a, b) => a + b);
    final sections = _levelDistribution.entries.map((e) {
      final color = colors[e.key] ?? Colors.grey;
      final pct = total > 0 ? (e.value / total * 100).round() : 0;
      return PieChartSectionData(
        color: color,
        value: e.value.toDouble(),
        title: '$pct%',
        radius: 48,
        titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white),
      );
    }).toList();

    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
        ],
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 36,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  Widget _buildLevelLegend(bool isDark) {
    final colors = {
      'Balanced': Colors.teal,
      'Managing': Colors.blue,
      'Needs Attention': Colors.amber.shade700,
      'Priority Support': Colors.deepOrange,
      'Unknown': Colors.grey,
    };
    final total = _levelDistribution.values.fold(0, (a, b) => a + b);

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: _levelDistribution.entries.map((e) {
        final color = colors[e.key] ?? Colors.grey;
        final pct = total > 0 ? (e.value / total * 100).round() : 0;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: color, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text('${e.key} ($pct%)',
                style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white70 : AppColors.textSecondary)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildStressDistributionChart(
      Color cardColor, bool isDark, Color textColor) {
    final stressColors = {
      'Calm': Colors.teal,
      'Normal': Colors.blue,
      'Stressed': Colors.deepOrange,
      'Unknown': Colors.grey,
    };
    final total = _stressDistribution.values.fold(0, (a, b) => a + b);
    final entries = _stressDistribution.entries.toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
        ],
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: Column(
        children: entries.map((e) {
          final color = stressColors[e.key] ?? Colors.grey;
          final pct = total > 0 ? e.value / total : 0.0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(e.key,
                      style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : AppColors.textSecondary)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct.toDouble(),
                      minHeight: 12,
                      backgroundColor:
                          isDark ? Colors.white12 : Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${e.value}',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEngagementCard(
      Color cardColor, bool isDark, Color textColor, Color subColor) {
    final engagementRate =
        _totalUsers > 0 ? (_activeUsers / _totalUsers * 100) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.85),
            AppColors.primaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.group_rounded, color: Colors.white70, size: 20),
              SizedBox(width: 8),
              Text('User Engagement Rate',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          Text('${engagementRate.toStringAsFixed(1)}%',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
              '$_activeUsers of $_totalUsers users have completed at least one check-in',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (engagementRate / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String msg, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(28),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? Colors.white12 : Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.bar_chart_outlined,
              size: 40, color: isDark ? Colors.white30 : Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(msg,
              style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.grey.shade500)),
        ],
      ),
    );
  }
}
