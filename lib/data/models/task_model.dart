import 'package:equatable/equatable.dart';

enum TaskPriority { low, medium, high }

class TaskModel extends Equatable {
  const TaskModel({
    required this.id,
    required this.title,
    required this.notes,
    required this.time,
    required this.priority,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String notes;
  final DateTime time;
  final TaskPriority priority;
  final bool isCompleted;

  Map<String, dynamic> toJson() => {
    'title': title,
    'notes': notes,
    'time': time.toIso8601String(),
    'priority': priority.name,
    'isCompleted': isCompleted,
  };

  static TaskModel fromJson(String id, Map<String, dynamic> json) {
    return TaskModel(
      id: id,
      title: json['title'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      time: _parseTime(json['time']),
      priority: _parsePriority(json['priority']),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  static DateTime _parseTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      final d = DateTime.tryParse(value);
      return d ?? DateTime.now();
    }
    return DateTime.now();
  }

  static TaskPriority _parsePriority(dynamic value) {
    if (value is String) {
      switch (value) {
        case 'low':
          return TaskPriority.low;
        case 'medium':
          return TaskPriority.medium;
        case 'high':
          return TaskPriority.high;
      }
    }
    return TaskPriority.medium;
  }

  @override
  List<Object?> get props => [id, title, notes, time, priority, isCompleted];

  TaskModel copyWith({
    String? id,
    String? title,
    String? notes,
    DateTime? time,
    TaskPriority? priority,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      time: time ?? this.time,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
