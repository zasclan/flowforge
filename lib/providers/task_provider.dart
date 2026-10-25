import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/task.dart';

enum TaskView { all, active, dueSoon, overdue, completed }

class TaskProvider extends ChangeNotifier {
  TaskProvider({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
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

  CollectionReference<Map<String, dynamic>>? get _collection {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid).collection('tasks');
  }

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
    final collection = _collection;
    _subscription?.cancel();
    if (collection == null) {
      _tasks = const [];
      notifyListeners();
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    _subscription =
        collection.orderBy('createdAt', descending: true).snapshots().listen(
      (snapshot) {
        _tasks = snapshot.docs
            .map((doc) => Task.fromMap(doc.id, doc.data()))
            .toList();
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
    final collection = _collection;
    final cleanTitle = title.trim();
    if (collection == null) throw StateError('Sign in before creating tasks.');
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
    await collection.add(task.toMap());
  }

  Future<void> setStatus(Task task, TaskStatus status) async {
    final now = DateTime.now();
    await _collection?.doc(task.id).update({
      'status': status.name,
      'isCompleted': status == TaskStatus.completed,
      'completedAt': status == TaskStatus.completed ? now : null,
      'updatedAt': now,
      'schemaVersion': 2,
    });
  }

  Future<void> deleteTask(String taskId) async =>
      _collection?.doc(taskId).delete();
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
