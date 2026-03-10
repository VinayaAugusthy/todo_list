import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:todo_list/core/constants/app_colors.dart';
import 'package:todo_list/core/constants/app_strings.dart';
import 'package:todo_list/core/extensions/task_priority_x.dart';
import 'package:todo_list/data/models/task_model.dart';
import 'package:todo_list/presentation/common/widgets/app_text_field.dart';
import 'package:todo_list/presentation/tasks/bloc/add_task_cubit.dart';
import 'package:todo_list/presentation/tasks/widgets/priority_dot.dart';

class AddTaskForm extends StatelessWidget {
  const AddTaskForm({
    super.key,
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
    final priorityColor = priority.color;

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
              segments: const [
                ButtonSegment(
                  value: TaskPriority.low,
                  icon: PriorityDot(color: Colors.green),
                  label: Text(AppStrings.priorityLow),
                ),
                ButtonSegment(
                  value: TaskPriority.medium,
                  icon: PriorityDot(color: Colors.amber),
                  label: Text(AppStrings.priorityMedium),
                ),
                ButtonSegment(
                  value: TaskPriority.high,
                  icon: PriorityDot(color: Colors.red),
                  label: Text(AppStrings.priorityHigh),
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
