import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/exercise.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';


class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> with SingleTickerProviderStateMixin {
  late Timer _timer;
  late int _totalSeconds;
  late int _remainingSeconds;
  bool _isActive = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _totalSeconds = _parseDuration(widget.exercise.duration);
    _remainingSeconds = _totalSeconds;
  }

  @override
  void dispose() {
    if (_isActive) _timer.cancel();
    super.dispose();
  }

  int _parseDuration(String durationStr) {
    // "5 mins" -> 300
    // "10 mins" -> 600
    try {
      final parts = durationStr.split(' ');
      if (parts.isNotEmpty) {
        final val = int.tryParse(parts[0]);
        if (val != null) return val * 60;
      }
    } catch (_) {}
    return 300; // Default 5 mins
  }

  void _startTimer() {
    setState(() {
      _isActive = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _stopTimer();
        setState(() {
          _isCompleted = true;
          _isActive = false;
        });
        _triggerFeedback();
        _showCompletionDialog();
      }
    });
  }

  Future<void> _triggerFeedback() async {
    // Vibrate 3 times: [wait, vibrate, wait, vibrate, ...]
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(pattern: [0, 500, 200, 500, 200, 500]);
    }
    // Sound
    FlutterRingtonePlayer().playNotification();
  }

  void _stopTimer() {
    if (_isActive) {
      _timer.cancel();
      setState(() {
        _isActive = false;
      });
    }
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _remainingSeconds = _totalSeconds;
      _isCompleted = false;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Great Job!"),
        content: const Text("You've completed this exercise. Take a moment to appreciate yourself."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to list
            },
            child: const Text("Finish"),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds / 60).floor();
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text(widget.exercise.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Description
                  Text(
                    widget.exercise.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Benefits Section
                  if (widget.exercise.benefits.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.psychology, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "Why this helps",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.exercise.benefits,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  if (widget.exercise.steps.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      "How to do it",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...widget.exercise.steps.asMap().entries.map((entry) {
                      final index = entry.key + 1;
                      final step = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white10 : Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "$index",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                step,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.4,
                                  color: isDark ? Colors.white70 : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],

                  const SizedBox(height: 40),
                  
                  // Timer Circle (Centered in scroll view)
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 220,
                          height: 220,
                          child: CircularProgressIndicator(
                            value: 1.0 - (_remainingSeconds / _totalSeconds), 
                            strokeWidth: 12,
                            backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                             Icon(
                              _isActive ? Icons.timer : Icons.timer_off_outlined,
                              size: 32,
                              color: isDark ? Colors.white30 : Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatTime(_remainingSeconds),
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                            Text(
                              _isActive ? "Remaining" : "Ready",
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white54 : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isActive)
            FloatingActionButton.large(
              onPressed: _stopTimer,
              backgroundColor: Colors.orangeAccent,
              child: const Icon(Icons.pause, size: 40, color: Colors.white),
            )
          else
            FloatingActionButton.large(
              onPressed: _isCompleted ? null : _startTimer,
              backgroundColor: _isCompleted ? Colors.grey : AppColors.success,
              child: Icon(
                _isCompleted ? Icons.check : Icons.play_arrow,
                size: 40,
                color: Colors.white
              ),
            ),
            
          const SizedBox(width: 20),
          
          FloatingActionButton(
            onPressed: _resetTimer,
            backgroundColor: isDark ? Colors.white10 : Colors.white,
            foregroundColor: isDark ? Colors.white : Colors.grey,
            elevation: 0,
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
