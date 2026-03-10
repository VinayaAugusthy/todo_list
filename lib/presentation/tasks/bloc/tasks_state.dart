part of 'tasks_bloc.dart';

@immutable
sealed class TasksState extends Equatable {
  const TasksState();

  @override
  List<Object?> get props => [];
}

final class TasksInitial extends TasksState {
  const TasksInitial();
}

final class TasksLoading extends TasksState {
  const TasksLoading();
}

final class TasksLoaded extends TasksState {
  const TasksLoaded(this.tasks);

  final List<TaskModel> tasks;

  @override
  List<Object?> get props => [tasks];
}

final class TasksError extends TasksState {
  const TasksError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
