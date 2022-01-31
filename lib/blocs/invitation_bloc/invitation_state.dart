import 'package:flutter/material.dart';
import 'package:taskaty/models/invitaion_model.dart';

@immutable
abstract class InvitationState {}

class InvitationInitial extends InvitationState{}

class InvitationReceivedFailure extends InvitationState{}

class InvitationUpdated extends InvitationState{}

class InvitationNotUpdated extends InvitationState{}

class ReceivedInvitationLoading extends InvitationState{}

class InvitationDeleted extends InvitationState{}

class ReceivedInvitationsLoaded extends InvitationState{
  final List<InvitationModel> receivedList;

  ReceivedInvitationsLoaded(this.receivedList);
}