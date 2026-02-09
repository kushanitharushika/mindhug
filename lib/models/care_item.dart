class CareItem {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final String? reminderTime; // e.g., "08:00 AM"

  CareItem({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.reminderTime,
  });

  CareItem copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    String? reminderTime,
  }) {
    return CareItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'reminderTime': reminderTime,
    };
  }

  factory CareItem.fromJson(Map<String, dynamic> json) {
    return CareItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['isCompleted'] ?? false,
      reminderTime: json['reminderTime'],
    );
  }
}
