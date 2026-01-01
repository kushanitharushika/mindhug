import 'package:flutter/material.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/app_scaffold.dart';

class QuizResultScreen extends StatelessWidget {
  final int score;
  final String level;

  const QuizResultScreen({super.key, required this.score, required this.level});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showLogo: false,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🌸 Icon
              Container(
                height: 110,
                width: 110,
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  size: 56,
                  color: Colors.purple,
                ),
              ),

              const SizedBox(height: 20),

              // 🧠 Title
              const Text(
                "Your Wellbeing Snapshot",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // 🌿 Level
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  level,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.purple,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // 💬 Support Message
              Text(
                getSupportMessage(level),
                style: const TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 22),

              // ➡️ Continue Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const BottomNav()),
                ),
                child: const Text(
                  'Continue to MindHug',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),

              const SizedBox(height: 12),
              const Text(
                "This result is not a diagnosis.\nIt's just a small check-in 💜",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getSupportMessage(String level) {
    switch (level) {
      case "🌸 Balanced & Resilient":
        return "You're doing well! Keep nurturing your mental well-being with small positive habits 🌼";
      case "🌿 Managing Well":
        return "You seem to be managing, but might feel some pressure. Remember to take small breaks for yourself 💚";
      case "⚠️ Needs Attention":
        return "Based on your answers, it looks like you may be feeling under pressure lately. This doesn’t define you — it just shows what you might need right now 🤍";
      default:
        return "It seems things are quite heavy right now. Please consider reaching out to someone you trust — you don't have to carry this alone 🌷";
    }
  }
}
