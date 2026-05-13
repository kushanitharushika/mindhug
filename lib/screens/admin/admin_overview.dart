import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/admin_stat_card.dart';

class AdminOverview extends StatefulWidget {
  const AdminOverview({super.key});

  @override
  State<AdminOverview> createState() => _AdminOverviewState();
}

class _AdminOverviewState extends State<AdminOverview> {
  bool _loading = true;

  // Level distribution (from quiz_history)
  Map<String, int> _levelDist = {};
  int _levelTotal = 0;

  // Most recent quiz submission
  Map<String, dynamic>? _latestQuiz;

  // Most recent stroop submission
  Map<String, dynamic>? _latestStroop;

  // Recent combined activity feed
  List<Map<String, dynamic>> _recentActivity = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final List<Map<String, dynamic>> activity = [];

      // ── Quiz history ─────────────────────────────────────────────────────
      final quizSnap = await FirebaseFirestore.instance
          .collection('quiz_history')
          .orderBy('timestamp', descending: true)
          .get();

      final Map<String, int> levelMap = {};
      Map<String, dynamic>? latestQuiz;

      for (final doc in quizSnap.docs) {
        final d = doc.data();
        final level = _simplifyLevel(d['quizlevel'] ?? 'Unknown');
        levelMap[level] = (levelMap[level] ?? 0) + 1;

        final ts = d['timestamp'];
        final dt = ts is Timestamp ? ts.toDate() : DateTime(2000);

        // First doc is the latest (ordered desc)
        latestQuiz ??= {
          'email': d['email'] ?? 'Unknown',
          'level': d['quizlevel'] ?? '—',
          'score': int.tryParse(d['quizscore']?.toString() ?? '0') ?? 0,
          'ts': dt,
        };

        activity.add({
          'type': 'quiz',
          'email': d['email'] ?? 'Unknown',
          'level': d['quizlevel'] ?? '—',
          'score': int.tryParse(d['quizscore']?.toString() ?? '0') ?? 0,
          'ts': dt,
        });
      }

      // ── Stroop history ───────────────────────────────────────────────────
      final stroopSnap = await FirebaseFirestore.instance
          .collection('color_confution_test')
          .orderBy('time', descending: true)
          .get();

      Map<String, dynamic>? latestStroop;

      for (final doc in stroopSnap.docs) {
        final d = doc.data();
        final ts = d['time'];
        final dt = ts is Timestamp ? ts.toDate() : DateTime(2000);

        latestStroop ??= {
          'userId': (d['userId'] ?? '').toString(),
          'stress': d['stress_level'] ?? '—',
          'accuracy': (d['accuracy'] as num?)?.toStringAsFixed(1) ?? '—',
          'avgTime': d['avg_reaction_time'] ?? '—',
          'consistency': d['consistency_score'] ?? '—',
          'ts': dt,
        };

        activity.add({
          'type': 'stroop',
          'userId': (d['userId'] ?? '').toString(),
          'stress': d['stress_level'] ?? '—',
          'accuracy': (d['accuracy'] as num?)?.toStringAsFixed(1) ?? '—',
          'ts': dt,
        });
      }

      // Sort combined activity newest first, take 8
      activity.sort(
          (a, b) => (b['ts'] as DateTime).compareTo(a['ts'] as DateTime));

      if (mounted) {
        setState(() {
          _levelDist = levelMap;
          _levelTotal = levelMap.values.fold(0, (a, b) => a + b);
          _latestQuiz = latestQuiz;
          _latestStroop = latestStroop;
          _recentActivity = activity.take(8).toList();
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('AdminOverview load error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  String _simplifyLevel(String level) {
    if (level.contains('Balanced')) return 'Balanced';
    if (level.contains('Managing')) return 'Managing';
    if (level.contains('Attention')) return 'Needs Attention';
    if (level.contains('Priority')) return 'Priority Support';
    return 'Unknown';
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'yesterday';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subColor = isDark ? Colors.white60 : AppColors.textSecondary;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _loading = true);
        await _loadData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dashboard',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: textColor)),
                      Text('Platform at a glance',
                          style: TextStyle(fontSize: 13, color: subColor)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  color: AppColors.primary,
                  onPressed: () async {
                    setState(() => _loading = true);
                    await _loadData();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Stat tiles (live streams) ────────────────────────────────────
            LayoutBuilder(builder: (context, constraints) {
              return GridView.count(
                crossAxisCount: constraints.maxWidth > 600 ? 4 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStatStream('users', 'Total Users',
                      Icons.people_alt_rounded, Colors.blueAccent),
                  _buildStatStream('quiz_history', 'Quiz Sessions',
                      Icons.quiz_rounded, Colors.orangeAccent),
                  _buildStatStream('exercises', 'Exercises',
                      Icons.fitness_center_rounded, Colors.purpleAccent),
                  _buildStatStream('color_confution_test', 'Stroop Tests',
                      Icons.psychology_rounded, Colors.teal),
                ],
              );
            }),

            const SizedBox(height: 24),

            // ── Latest submissions ───────────────────────────────────────────
            _sectionHeader('Latest Submissions',
                Icons.inbox_rounded, Colors.blueAccent, textColor),
            const SizedBox(height: 12),
            _loading
                ? _shimmer(cardColor, isDark, height: 130)
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: _latestQuizCard(
                              cardColor, isDark, textColor, subColor)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _latestStroopCard(
                              cardColor, isDark, textColor, subColor)),
                    ],
                  ),

            const SizedBox(height: 24),

            // ── Wellbeing distribution ───────────────────────────────────────
            _sectionHeader('Wellbeing Distribution',
                Icons.bar_chart_rounded, Colors.orangeAccent, textColor),
            const SizedBox(height: 12),
            _loading
                ? _shimmer(cardColor, isDark, height: 160)
                : _levelDist.isEmpty
                    ? _emptyState('No quiz data yet', isDark)
                    : _buildLevelBars(cardColor, isDark, textColor),

            const SizedBox(height: 24),

            // ── Recent activity feed ─────────────────────────────────────────
            _sectionHeader('Recent Activity',
                Icons.history_rounded, Colors.purpleAccent, textColor),
            const SizedBox(height: 12),
            _loading
                ? _shimmer(cardColor, isDark, height: 200)
                : _recentActivity.isEmpty
                    ? _emptyState('No activity yet', isDark)
                    : _buildActivityFeed(cardColor, isDark, textColor, subColor),
          ],
        ),
      ),
    );
  }

  // ─────────────────────── Widgets ────────────────────────────────────────────

  Widget _sectionHeader(
      String title, IconData icon, Color color, Color textColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 9),
        Text(title,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textColor)),
      ],
    );
  }

  Widget _buildStatStream(
      String collection, String title, IconData icon, Color color) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snap) {
        final value = snap.hasData ? '${snap.data!.docs.length}' : '…';
        return AdminStatCard(
            title: title, value: value, icon: icon, color: color);
      },
    );
  }

  Widget _latestQuizCard(
      Color cardColor, bool isDark, Color textColor, Color subColor) {
    if (_latestQuiz == null) return _emptyState('No quiz yet', isDark);

    final q = _latestQuiz!;
    final level = q['level'] as String;
    final score = q['score'] as int;
    final dt = q['ts'] as DateTime;

    final Color levelColor;
    if (level.contains('Balanced')) {
      levelColor = Colors.teal;
    } else if (level.contains('Managing')) {
      levelColor = Colors.blue;
    } else if (level.contains('Attention')) {
      levelColor = Colors.amber.shade700;
    } else {
      levelColor = Colors.deepOrange;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: Colors.white10) : null,
        boxShadow: isDark
            ? null
            : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.12),
                    shape: BoxShape.circle),
                child: const Icon(Icons.quiz_rounded,
                    color: Colors.orangeAccent, size: 14),
              ),
              const SizedBox(width: 6),
              Text('Last Check-in',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: subColor)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            q['email'] as String,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: levelColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              level,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: levelColor),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Score: $score / 50',
                  style: TextStyle(fontSize: 11, color: subColor)),
              Text(_timeAgo(dt),
                  style: TextStyle(fontSize: 11, color: subColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _latestStroopCard(
      Color cardColor, bool isDark, Color textColor, Color subColor) {
    if (_latestStroop == null) return _emptyState('No test yet', isDark);

    final s = _latestStroop!;
    final stress = s['stress'] as String;
    final accuracy = s['accuracy'].toString();
    final dt = s['ts'] as DateTime;
    final uid = s['userId'] as String;
    final shortUid = uid.length > 8 ? '…${uid.substring(uid.length - 8)}' : uid;

    final stressColor = stress == 'Calm'
        ? Colors.teal
        : stress == 'Stressed'
            ? Colors.deepOrange
            : Colors.blue;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: Colors.white10) : null,
        boxShadow: isDark
            ? null
            : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.12),
                    shape: BoxShape.circle),
                child: const Icon(Icons.psychology_rounded,
                    color: Colors.teal, size: 14),
              ),
              const SizedBox(width: 6),
              Text('Last Stroop Test',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: subColor)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            shortUid,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: stressColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              stress,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: stressColor),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Accuracy: $accuracy%',
                  style: TextStyle(fontSize: 11, color: subColor)),
              Text(_timeAgo(dt),
                  style: TextStyle(fontSize: 11, color: subColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBars(Color cardColor, bool isDark, Color textColor) {
    final levelColors = {
      'Balanced': Colors.teal,
      'Managing': Colors.blue,
      'Needs Attention': Colors.amber.shade700,
      'Priority Support': Colors.deepOrange,
      'Unknown': Colors.grey,
    };

    final sorted = _levelDist.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: isDark ? Border.all(color: Colors.white10) : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
      ),
      child: Column(
        children: sorted.map((e) {
          final color = levelColors[e.key] ?? Colors.grey;
          final frac = _levelTotal > 0 ? e.value / _levelTotal : 0.0;
          final pct = (frac * 100).round();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(e.key,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary)),
                    ),
                    Text('${e.value} users · $pct%',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: color)),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: frac,
                    minHeight: 8,
                    backgroundColor:
                        isDark ? Colors.white12 : Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActivityFeed(
      Color cardColor, bool isDark, Color textColor, Color subColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: isDark ? Border.all(color: Colors.white10) : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
      ),
      child: Column(
        children: _recentActivity.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final isLast = i == _recentActivity.length - 1;
          final isQuiz = item['type'] == 'quiz';

          final icon =
              isQuiz ? Icons.quiz_rounded : Icons.psychology_rounded;
          final color = isQuiz ? Colors.orangeAccent : Colors.teal;

          String title;
          String subtitle;

          if (isQuiz) {
            title = (item['email'] as String).isNotEmpty
                ? item['email'] as String
                : 'Unknown user';
            subtitle =
                '${item['level']}  ·  Score ${item['score']} / 50';
          } else {
            final uid = item['userId'] as String;
            title = uid.length > 8
                ? 'User …${uid.substring(uid.length - 8)}'
                : uid;
            subtitle =
                'Stroop · ${item['stress']} · Accuracy ${item['accuracy']}%';
          }

          return Column(
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.12), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 18),
                ),
                title: Text(title,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                subtitle: Text(subtitle,
                    style: TextStyle(fontSize: 11, color: subColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                trailing: Text(_timeAgo(item['ts'] as DateTime),
                    style: TextStyle(fontSize: 11, color: subColor)),
              ),
              if (!isLast)
                Divider(
                    height: 1,
                    indent: 56,
                    color:
                        isDark ? Colors.white10 : Colors.grey.shade100),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _shimmer(Color cardColor, bool isDark, {required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _emptyState(String msg, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? Colors.white12 : Colors.grey.shade200),
      ),
      child: Text(msg,
          style: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey.shade500)),
    );
  }
}
