import 'package:flutter/material.dart';
import 'package:cloud_firestore/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get tasks => _tasks;
  bool get isLoading => _isLoading;

  void loadTasks() {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .snapshots()
        .listen((snapshot) {
      _tasks = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'title': doc.data()['title'] ?? '',
          'description': doc.data()['description'] ?? '',
          'isCompleted': doc.data()['isCompleted'] ?? false,
        };
      }).toList();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addTask(String title, String description) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).collection('tasks').add({
      'title': title,
      'description': description,
      'isCompleted': false,
      'createdAt': DateTime.now(),
    });
  }

  Future<void> toggleTask(String taskId, bool currentStatus) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .doc(taskId)
        .update({'isCompleted': !currentStatus});
  }

  Future<void> deleteTask(String taskId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }
}
