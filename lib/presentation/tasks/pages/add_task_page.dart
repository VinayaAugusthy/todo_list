import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:todo_list/core/constants/app_colors.dart';
import 'package:todo_list/core/constants/app_strings.dart';
import 'package:todo_list/data/models/task_model.dart';
import 'package:todo_list/data/repositories/tasks_repository.dart';
import 'package:todo_list/presentation/common/widgets/app_text_field.dart';
import 'package:todo_list/presentation/common/widgets/app_snackbar.dart';
import 'package:todo_list/presentation/tasks/bloc/add_task_cubit.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({
    super.key,
    required this.tasksRepository,
    this.taskToEdit,
  });

  final TasksRepository tasksRepository;
  final TaskModel? taskToEdit;

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final task = widget.taskToEdit;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.notes ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit(BuildContext formContext) {
    if (!_formKey.currentState!.validate()) return;
    final cubit = formContext.read<AddTaskCubit>();
    cubit.submitTask(
      title: _titleController.text.trim(),
      notes: _descriptionController.text.trim(),
      priority: cubit.state.priority,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddTaskCubit(
        tasksRepository: widget.tasksRepository,
        initialTask: widget.taskToEdit,
      ),
      child: BlocListener<AddTaskCubit, AddTaskState>(
        listener: (context, state) {
          if (state is AddTaskSuccess) {
            final msg = state.isEditMode
                ? AppStrings.taskUpdated
                : AppStrings.taskAdded;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(AppSnackBar.success(msg));
            Navigator.of(context).pop(true);
          }
          if (state is AddTaskError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(AppSnackBar.error(state.message));
            context.read<AddTaskCubit>().resetToIdle();
          }
        },
        child: _AddTaskForm(
          formKey: _formKey,
          titleController: _titleController,
          descriptionController: _descriptionController,
          onSubmit: _submit,
          isEditMode: widget.taskToEdit != null,
        ),
      ),
    );
  }
}

class _AddTaskForm extends StatelessWidget {
  const _AddTaskForm({
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.onSubmit,
    this.isEditMode = false,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final void Function(BuildContext formContext) onSubmit;
  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AddTaskCubit>().state;
    final isSubmitting = state is AddTaskSubmitting;
    final priority = state.priority;
    final priorityColor = switch (priority) {
      TaskPriority.high => Colors.red,
      TaskPriority.medium => Colors.amber,
      TaskPriority.low => Colors.green,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? AppStrings.editTask : AppStrings.addTask),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            AppTextField(
              controller: titleController,
              hintText: AppStrings.hintTaskTitle,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? AppStrings.pleaseEnterTitle
                  : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: descriptionController,
              hintText: AppStrings.hintTaskDescription,
            ),
            const SizedBox(height: 16),
            const Text(AppStrings.taskPriority),
            const SizedBox(height: 8),
            SegmentedButton<TaskPriority>(
              segments: [
                ButtonSegment(
                  value: TaskPriority.low,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      _PriorityDot(color: Colors.green),
                      SizedBox(width: 8),
                      Text(AppStrings.priorityLow),
                    ],
                  ),
                ),
                ButtonSegment(
                  value: TaskPriority.medium,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      _PriorityDot(color: Colors.amber),
                      SizedBox(width: 8),
                      Text(AppStrings.priorityMedium),
                    ],
                  ),
                ),
                ButtonSegment(
                  value: TaskPriority.high,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      _PriorityDot(color: Colors.red),
                      SizedBox(width: 8),
                      Text(AppStrings.priorityHigh),
                    ],
                  ),
                ),
              ],
              selected: {priority},
              onSelectionChanged: (Set<TaskPriority> selected) {
                context.read<AddTaskCubit>().priorityChanged(selected.first);
              },
              style: ButtonStyle(
                side: WidgetStatePropertyAll(
                  BorderSide(color: priorityColor.withValues(alpha: 0.35)),
                ),
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return priorityColor.withValues(alpha: 0.15);
                  }
                  return null;
                }),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: isSubmitting ? null : () => onSubmit(context),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEditMode ? AppStrings.update : AppStrings.add),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityDot extends StatelessWidget {
  const _PriorityDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
