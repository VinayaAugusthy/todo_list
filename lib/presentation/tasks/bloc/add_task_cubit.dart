import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/task_model.dart';
import '../../../data/repositories/tasks_repository.dart';

sealed class AddTaskState extends Equatable {
  const AddTaskState({this.priority = TaskPriority.medium});

  final TaskPriority priority;

  @override
  List<Object?> get props => [priority];
}

final class AddTaskIdle extends AddTaskState {
  const AddTaskIdle({super.priority});

  AddTaskIdle copyWith({TaskPriority? priority}) =>
      AddTaskIdle(priority: priority ?? this.priority);
}

final class AddTaskSubmitting extends AddTaskState {
  const AddTaskSubmitting({super.priority});

  AddTaskSubmitting copyWith({TaskPriority? priority}) =>
      AddTaskSubmitting(priority: priority ?? this.priority);
}

final class AddTaskSuccess extends AddTaskState {
  const AddTaskSuccess({super.priority, this.isEditMode = false});
  final bool isEditMode;
  @override
  List<Object?> get props => [priority, isEditMode];
}

final class AddTaskError extends AddTaskState {
  const AddTaskError(this.message, {super.priority});

  final String message;

  @override
  List<Object?> get props => [message, priority];

  AddTaskError copyWith({String? message, TaskPriority? priority}) =>
      AddTaskError(
        message ?? this.message,
        priority: priority ?? this.priority,
      );
}

class AddTaskCubit extends Cubit<AddTaskState> {
  AddTaskCubit({
    required TasksRepository tasksRepository,
    TaskModel? initialTask,
  })  : _tasksRepository = tasksRepository,
        _initialTask = initialTask,
        super(AddTaskIdle(priority: initialTask?.priority ?? TaskPriority.medium));

  final TasksRepository _tasksRepository;
  final TaskModel? _initialTask;

  bool get isEditMode => _initialTask != null;

  void priorityChanged(TaskPriority priority) {
    final current = state;
    if (current is AddTaskIdle) {
      emit(current.copyWith(priority: priority));
    } else if (current is AddTaskSubmitting) {
      emit(current.copyWith(priority: priority));
    } else if (current is AddTaskError) {
      emit(current.copyWith(priority: priority));
    }
  }

  Future<void> submitTask({
    required String title,
    required String notes,
    required TaskPriority priority,
  }) async {
    emit(AddTaskSubmitting(priority: priority));
    try {
      if (_initialTask != null) {
        final updated = _initialTask.copyWith(
          title: title,
          notes: notes,
          priority: priority,
        );
        await _tasksRepository.updateTask(updated);
        emit(AddTaskSuccess(priority: priority, isEditMode: true));
      } else {
        final task = TaskModel(
          id: '',
          title: title,
          notes: notes,
          time: DateTime.now(),
          priority: priority,
        );
        final added = await _tasksRepository.addTask(task);
        if (added != null) {
          emit(const AddTaskSuccess());
        } else {
          emit(AddTaskError('Failed to add task', priority: priority));
        }
      }
    } on TasksRepositoryException catch (e) {
      emit(AddTaskError(e.message, priority: priority));
    } catch (e) {
      emit(AddTaskError(e.toString(), priority: priority));
    }
  }

  void resetToIdle() {
    final current = state;
    if (current is AddTaskError) {
      emit(AddTaskIdle(priority: current.priority));
    }
  }
}
