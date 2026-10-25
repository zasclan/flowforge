enum TaskPriority { low, medium, high, urgent }

enum TaskStatus { todo, inProgress, completed }

class Task {
  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? dueDate;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.tags = const [],
    this.completedAt,
  });

  bool get isCompleted => status == TaskStatus.completed;
  bool get isOverdue =>
      dueDate != null && !isCompleted && dueDate!.isBefore(DateTime.now());

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'priority': priority.name,
        'status': status.name,
        'dueDate': dueDate,
        'tags': tags,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'completedAt': completedAt,
        'schemaVersion': 2,
      };

  factory Task.fromMap(String id, Map<String, dynamic> map) {
    DateTime readDate(dynamic value, DateTime fallback) {
      if (value == null) return fallback;
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value) ?? fallback;
      try {
        return value.toDate() as DateTime;
      } catch (_) {
        return fallback;
      }
    }

    DateTime? readOptionalDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      try {
        return value.toDate() as DateTime;
      } catch (_) {
        return null;
      }
    }

    final now = DateTime.now();
    final legacyCompleted = map['isCompleted'] == true;
    return Task(
      id: id,
      title: (map['title'] as String? ?? '').trim(),
      description: (map['description'] as String? ?? '').trim(),
      priority: TaskPriority.values.firstWhere(
        (value) => value.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (value) => value.name == map['status'],
        orElse: () => legacyCompleted ? TaskStatus.completed : TaskStatus.todo,
      ),
      dueDate: readOptionalDate(map['dueDate']),
      tags: List<String>.from(map['tags'] as List? ?? const []),
      createdAt: readDate(map['createdAt'], now),
      updatedAt: readDate(map['updatedAt'], now),
      completedAt: readOptionalDate(map['completedAt']),
    );
  }
}
