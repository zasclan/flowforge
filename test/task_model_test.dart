import 'package:test/test.dart';
import 'package:task_app/models/task.dart';

void main() {
  group('Task model', () {
    test('reads legacy completed tasks without losing compatibility', () {
      final task = Task.fromMap('legacy', {
        'title': 'Migrated task',
        'description': '',
        'isCompleted': true,
        'createdAt': '2026-01-01T00:00:00.000Z',
      });
      expect(task.status, TaskStatus.completed);
      expect(task.isCompleted, isTrue);
      expect(task.priority, TaskPriority.medium);
    });

    test('serializes schema version and workflow fields', () {
      final now = DateTime.utc(2026, 1, 1);
      final task = Task(
          id: '1',
          title: 'Write report',
          description: 'Draft findings',
          priority: TaskPriority.high,
          status: TaskStatus.inProgress,
          createdAt: now,
          updatedAt: now,
          tags: const ['research']);
      final map = task.toMap();
      expect(map['schemaVersion'], 2);
      expect(map['priority'], 'high');
      expect(map['status'], 'inProgress');
      expect(map['tags'], ['research']);
    });
  });
}
