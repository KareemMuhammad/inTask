import 'package:bloc/bloc.dart';
import 'package:taskaty/blocs/invitation_bloc/invitation_state.dart';
import 'package:taskaty/models/invitaion_model.dart';
import 'package:taskaty/repo/project_repository.dart';

class InvitationCubit extends Cubit<InvitationState>{
  final ProjectRepository projectRepository;

  InvitationCubit({this.projectRepository}) : super(InvitationInitial());

  List<InvitationModel> inviteList;

  void getAllInvitationsOfGuest(String id) async{
    try{
      emit(InvitationLoading());
      inviteList = await projectRepository.getAllInvitations(id,InvitationModel.GUEST);
    }catch(e){
      print(e.toString());
      emit(InvitationFailure());
    }
  }

  void getAllInvitationsOfOwner(String id) async{
    try{
      emit(InvitationLoading());
      inviteList = await projectRepository.getAllInvitations(id,InvitationModel.OWNER);
    }catch(e){
      print(e.toString());
      emit(InvitationFailure());
    }
  }

  void addInviteToProject(InvitationModel inviteModel) async {
    emit(InvitationLoading());
    await projectRepository.saveProjectToInvitationsDb(inviteModel.toMap(),inviteModel.id);
  }

  void removeInviteFromProject(InvitationModel inviteModel) async {
    emit(InvitationLoading());
    await projectRepository.deleteProjectInviteFromDb(inviteModel.id);
  }

}