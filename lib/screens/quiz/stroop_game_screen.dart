import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'stroop_result_screen.dart';

class StroopRoundData {
  final String word;
  final String colorName;
  final String userAnswer;
  final bool isCorrect;
  final int reactionTimeMs;
  final String questionType; 

  StroopRoundData({
    required this.word,
    required this.colorName,
    required this.userAnswer,
    required this.isCorrect,
    required this.reactionTimeMs,
    required this.questionType,
  });

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'color': colorName,
      'user_answer': userAnswer,
      'is_correct': isCorrect,
      'reaction_time': reactionTimeMs,
      'question_type': questionType,
    };
  }
}

class StroopGameScreen extends StatefulWidget {
  const StroopGameScreen({super.key});

  @override
  State<StroopGameScreen> createState() => _StroopGameScreenState();
}

class _StroopGameScreenState extends State<StroopGameScreen> {
  final List<String> _colorNames = ["RED", "BLUE", "GREEN", "YELLOW"];
  final List<Color> _colors = [
    Colors.redAccent.shade700, 
    Colors.blueAccent.shade700, 
    Colors.green.shade600, 
    Colors.amber.shade700
  ];
  
  int _currentWordIndex = 0;
  int _currentColorIndex = 0;
  
  int _round = 1;
  final int _maxRounds = 20;
  
  final List<StroopRoundData> _roundsData = [];
  
  DateTime? _wordAppearedTime;
  final Random _random = Random();
  
  bool _isPlaying = false;
  bool _hasStarted = false;
  
  // Per-round Timer
  Timer? _roundTimer;
  final int _timeLimitMs = 3000; // 3 seconds per round

  @override
  void dispose() {
    _roundTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _hasStarted = true;
      _isPlaying = true;
      _round = 1;
      _roundsData.clear();
      _nextRound();
    });
  }

  void _nextRound() {
    if (_round > _maxRounds) {
      _endGame();
      return;
    }
    
    _roundTimer?.cancel();
    
    setState(() {
      _currentWordIndex = _random.nextInt(_colorNames.length);
      // Roughly 30% congruent, 70% incongruent
      if (_random.nextDouble() > 0.3) {
        _currentColorIndex = _random.nextInt(_colors.length);
        while (_currentColorIndex == _currentWordIndex) {
          _currentColorIndex = _random.nextInt(_colors.length);
        }
      } else {
        _currentColorIndex = _currentWordIndex;
      }
      
      _wordAppearedTime = DateTime.now();
      
      // Enforce the 3-second limit per question
      _roundTimer = Timer(Duration(milliseconds: _timeLimitMs), _handleTimeout);
    });
  }

  void _handleTimeout() {
    if (!_isPlaying) return;
    
    final String qType = (_currentWordIndex == _currentColorIndex) ? "congruent" : "incongruent";
    
    // Auto-record a miss
    _roundsData.add(StroopRoundData(
      word: _colorNames[_currentWordIndex],
      colorName: _colorNames[_currentColorIndex],
      userAnswer: "TIMEOUT",
      isCorrect: false,
      reactionTimeMs: _timeLimitMs,
      questionType: qType,
    ));
    
    _round++;
    _nextRound();
  }

  void _handleTap(int colorIndex) {
    if (!_isPlaying) return;
    
    _roundTimer?.cancel(); // stop timer when they answer
    
    final int reactionTime = DateTime.now().difference(_wordAppearedTime!).inMilliseconds;
    final bool isCorrect = colorIndex == _currentColorIndex;
    final String qType = (_currentWordIndex == _currentColorIndex) ? "congruent" : "incongruent";
    
    _roundsData.add(StroopRoundData(
      word: _colorNames[_currentWordIndex],
      colorName: _colorNames[_currentColorIndex],
      userAnswer: _colorNames[colorIndex],
      isCorrect: isCorrect,
      reactionTimeMs: reactionTime,
      questionType: qType,
    ));
    
    _round++;
    _nextRound();
  }

  void _endGame() {
    setState(() {
      _isPlaying = false;
      _roundTimer?.cancel();
    });
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => StroopResultScreen(
          roundsData: _roundsData,
          totalRounds: _maxRounds,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: const Text("Color Confusion"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_hasStarted) ...[
                const Spacer(),
                const Icon(Icons.psychology, size: 80, color: AppColors.primary),
                const SizedBox(height: 24),
                Text(
                  "Color Confusion Game",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "A word will appear on the screen. Tap the button that matches the INK COLOR of the word, not what the word says.\n\nYou have exactly 3 seconds per word. Be as fast as possible!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text("Start Game", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ] else ...[
                // Game UI
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Round $_round / $_maxRounds",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Visual Shrinking Progress Bar (3 seconds)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey<int>(_round), // Remakes the animation every round
                    tween: Tween<double>(begin: 1.0, end: 0.0),
                    duration: Duration(milliseconds: _timeLimitMs),
                    builder: (context, value, child) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 12,
                        backgroundColor: isDark ? Colors.white10 : Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          value > 0.3 ? AppColors.primary : AppColors.error
                        ),
                      );
                    },
                  ),
                ),
                
                const Spacer(),
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 100),
                    child: Text(
                      _colorNames[_currentWordIndex],
                      key: ValueKey<int>(_round),
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        color: _colors[_currentColorIndex],
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(2, 4),
                            blurRadius: 4,
                          )
                        ]
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Color choices grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.0, 
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => _handleTap(index),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _colors[index],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _colors[index].withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
