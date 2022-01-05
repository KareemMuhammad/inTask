import 'package:flutter/material.dart';
import 'package:taskaty/models/task_model.dart';

@immutable
abstract class MyUpcomingTaskState {}

class UpTaskInitial extends MyUpcomingTaskState{}

class UpTaskFailure extends MyUpcomingTaskState{}

class UpTaskLoading extends MyUpcomingTaskState{}

class UpcomingTasksLoaded extends MyUpcomingTaskState{
  final List<MyTask> upTasks;

  UpcomingTasksLoaded(this.upTasks);
}
