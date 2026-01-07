class JournalEntry {
  final String? title;
  final String text;
  final String mood;
  final List<String> tags;
  final List<String> images;
  final DateTime date;

  JournalEntry({
    this.title,
    required this.text,
    required this.mood,
    this.tags = const [],
    this.images = const [],
    DateTime? date,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'text': text,
      'mood': mood,
      'tags': tags,
      'images': images,
      'date': date.toIso8601String(),
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      title: json['title'],
      text: json['text'],
      mood: json['mood'],
      tags: List<String>.from(json['tags'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      date: DateTime.parse(json['date']),
    );
  }
}
