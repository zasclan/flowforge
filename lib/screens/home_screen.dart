import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.read<TaskProvider>().loadTasks());
  }

  Future<void> _createTask() async {
    final title = TextEditingController();
    final description = TextEditingController();
    final tags = TextEditingController();
    TaskPriority priority = TaskPriority.medium;
    DateTime? dueDate;
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 8, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Plan a task',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),
              TextField(
                  controller: title,
                  autofocus: true,
                  decoration: const InputDecoration(
                      labelText: 'Title',
                      prefixIcon: Icon(Icons.task_alt_rounded))),
              const SizedBox(height: 12),
              TextField(
                  controller: description,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'Description', alignLabelWithHint: true)),
              const SizedBox(height: 12),
              TextField(
                  controller: tags,
                  decoration: const InputDecoration(
                      labelText: 'Tags', hintText: 'study, mobile, urgent')),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskPriority>(
                initialValue: priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: TaskPriority.values
                    .map((value) => DropdownMenuItem(
                        value: value, child: Text(value.name.toUpperCase())))
                    .toList(),
                onChanged: (value) =>
                    setSheetState(() => priority = value ?? priority),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final selected = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 730)));
                  if (selected != null) {
                    setSheetState(() => dueDate = selected);
                  }
                },
                icon: const Icon(Icons.event_rounded),
                label: Text(dueDate == null
                    ? 'Set due date'
                    : 'Due ${_date(dueDate!)}'),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () async {
                  try {
                    await context.read<TaskProvider>().addTask(
                          title: title.text,
                          description: description.text,
                          priority: priority,
                          dueDate: dueDate,
                          tags: tags.text.split(','),
                        );
                    if (context.mounted) Navigator.pop(context, true);
                  } catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error.toString())));
                    }
                  }
                },
                child: const Text('Create task'),
              ),
            ]),
          ),
        ),
      ),
    );
    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task added to your workspace.')));
    }
  }

  static String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(builder: (context, model, _) {
      final tasks = model.visibleTasks;
      return Scaffold(
        appBar: AppBar(
          title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FlowForge',
                    style: TextStyle(fontWeight: FontWeight.w900)),
                Text('Personal execution workspace',
                    style:
                        TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
              ]),
          actions: [
            IconButton(
                tooltip: 'Sign out',
                icon: const Icon(Icons.logout_rounded),
                onPressed: () => context.read<AuthProvider>().logout()),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: _createTask,
            icon: const Icon(Icons.add_rounded),
            label: const Text('New task')),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => model.loadTasks(),
            child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: [
                  _Overview(model: model),
                  const SizedBox(height: 18),
                  TextField(
                    onChanged: model.setQuery,
                    decoration: const InputDecoration(
                        hintText: 'Search tasks, notes or tags',
                        prefixIcon: Icon(Icons.search_rounded)),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        children: TaskView.values
                            .map((view) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                      label: Text(_viewLabel(view)),
                                      selected: model.view == view,
                                      onSelected: (_) => model.setView(view)),
                                ))
                            .toList()),
                  ),
                  const SizedBox(height: 16),
                  if (model.error != null)
                    _MessageCard(message: model.error!, color: Colors.red),
                  if (model.isLoading && model.tasks.isEmpty)
                    const Center(
                        child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator())),
                  if (!model.isLoading && tasks.isEmpty) const _EmptyState(),
                  ...tasks.map((task) => _TaskCard(task: task)),
                ]),
          ),
        ),
      );
    });
  }

  static String _viewLabel(TaskView view) => switch (view) {
        TaskView.all => 'All',
        TaskView.active => 'Active',
        TaskView.dueSoon => 'Due soon',
        TaskView.overdue => 'Overdue',
        TaskView.completed => 'Completed',
      };
}

class _Overview extends StatelessWidget {
  const _Overview({required this.model});
  final TaskProvider model;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xff0f172a), Color(0xff1d4ed8)]),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Execution overview',
              style: TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('${(model.completionRate * 100).round()}% complete',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          Row(children: [
            _Metric(label: 'Active', value: model.activeCount),
            _Metric(label: 'Completed', value: model.completedCount),
            _Metric(label: 'Overdue', value: model.overdueCount),
          ]),
        ]),
      );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final int value;
  @override
  Widget build(BuildContext context) => Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$value',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900)),
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ]));
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});
  final Task task;
  @override
  Widget build(BuildContext context) {
    final color = switch (task.priority) {
      TaskPriority.low => Colors.green,
      TaskPriority.medium => Colors.blue,
      TaskPriority.high => Colors.orange,
      TaskPriority.urgent => Colors.red
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Checkbox(
              value: task.isCompleted,
              onChanged: (_) => context.read<TaskProvider>().setStatus(task,
                  task.isCompleted ? TaskStatus.todo : TaskStatus.completed)),
          const SizedBox(width: 8),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Expanded(
                      child: Text(task.title,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null))),
                  Container(
                      width: 9,
                      height: 9,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle)),
                ]),
                if (task.description.isNotEmpty)
                  Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(task.description,
                          maxLines: 2, overflow: TextOverflow.ellipsis)),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 6, children: [
                  if (task.dueDate != null)
                    _Tag(
                        icon: Icons.event_rounded,
                        text: _HomeScreenState._date(task.dueDate!),
                        danger: task.isOverdue),
                  _Tag(icon: Icons.flag_rounded, text: task.priority.name),
                  ...task.tags
                      .take(2)
                      .map((tag) => _Tag(icon: Icons.tag_rounded, text: tag)),
                ]),
              ])),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                context.read<TaskProvider>().deleteTask(task.id);
              }
              if (value == 'progress') {
                context
                    .read<TaskProvider>()
                    .setStatus(task, TaskStatus.inProgress);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'progress', child: Text('Mark in progress')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ]),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.text, this.danger = false});
  final IconData icon;
  final String text;
  final bool danger;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
            color: danger ? Colors.red.shade50 : const Color(0xfff1f5f9),
            borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: danger ? Colors.red : Colors.blueGrey),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: danger ? Colors.red : Colors.blueGrey))
        ]),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 56),
        child: Column(children: [
          Icon(Icons.inbox_rounded, size: 52, color: Colors.blueGrey),
          SizedBox(height: 12),
          Text('No matching tasks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          SizedBox(height: 6),
          Text('Create a task or change the current filter.')
        ]),
      );
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message, required this.color});
  final String message;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(12)),
      child: Text(message, style: TextStyle(color: color)));
}
