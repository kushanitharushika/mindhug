// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import '../../core/storage/local_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/mindhug_logo.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final appBarColor = isDark ? const Color(0xFF121212) : Colors.purple.shade50;

    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: appBarColor,
        toolbarHeight: 90,
        elevation: 0,
        title: MindHugLogo(size: 40),
      ),
      body: Container(
         decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [const Color(0xFF121212), Colors.black],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.purple.shade50, Colors.white],
                ),
        ),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
          children: [
              // Top section: level + icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    level.isEmpty ? 'Exercises' : level,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: getColor(),
                    ),
                  ),
                  Icon(Icons.self_improvement, color: getColor(), size: 28),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Recommended for you",
                style: TextStyle(fontSize: 14, color: subTextColor),
              ),
              const SizedBox(height: 16),
              
              // Exercise list rendered as children of Column
              ...exercises.map((exercise) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Card(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
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
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: textColor,
                        ),
                      ),
                      subtitle: Text(
                        exercise["desc"]!,
                        style: TextStyle(
                          fontSize: 13,
                          color: subTextColor,
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
              }).toList(),
            ],
        ),
      ),
    );
  }
}
