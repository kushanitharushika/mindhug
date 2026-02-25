class CareItem {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final String? reminderTime; // e.g., "08:00 AM"
  
  // New fields for Drink Timer / Counter type items
  final String type; // 'checkbox' or 'counter'
  final int currentProgress;
  final int maxProgress;

  CareItem({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.reminderTime,
    this.type = 'checkbox',
    this.currentProgress = 0,
    this.maxProgress = 1,
  });

  CareItem copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    String? reminderTime,
    String? type,
    int? currentProgress,
    int? maxProgress,
  }) {
    return CareItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderTime: reminderTime ?? this.reminderTime,
      type: type ?? this.type,
      currentProgress: currentProgress ?? this.currentProgress,
      maxProgress: maxProgress ?? this.maxProgress,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'reminderTime': reminderTime,
      'type': type,
      'currentProgress': currentProgress,
      'maxProgress': maxProgress,
    };
  }

  factory CareItem.fromJson(Map<String, dynamic> json) {
    return CareItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['isCompleted'] ?? false,
      reminderTime: json['reminderTime'],
      type: json['type'] ?? 'checkbox',
      currentProgress: json['currentProgress'] ?? 0,
      maxProgress: json['maxProgress'] ?? 1,
    );
  }
}
