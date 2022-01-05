import 'package:flutter/material.dart';
import 'package:taskaty/models/user_model.dart';

@immutable
abstract class UserState {}

class UserInitial extends UserState{}

class UserLoading extends UserState{}

class UserLoadError extends UserState{}

class UserLoaded extends UserState{
  final AppUser appUser;

  UserLoaded(this.appUser);
}

class UserPasswordReset extends UserState{}