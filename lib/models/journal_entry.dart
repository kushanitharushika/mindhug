import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  final String? id; // Firestore Document ID
  final String userId;
  final String? title;
  final String text;
  final String mood;
  final List<String> tags;
  final List<String> images;
  final DateTime date;

  JournalEntry({
    this.id,
    required this.userId,
    this.title,
    required this.text,
    required this.mood,
    this.tags = const [],
    this.images = const [],
    DateTime? date,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'text': text,
      'mood': mood,
      'tags': tags,
      'images': images,
      'date': date.toIso8601String(),
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json, {String? id}) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) {
        return date.toDate();
      } else if (date is String) {
        return DateTime.parse(date);
      }
      return DateTime.now();
    }

    return JournalEntry(
      id: id,
      userId: json['userId'] ?? '',
      title: json['title'],
      text: json['text'] ?? '',
      mood: json['mood'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      date: parseDate(json['date']),
    );
  }
}
