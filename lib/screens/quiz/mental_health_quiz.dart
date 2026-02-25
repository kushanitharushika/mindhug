import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'quiz_data.dart'; // Keep for fallback if verification fails
import '../../models/quiz_question.dart';
import 'quiz_results_screen.dart';
import '../../core/storage/local_storage.dart';
import '../../widgets/app_scaffold.dart';

class MentalHealthQuiz extends StatefulWidget {
  final bool isForced;
  const MentalHealthQuiz({super.key, this.isForced = false});

  @override
  State<MentalHealthQuiz> createState() => _MentalHealthQuizState();
}

class _MentalHealthQuizState extends State<MentalHealthQuiz> {
  int currentQuestion = 0;
  int totalScore = 0;
  List<QuizQuestion> _selectedQuestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('questions').get();
      
      List<QuizQuestion> allQuestions = [];
      
      if (snapshot.docs.isNotEmpty) {
        allQuestions = snapshot.docs.map((doc) {
          final data = doc.data();
          return QuizQuestion(
            question: data['question'] ?? 'Unknown Question',
            options: List<String>.from(data['options'] ?? []),
            scores: List<int>.from(data['scores'] ?? []),
          );
        }).toList();
      } else {
        // Fallback to static data if DB is empty (e.g. before seeding)
        allQuestions = List<QuizQuestion>.from(quizQuestions);
      }

      // Shuffle and pick 12 (or fewer if not enough)
      allQuestions.shuffle();
      _selectedQuestions = allQuestions.take(12).toList();
    } catch (e) {
      debugPrint("Error loading questions: $e");
      // Fallback on error
      final allQuestions = List<QuizQuestion>.from(quizQuestions);
      allQuestions.shuffle();
      _selectedQuestions = allQuestions.take(12).toList();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void answerQuestion(int score) {
    setState(() {
      totalScore += score;
      currentQuestion++;
    });

    if (currentQuestion >= _selectedQuestions.length) {
      showResult();
    }
  }

  void showResult() async {
    final level = getMentalHealthLevel(totalScore);

    // Save to Local Storage (Backup)
    await LocalStorage.saveQuizResult(score: totalScore, level: level);

    // Save to Firestore
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        
        // 1. Update latest score on main profile (keep for quick access)
        await userRef.set({
          'latestQuizScore': totalScore,
          'latestQuizLevel': level,
          'lastQuizDate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint("SUCCESS: User profile updated.");

        // 2. Add to 'quiz_history' root collection (matching user's schema)
        try {
          debugPrint("Attempting to write to quiz_history...");
          await FirebaseFirestore.instance.collection('quiz_history').add({
            'userId': user.uid, // Important for querying
            'email': user.email ?? "",
            'quizscore': totalScore.toString(), // Storing as string based on screenshot schema
            'quizlevel': level,
            'quizdate': DateTime.now().toIso8601String(),
            'timestamp': FieldValue.serverTimestamp(),
          });
          debugPrint("SUCCESS: Written to quiz_history.");
        } catch (e) {
          debugPrint("ERROR writing to quiz_history: $e");
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text("Failed to save history: $e")),
             );
          }
        }
      }
    } catch (e) {
      debugPrint("Error saving quiz result to Firestore: $e");
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(score: totalScore, level: level),
        ),
      );
    }
  }

  String getMentalHealthLevel(int score) {
    if (score >= 40) {
      return "🌸 Balanced & Resilient";
    } else if (score >= 32) {
      return "🌿 Managing Well";
    } else if (score >= 24) {
      return "⚠️ Needs Attention";
    } else {
      return "🚨 Priority Support Needed";
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isForced,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
       return const AppScaffold(
         child: Center(child: CircularProgressIndicator()),
       );
    }

    if (_selectedQuestions.isEmpty) {
      // Should not happen with fallback, but safe check
       return const AppScaffold(
         child: Center(child: Text("No questions available. Please try again later.")),
       );
    }

    if (currentQuestion >= _selectedQuestions.length) {
      return const AppScaffold(child: Center(child: CircularProgressIndicator()));
    }

    final question = _selectedQuestions[currentQuestion];

    return AppScaffold(
      showLogo: false,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isForced) ...[
              const Padding(
                padding: EdgeInsets.only(bottom: 24.0, top: 12.0),
                child: Text(
                  "It's time for your weekly check-in 💜\nLet's see how you're feeling.",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.purple,
                  ),
                ),
              ),
            ],
            Text(
              "Question ${currentQuestion + 1}/${_selectedQuestions.length}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),

            Text(
              question.question,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 18),

            ...List.generate(question.options.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    backgroundColor: Colors.purple.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => answerQuestion(question.scores[index]),
                  child: Text(
                    question.options[index],
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
