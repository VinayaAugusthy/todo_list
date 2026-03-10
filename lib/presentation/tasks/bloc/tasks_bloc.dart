// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../data/models/task_model.dart';
import '../../../data/repositories/tasks_repository.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  TasksBloc({required TasksRepository tasksRepository})
    : _tasksRepository = tasksRepository,
      super(const TasksInitial()) {
    on<TasksLoadRequested>(_onTasksLoadRequested);
    on<TaskDeleteRequested>(_onTaskDeleteRequested);
    on<TaskToggleCompletedRequested>(_onTaskToggleCompletedRequested);
  }

  final TasksRepository _tasksRepository;

  Future<void> _loadAndEmit(Emitter<TasksState> emit) async {
    final tasks = await _tasksRepository.getTasks();
    emit(TasksLoaded(tasks));
  }

  Future<void> _onTasksLoadRequested(
    TasksLoadRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(const TasksLoading());
    try {
      final tasks = await _tasksRepository.getTasks();
      emit(TasksLoaded(tasks));
    } on TasksRepositoryException catch (e) {
      emit(TasksError(e.message));
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  Future<void> _onTaskDeleteRequested(
    TaskDeleteRequested event,
    Emitter<TasksState> emit,
  ) async {
    try {
      await _tasksRepository.deleteTask(event.taskId);
      emit(const TasksLoading());
      await _loadAndEmit(emit);
    } on TasksRepositoryException catch (e) {
      emit(TasksError(e.message));
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  Future<void> _onTaskToggleCompletedRequested(
    TaskToggleCompletedRequested event,
    Emitter<TasksState> emit,
  ) async {
    try {
      await _tasksRepository.updateTask(
        event.task.copyWith(isCompleted: !event.task.isCompleted),
      );
      emit(const TasksLoading());
      await _loadAndEmit(emit);
    } on TasksRepositoryException catch (e) {
      emit(TasksError(e.message));
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }
}
