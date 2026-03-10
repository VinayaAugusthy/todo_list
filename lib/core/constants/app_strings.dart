/// Centralized app string constants.
abstract final class AppStrings {
  AppStrings._();

  // App
  static const String appTitle = 'TaskFlow';

  // Auth – labels & hints
  static const String signin = 'Signin';
  static const String signup = 'Signup';
  static const String signIn = 'Sign In';
  static const String signInWithGoogle = 'Sign in with Google';
  static const String signOut = 'Sign out';
  static const String confirmSignOut = 'Do you want to sign out?';

  static const String hintEmail = 'Enter email';
  static const String hintPassword = 'Enter password';
  static const String hintUsername = 'Enter username';

  // Auth – prompts
  static const String alreadyHaveAccount = 'Already have an account ? ';
  static const String dontHaveAccount = "Don't have an account ? ";

  // Messages
  static const String pleaseFillAllFields = 'Please fill all the fields';
  static const String welcomeUser = 'Welcome, ';
  static const String userFallback = 'User';
  static const String sessionPersistsMessage =
      'You are signed in. Your session persists across app restarts.';
  static const String welcomeBack = 'Welcome back,';
  static const String letsGetThingsDone = 'Let’s get things done today';
  static const String googleLogoAsset = 'assets/images/google_logo.png';

  // Tasks
  static const String addTask = 'Add Task';
  static const String taskTitle = 'Title';
  static const String taskDescription = 'Description';
  static const String taskNotes = 'Notes';
  static const String taskTime = 'Time';
  static const String taskPriority = 'Priority';
  static const String hintTaskTitle = 'Enter task title';
  static const String hintTaskDescription = 'Enter description or notes';
  static const String priorityLow = 'Low';
  static const String priorityMedium = 'Medium';
  static const String priorityHigh = 'High';
  static const String add = 'Add';
  static const String noTasks = 'No tasks yet';
  static const String tapToAdd = 'Tap + to add a task';
  static const String taskAdded = 'Task added';
  static const String failedToAddTask = 'Failed to add task';
  static const String pleaseEnterTitle = 'Please enter a title';
  static const String editTask = 'Edit Task';
  static const String update = 'Update';
  static const String taskUpdated = 'Task updated';
  static const String deleteTask = 'Delete task';
  static const String confirmDelete = 'Delete this task?';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String taskDeleted = 'Task deleted';
  static const String taskCompleted = 'Task marked as completed';
  static const String retry = 'Retry';
}
