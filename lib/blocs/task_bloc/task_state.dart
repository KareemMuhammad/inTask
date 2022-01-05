import 'package:flutter/material.dart';
import 'package:taskaty/models/task_model.dart';

@immutable
abstract class MyTaskState {}

class TaskInitial extends MyTaskState{}

class TaskFailure extends MyTaskState{}

class TaskUpdated extends MyTaskState{}

class TaskNotUpdated extends MyTaskState{}

class TaskLoading extends MyTaskState{}

class TaskLoaded extends MyTaskState{
  final List<MyTask> tasks;

  TaskLoaded(this.tasks);
}

class SingleTaskLoaded extends MyTaskState{
  final MyTask task;

  SingleTaskLoaded(this.task);
}