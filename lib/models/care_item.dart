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
  final int minTarget; // Minimum target allowed when editing
  final bool isDeletable;
  
  // Custom Time Period
  final String? startTime; // "10:00" or similar
  final String? endTime;   // "12:00" or similar

  CareItem({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.reminderTime,
    this.type = 'checkbox',
    this.currentProgress = 0,
    this.maxProgress = 1,
    this.minTarget = 1,
    this.isDeletable = true,
    this.startTime,
    this.endTime,
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
    int? minTarget,
    bool? isDeletable,
    String? startTime,
    String? endTime,
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
      minTarget: minTarget ?? this.minTarget,
      isDeletable: isDeletable ?? this.isDeletable,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
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
      'minTarget': minTarget,
      'isDeletable': isDeletable,
      'startTime': startTime,
      'endTime': endTime,
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
      minTarget: json['minTarget'] ?? 1,
      isDeletable: json['isDeletable'] ?? true,
      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }
}
