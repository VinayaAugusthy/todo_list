import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:todo_list/data/repositories/tasks_repository.dart';
import 'package:todo_list/presentation/auth/bloc/auth_bloc.dart';
import 'package:todo_list/presentation/auth/pages/sign_in_page.dart';
import 'package:todo_list/presentation/tasks/bloc/tasks_bloc.dart';
import 'package:todo_list/presentation/tasks/pages/tasks_home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return BlocProvider(
            create: (context) => TasksBloc(
              tasksRepository: context.read<TasksRepository>(),
            )..add(const TasksLoadRequested()),
            child: TasksHomePage(
              key: ValueKey('home_${state.user.uid}'),
              user: state.user,
            ),
          );
        }
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const SigninScreen();
      },
    );
  }
}
