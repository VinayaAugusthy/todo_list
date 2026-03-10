import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:todo_list/core/constants/app_strings.dart';
import 'package:todo_list/data/models/task_model.dart';
import 'package:todo_list/data/repositories/tasks_repository.dart';
import 'package:todo_list/presentation/common/widgets/app_snackbar.dart';
import 'package:todo_list/presentation/tasks/bloc/add_task_cubit.dart';
import 'package:todo_list/presentation/tasks/widgets/add_task_form.dart';

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
            final msg =
                state.isEditMode ? AppStrings.taskUpdated : AppStrings.taskAdded;
            ScaffoldMessenger.of(context).showSnackBar(AppSnackBar.success(msg));
            Navigator.of(context).pop(true);
          }
          if (state is AddTaskError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(AppSnackBar.error(state.message));
            context.read<AddTaskCubit>().resetToIdle();
          }
        },
        child: AddTaskForm(
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
