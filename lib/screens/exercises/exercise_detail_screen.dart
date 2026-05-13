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
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
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
                                    step.text,
                                    style: TextStyle(
                                      fontSize: 15,
                                      height: 1.4,
                                      color: isDark ? Colors.white70 : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (step.imageUrl != null) ...[
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  step.imageUrl!,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      height: 180,
                                      width: double.infinity,
                                      color: isDark ? Colors.white10 : Colors.grey.shade100,
                                      alignment: Alignment.center,
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / 
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (ctx, err, stack) {
                                    return Container(
                                    height: 180,
                                    width: double.infinity,
                                    color: isDark ? Colors.white10 : Colors.grey.shade100,
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.broken_image, color: Colors.grey),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Could not load image",
                                          style: TextStyle(
                                            color: isDark ? Colors.white54 : Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
          
          // Persistent Timer Section
          Container(
            padding: const EdgeInsets.only(top: 24, bottom: 32, left: 16, right: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black45 : Colors.black12,
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Timer Circle
                  Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? AppColors.backgroundDark : Colors.grey.shade50,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(isDark ? 0.2 : 0.1),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: isDark ? Colors.black26 : Colors.black12,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 170,
                            height: 170,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0 - (_remainingSeconds / _totalSeconds)),
                              duration: const Duration(milliseconds: 300),
                              builder: (context, value, child) {
                                return CircularProgressIndicator(
                                  value: value, 
                                  strokeWidth: 12,
                                  strokeCap: StrokeCap.round,
                                  backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _remainingSeconds <= 10 && _remainingSeconds > 0 ? AppColors.error : AppColors.primary
                                  ),
                                );
                              }
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isActive ? Icons.timer : Icons.timer_outlined,
                                size: 28,
                                color: isDark ? Colors.white30 : AppColors.textSecondary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatTime(_remainingSeconds),
                                style: TextStyle(
                                  fontSize: 48,
                                  height: 1.0,
                                  fontWeight: FontWeight.w800,
                                  color: _remainingSeconds <= 10 && _remainingSeconds > 0
                                      ? AppColors.error 
                                      : (isDark ? Colors.white : AppColors.textPrimary),
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isActive ? "Time Remaining" : "Ready to Start",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.1,
                                  color: isDark ? Colors.white54 : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isActive)
                        ElevatedButton.icon(
                          onPressed: _stopTimer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.pause),
                          label: const Text("Pause", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: _isCompleted ? null : _startTimer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isCompleted ? Colors.grey : AppColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          icon: Icon(_isCompleted ? Icons.check : Icons.play_arrow),
                          label: Text(
                            _isCompleted ? "Done" : "Start", 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                          ),
                        ),
                        
                      const SizedBox(width: 16),
                      
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.refresh, 
                            color: isDark ? Colors.white70 : AppColors.textSecondary
                          ),
                          onPressed: _resetTimer,
                          tooltip: "Reset Timer",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
