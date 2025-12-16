import 'package:flutter/material.dart';
import '../quiz/mental_health_quiz.dart';
import '../../widgets/bottom_nav.dart';
import '../../core/storage/local_storage.dart';
import '../../widgets/app_scaffold.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Full Name
            TextField(
              decoration: InputDecoration(
                labelText: "Full Name",
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Email
            TextField(
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Password
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Sign Up Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.purple.shade400,
              ),
              onPressed: () async {
                // Optional: clear previous data for testing
                // await LocalStorage.clearQuizData();

                // Check if quiz was completed
                final quizCompleted = await LocalStorage.isQuizCompleted();
                print("Quiz completed? $quizCompleted"); // debug

                // Navigate based on quiz completion
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => quizCompleted
                        ? const BottomNav() // Skip quiz if done
                        : const MentalHealthQuiz(), // Go to quiz if new
                  ),
                );
              },
              child: const Text(
                "Sign Up",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
