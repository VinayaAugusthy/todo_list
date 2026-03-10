import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'firebase_options.dart';
import 'core/constants/app_colors.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/tasks_repository.dart';
import 'presentation/auth/auth_gate.dart';
import 'presentation/auth/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authRepository = AuthRepository();
  final tasksRepository = TasksRepository();

  runApp(
    RepositoryProvider<AuthRepository>.value(
      value: authRepository,
      child: RepositoryProvider<TasksRepository>.value(
        value: tasksRepository,
        child: BlocProvider(
          create: (context) => AuthBloc(authRepository: authRepository)
            ..add(const AuthCheckRequested()),
          child: const MyApp(),
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: AppColors.primary),
          actionsIconTheme: IconThemeData(color: AppColors.primary),
        ),
      ),
      home: const AuthGate(),
    );
  }
}
