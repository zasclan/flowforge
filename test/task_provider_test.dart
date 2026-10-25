import 'dart:async';
import 'package:test/test.dart';
import 'package:task_app/models/task.dart';
import 'package:task_app/providers/task_provider.dart';
import 'package:task_app/repositories/task_repository.dart';

class FakeTaskRepository implements TaskRepository {
  final controller = StreamController<List<Task>>.broadcast();
  final added = <Task>[];
  final deleted = <String>[];
  final statusChanges = <(String, TaskStatus)>[];

  @override
  Stream<List<Task>> watchTasks() => controller.stream;
  @override
  Future<void> addTask(Task task) async => added.add(task);
  @override
  Future<void> deleteTask(String taskId) async => deleted.add(taskId);
  @override
  Future<void> updateStatus(String taskId, TaskStatus status, DateTime now) async =>
      statusChanges.add((taskId, status));
  Future<void> close() => controller.close();
}

Task makeTask(String id, String title, {TaskStatus status = TaskStatus.todo, List<String> tags = const []}) {
  final now = DateTime(2026, 1, 1);
  return Task(id: id, title: title, description: '', priority: TaskPriority.medium, status: status, createdAt: now, updatedAt: now, tags: tags);
}

void main() {
  late FakeTaskRepository repository;
  late TaskProvider provider;

  setUp(() {
    repository = FakeTaskRepository();
    provider = TaskProvider(repository: repository)..loadTasks();
  });

  tearDown(() async {
    provider.dispose();
    await repository.close();
  });

  test('derives counts and completion rate from repository stream', () async {
    repository.controller.add([makeTask('1', 'Plan sprint'), makeTask('2', 'Ship release', status: TaskStatus.completed)]);
    await Future<void>.delayed(Duration.zero);
    expect(provider.totalCount, 2);
    expect(provider.activeCount, 1);
    expect(provider.completedCount, 1);
    expect(provider.completionRate, .5);
  });

  test('filters tasks by text, tags, and workflow view', () async {
    repository.controller.add([makeTask('1', 'Plan sprint', tags: ['work']), makeTask('2', 'Buy milk', status: TaskStatus.completed)]);
    await Future<void>.delayed(Duration.zero);
    provider.setQuery('work');
    expect(provider.visibleTasks.single.id, '1');
    provider.setQuery('');
    provider.setView(TaskView.completed);
    expect(provider.visibleTasks.single.id, '2');
  });

  test('validates titles before sending commands to repository', () async {
    expect(() => provider.addTask(title: 'x'), throwsArgumentError);
    await provider.addTask(title: '  Prepare release  ', tags: [' work ', 'work']);
    expect(repository.added.single.title, 'Prepare release');
    expect(repository.added.single.tags, ['work']);
  });

  test('forwards status and delete commands through repository boundary', () async {
    final item = makeTask('42', 'Review alerts');
    await provider.setStatus(item, TaskStatus.inProgress);
    await provider.deleteTask(item.id);
    expect(repository.statusChanges, [('42', TaskStatus.inProgress)]);
    expect(repository.deleted, ['42']);
  });
}
