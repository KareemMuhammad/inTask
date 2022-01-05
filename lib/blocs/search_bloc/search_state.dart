import 'package:flutter/material.dart';
import 'package:taskaty/models/user_model.dart';

@immutable
abstract class SearchState {}

class SearchInitial extends SearchState{}

class SearchFailure extends SearchState{}

class SearchLoading extends SearchState{}

class SearchLoaded extends SearchState{
  final List<AppUser> users;
  final List<dynamic> teamId;

  SearchLoaded(this.users, this.teamId);
}