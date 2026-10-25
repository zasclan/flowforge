import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

abstract interface class TaskRepository {
  Stream<List<Task>> watchTasks();
  Future<void> addTask(Task task);
  Future<void> updateStatus(String taskId, TaskStatus status, DateTime now);
  Future<void> deleteTask(String taskId);
}

class FirestoreTaskRepository implements TaskRepository {
  FirestoreTaskRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _collection() {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Sign in before accessing tasks.');
    return _firestore.collection('users').doc(user.uid).collection('tasks');
  }

  @override
  Stream<List<Task>> watchTasks() => _collection()
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((document) => Task.fromMap(document.id, document.data()))
          .toList());

  @override
  Future<void> addTask(Task task) => _collection().add(task.toMap());

  @override
  Future<void> updateStatus(String taskId, TaskStatus status, DateTime now) =>
      _collection().doc(taskId).update({
        'status': status.name,
        'isCompleted': status == TaskStatus.completed,
        'completedAt': status == TaskStatus.completed ? now : null,
        'updatedAt': now,
        'schemaVersion': 2,
      });

  @override
  Future<void> deleteTask(String taskId) => _collection().doc(taskId).delete();
}
