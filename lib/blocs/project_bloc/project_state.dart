import 'package:flutter/material.dart';
import 'package:taskaty/models/project_model.dart';

@immutable
abstract class ProjectState {}

class ProjectInitial extends ProjectState{}

class ProjectFailure extends ProjectState{}

class ProjectLoading extends ProjectState{}

class ProjectDeleted extends ProjectState{}

class ProjectsLoaded extends ProjectState{
  final List<ProjectModel> projectsList;

  ProjectsLoaded(this.projectsList);
}

class SingleProjectLoaded extends ProjectState{
  final ProjectModel project;

  SingleProjectLoaded(this.project);
}