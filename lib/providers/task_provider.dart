import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';

enum TaskView { all, active, dueSoon, overdue, completed }

class TaskProvider extends ChangeNotifier {
  TaskProvider({TaskRepository? repository})
      : _repository = repository ?? FirestoreTaskRepository();

  final TaskRepository _repository;
  StreamSubscription<List<Task>>? _subscription;
  List<Task> _tasks = const [];
  bool _isLoading = false;
  String? _error;
  String _query = '';
  TaskView _view = TaskView.all;

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  TaskView get view => _view;
  int get totalCount => _tasks.length;
  int get completedCount => _tasks.where((task) => task.isCompleted).length;
  int get activeCount => totalCount - completedCount;
  int get overdueCount => _tasks.where((task) => task.isOverdue).length;
  double get completionRate =>
      totalCount == 0 ? 0 : completedCount / totalCount;

  List<Task> get visibleTasks {
    final now = DateTime.now();
    final horizon = now.add(const Duration(days: 7));
    final term = _query.trim().toLowerCase();
    return _tasks.where((task) {
      final matches = term.isEmpty ||
          task.title.toLowerCase().contains(term) ||
          task.description.toLowerCase().contains(term) ||
          task.tags.any((tag) => tag.toLowerCase().contains(term));
      if (!matches) return false;
      switch (_view) {
        case TaskView.active:
          return !task.isCompleted;
        case TaskView.dueSoon:
          return !task.isCompleted &&
              task.dueDate != null &&
              !task.dueDate!.isBefore(now) &&
              task.dueDate!.isBefore(horizon);
        case TaskView.overdue:
          return task.isOverdue;
        case TaskView.completed:
          return task.isCompleted;
        case TaskView.all:
          return true;
      }
    }).toList();
  }

  void loadTasks() {
    _subscription?.cancel();
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _subscription = _repository.watchTasks().listen(
      (tasks) {
        _tasks = tasks;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        _error = 'Tasks could not be synchronized. Check your connection.';
        notifyListeners();
      },
    );
    } on StateError catch (error) {
      _isLoading = false;
      _error = error.message;
      notifyListeners();
    }
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setView(TaskView value) {
    _view = value;
    notifyListeners();
  }

  Future<void> addTask({
    required String title,
    String description = '',
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
    List<String> tags = const [],
  }) async {
    final cleanTitle = title.trim();
    if (cleanTitle.length < 3) {
      throw ArgumentError('Use at least 3 characters.');
    }
    final now = DateTime.now();
    final task = Task(
      id: '',
      title: cleanTitle,
      description: description.trim(),
      priority: priority,
      status: TaskStatus.todo,
      dueDate: dueDate,
      tags: tags
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toSet()
          .toList(),
      createdAt: now,
      updatedAt: now,
    );
    await _repository.addTask(task);
  }

  Future<void> setStatus(Task task, TaskStatus status) async {
    final now = DateTime.now();
    await _repository.updateStatus(task.id, status, now);
  }

  Future<void> deleteTask(String taskId) async =>
      _repository.deleteTask(taskId);
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
