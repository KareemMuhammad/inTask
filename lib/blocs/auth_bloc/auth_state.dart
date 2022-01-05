import 'package:flutter/material.dart';
import 'package:taskaty/models/user_model.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState{}

class AuthLoading extends AuthState{}

class AuthFailure extends AuthState{}

class AuthRegistration extends AuthState{}

class AuthOTP extends AuthState{
 final String phone;
 final String codeDigits;

  AuthOTP(this.phone, this.codeDigits);
}

class AuthSetup extends AuthState{
 final AppUser user;

  AuthSetup(this.user);
}

class AuthSuccessful extends AuthState{
 final AppUser appUser;

 AuthSuccessful(this.appUser);
}