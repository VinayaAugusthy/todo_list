import 'package:flutter/material.dart';

import 'package:todo_list/data/models/task_model.dart';

extension TaskPriorityX on TaskPriority {
  Color get color => switch (this) {
        TaskPriority.high => Colors.red,
        TaskPriority.medium => Colors.amber,
        TaskPriority.low => Colors.green,
      };
}

