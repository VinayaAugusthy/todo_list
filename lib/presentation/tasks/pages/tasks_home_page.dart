import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:todo_list/core/constants/app_colors.dart';
import 'package:todo_list/core/constants/app_strings.dart';
import 'package:todo_list/core/extensions/task_priority_x.dart';
import 'package:todo_list/data/models/task_model.dart';
import 'package:todo_list/data/repositories/tasks_repository.dart';
import 'package:todo_list/presentation/auth/bloc/auth_bloc.dart';
import 'package:todo_list/presentation/common/widgets/app_snackbar.dart';
import 'package:todo_list/presentation/tasks/bloc/tasks_bloc.dart';
import 'package:todo_list/presentation/tasks/pages/add_task_page.dart';

class TasksHomePage extends StatelessWidget {
  const TasksHomePage({super.key, required this.user});

  final User user;

  String _displayName(User user) {
    final name = user.displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final email = user.email?.trim();
    if (email != null && email.contains('@')) return email.split('@').first;
    return AppStrings.userFallback;
  }

  Future<void> _openAddTask(BuildContext context) async {
    final tasksRepository = context.read<TasksRepository>();
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddTaskPage(tasksRepository: tasksRepository),
      ),
    );
    if (added == true && context.mounted) {
      context.read<TasksBloc>().add(const TasksLoadRequested());
    }
  }

  Future<void> _openEditTask(BuildContext context, TaskModel task) async {
    final tasksRepository = context.read<TasksRepository>();
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) =>
            AddTaskPage(tasksRepository: tasksRepository, taskToEdit: task),
      ),
    );
    if (updated == true && context.mounted) {
      context.read<TasksBloc>().add(const TasksLoadRequested());
    }
  }

  Future<void> _confirmDeleteTask(BuildContext context, TaskModel task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.deleteTask),
        content: const Text(AppStrings.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      context.read<TasksBloc>().add(TaskDeleteRequested(task.id));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(AppSnackBar.success(AppStrings.taskDeleted));
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _displayName(user);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.welcomeBack,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),

                        Text(
                          AppStrings.letsGetThingsDone,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: AppColors.primary),
                    tooltip: AppStrings.signOut,
                    onPressed: () {
                      context.read<AuthBloc>().add(
                        const AuthSignOutRequested(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: BlocBuilder<TasksBloc, TasksState>(
                builder: (context, state) => _buildBody(context, state),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddTask(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildBody(BuildContext context, TasksState state) {
    if (state is TasksLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is TasksError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(state.message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    context.read<TasksBloc>().add(const TasksLoadRequested()),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (state is TasksLoaded && state.tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, size: 64),
              const SizedBox(height: 16),
              Text(
                AppStrings.tapToAdd,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    if (state is TasksLoaded && state.tasks.isNotEmpty) {
      final tasks = state.tasks;
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          final priorityColor = task.priority.color;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              isThreeLine: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: task.isCompleted,
                    onChanged: (_) {
                      if (!task.isCompleted) {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            AppSnackBar.success(AppStrings.taskCompleted),
                          );
                      }
                      context.read<TasksBloc>().add(
                        TaskToggleCompletedRequested(task),
                      );
                    },
                    activeColor: AppColors.primary,
                  ),
                  Container(
                    width: 6,
                    height: 34,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              title: Text(
                task.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (task.notes.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      task.notes,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _openEditTask(context, task),
                        tooltip: AppStrings.editTask,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDeleteTask(context, task),
                        tooltip: AppStrings.deleteTask,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }
}
