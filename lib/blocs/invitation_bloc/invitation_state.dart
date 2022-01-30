import 'package:flutter/material.dart';
import 'package:taskaty/models/invitaion_model.dart';

@immutable
abstract class InvitationState {}

class InvitationInitial extends InvitationState{}

class InvitationFailure extends InvitationState{}

class InvitationLoading extends InvitationState{}

class InvitationDeleted extends InvitationState{}

class InvitationsLoaded extends InvitationState{
  final List<InvitationModel> invitationsList;

  InvitationsLoaded(this.invitationsList);
}