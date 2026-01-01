import 'package:flutter/material.dart';
import 'quiz_data.dart';
import '../../models/quiz_question.dart';
import 'quiz_results_screen.dart';
import '../../core/storage/local_storage.dart';
import '../../widgets/app_scaffold.dart';

class MentalHealthQuiz extends StatefulWidget {
  const MentalHealthQuiz({super.key});

  @override
  State<MentalHealthQuiz> createState() => _MentalHealthQuizState();
}

class _MentalHealthQuizState extends State<MentalHealthQuiz> {
  int currentQuestion = 0;
  int totalScore = 0;
  List<QuizQuestion> _selectedQuestions = [];

  @override
  void initState() {
    super.initState();
    // Shuffle and pick 12 questions
    final allQuestions = List<QuizQuestion>.from(quizQuestions);
    allQuestions.shuffle();
    _selectedQuestions = allQuestions.take(12).toList();
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

    await LocalStorage.saveQuizResult(score: totalScore, level: level);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuizResultScreen(score: totalScore, level: level),
      ),
    );
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
    if (currentQuestion >= _selectedQuestions.length) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = _selectedQuestions[currentQuestion];

    return AppScaffold(
      showLogo: false,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
