part of 'tasks_bloc.dart';

@immutable
sealed class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

final class TasksLoadRequested extends TasksEvent {
  const TasksLoadRequested();
}

final class TaskDeleteRequested extends TasksEvent {
  const TaskDeleteRequested(this.taskId);
  final String taskId;
  @override
  List<Object?> get props => [taskId];
}

final class TaskToggleCompletedRequested extends TasksEvent {
  const TaskToggleCompletedRequested(this.task);
  final TaskModel task;
  @override
  List<Object?> get props => [task];
}
