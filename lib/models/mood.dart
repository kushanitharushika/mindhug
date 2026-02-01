import 'package:flutter/material.dart';

enum MoodType {
  happy,
  sad,
  stressed,
  calm,
  energetic,
  tired,
  neutral
}

class Mood {
  final MoodType type;
  final String label;
  final Color color;
  final IconData icon;

  const Mood({
    required this.type,
    required this.label,
    required this.color,
    required this.icon,
  });

  static List<Mood> getAll() {
    return [
      const Mood(
        type: MoodType.happy,
        label: "Happy",
        color: Colors.orange,
        icon: Icons.sentiment_very_satisfied,
      ),
      const Mood(
        type: MoodType.calm,
        label: "Calm",
        color: Colors.teal,
        icon: Icons.spa,
      ),
      const Mood(
        type: MoodType.energetic,
        label: "Energetic",
        color: Colors.yellow,
        icon: Icons.bolt,
      ),
      const Mood(
        type: MoodType.neutral,
        label: "Okay",
        color: Colors.blueGrey,
        icon: Icons.sentiment_neutral,
      ),
      const Mood(
        type: MoodType.sad,
        label: "Sad",
        color: Colors.blue,
        icon: Icons.sentiment_dissatisfied,
      ),
      const Mood(
        type: MoodType.stressed,
        label: "Stressed",
        color: Colors.redAccent,
        icon: Icons.warning_amber_rounded,
      ),
      const Mood(
        type: MoodType.tired,
        label: "Tired",
        color: Colors.purple,
        icon: Icons.bedtime,
      ),
    ];
  }
}
