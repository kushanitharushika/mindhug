// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import '../../core/storage/local_storage.dart';
import '../../widgets/app_scaffold.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  int score = 0;
  String level = "";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final savedScore = await LocalStorage.getQuizScore();
    final savedLevel = await LocalStorage.getMentalHealthLevel();

    setState(() {
      score = savedScore ?? 0;
      level = savedLevel ?? "";
    });
  }

  List<Map<String, String>> getExercises() {
    if (score >= 40) {
      return [
        {
          "title": "Gratitude Reflection",
          "desc": "List 3 things you’re grateful for today.",
        },
        {
          "title": "Mindful Breathing",
          "desc": "Slowly breathe in and out for 3 minutes.",
        },
        {
          "title": "Daily Stretching",
          "desc": "5 minutes of full body stretches to energize.",
        },
        {
          "title": "Positive Affirmations",
          "desc": "Repeat 3 positive statements to yourself.",
        },
        {
          "title": "Nature Walk",
          "desc": "Spend 10 minutes walking outside, notice surroundings.",
        },
      ];
    } else if (score >= 32) {
      return [
        {"title": "4-7-8 Breathing", "desc": "Inhale 4s, hold 7s, exhale 8s."},
        {"title": "Journaling", "desc": "Write down your thoughts freely."},
        {
          "title": "Music Pause",
          "desc": "Listen to calming music for 5 minutes.",
        },
        {
          "title": "Mini Meditation",
          "desc": "Sit quietly and focus on your breath for 3 mins.",
        },
        {
          "title": "Gentle Stretching",
          "desc": "Release tension from neck and shoulders.",
        },
      ];
    } else if (score >= 24) {
      return [
        {
          "title": "5-4-3-2-1 Grounding",
          "desc": "Name 5 things you see, 4 feel, 3 hear.",
        },
        {"title": "Body Relaxation", "desc": "Relax each muscle group slowly."},
        {
          "title": "Deep Breathing",
          "desc": "Inhale for 4s, exhale for 6s, repeat 5 times.",
        },
        {
          "title": "Soothing Visualization",
          "desc": "Imagine a safe, calm place for 5 minutes.",
        },
        {
          "title": "Stretch & Release",
          "desc": "Gentle stretching for arms, back, and legs.",
        },
      ];
    } else {
      return [
        {
          "title": "Calm Breathing",
          "desc": "Breathe gently and slowly for 3 minutes.",
        },
        {
          "title": "Reach Out",
          "desc": "Consider talking to someone you trust.",
        },
        {
          "title": "Grounding Exercise",
          "desc": "Focus on your senses to feel present.",
        },
        {
          "title": "Guided Meditation",
          "desc": "Listen to a short guided meditation.",
        },
        {
          "title": "Gentle Movement",
          "desc": "Simple stretching or walking to release tension.",
        },
      ];
    }
  }

  Color getColor() {
    if (score >= 40) return Colors.teal.shade600;
    if (score >= 32) return Colors.blue.shade600;
    if (score >= 24) return Colors.amber.shade600;
    return Colors.deepOrange.shade400;
  }

  @override
  Widget build(BuildContext context) {
    final exercises = getExercises();

    return AppScaffold(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top section: level + icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  level.isEmpty ? 'Exercises' : level,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: getColor(),
                  ),
                ),
                Icon(Icons.self_improvement, color: getColor(), size: 26),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              "Recommended for you",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 6),
            // Exercise list
            Expanded(
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        title: Text(
                          exercise["title"]!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          exercise["desc"]!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                        trailing: Icon(
                          Icons.play_circle_fill,
                          color: getColor(),
                          size: 24,
                        ),
                        onTap: () {},
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
