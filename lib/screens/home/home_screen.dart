import 'package:flutter/material.dart';
import '../../core/storage/local_storage.dart';
import '../../widgets/mindhug_logo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String level = "Loading...";
  int score = 0;

  @override
  void initState() {
    super.initState();
    loadMood();
  }

  Future<void> loadMood() async {
    final savedScore = await LocalStorage.getQuizScore();
    final savedLevel = await LocalStorage.getMentalHealthLevel();

    setState(() {
      // ignore: dead_code
      score = savedScore ?? 0;
      level = savedLevel ?? "Not Checked";
    });
  }

  Color getMoodColor() {
    if (score >= 40) return Colors.teal.shade600;
    if (score >= 32) return Colors.blue.shade600;
    if (score >= 24) return Colors.amber.shade600;
    return Colors.deepOrange.shade400;
  }

  String getMoodMessage() {
    if (score >= 40) {
      return "You're doing great 🌸 Keep nurturing your mind.";
    } else if (score >= 32) {
      return "You're managing well 🌿 A little care goes a long way.";
    } else if (score >= 24) {
      return "Things feel heavy ⚠️ Let's slow down together.";
    } else {
      return "You’re not alone 🚨 Support can really help.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.purple,
        automaticallyImplyLeading: false,
        leading: const SizedBox.shrink(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: logo (left) + Mood of the Day (right)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const MindHugLogo(size: 56),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: getMoodColor(),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mood of the Day',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            level,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "Hello 🌼",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Mood Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [getMoodColor(), getMoodColor().withOpacity(0.7)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    getMoodMessage(),
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Quick Actions
            const Text(
              "Quick Actions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _actionCard(Icons.self_improvement, "Exercises"),
                _actionCard(Icons.book, "Journal"),
                _actionCard(Icons.chat_bubble_outline, "Melo"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(IconData icon, String title) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade100,
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: Colors.purple),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
