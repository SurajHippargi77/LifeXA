// Placeholder task model.
// Replace with real API-backed model when task CRUD backend is implemented.
enum TaskStatus { pending, completed }

class TaskModel {
  final String id;
  final String title;
  final String? timeLabel;
  final TaskStatus status;

  const TaskModel({
    required this.id,
    required this.title,
    this.timeLabel,
    this.status = TaskStatus.pending,
  });
}
