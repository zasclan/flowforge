import 'dart:convert';

class Task {
  final String id;
  String title;
  bool isCompleted;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
  });

  // Convert Task to JSON map for SharedPreferences storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
  };

  // Create Task from JSON map
  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    isCompleted: json['isCompleted'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
  );

  // Encode list of tasks to JSON string
  static String encodeList(List<Task> tasks) =>
      jsonEncode(tasks.map((t) => t.toJson()).toList());

  // Decode JSON string to list of tasks
  static List<Task> decodeList(String jsonStr) {
    final List decoded = jsonDecode(jsonStr);
    return decoded.map((item) => Task.fromJson(item)).toList();
  }
}
