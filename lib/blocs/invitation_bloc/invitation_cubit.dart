import 'package:bloc/bloc.dart';
import 'package:taskaty/blocs/invitation_bloc/invitation_state.dart';
import 'package:taskaty/models/invitaion_model.dart';
import 'package:taskaty/repo/project_repository.dart';

class InvitationCubit extends Cubit<InvitationState>{
  final ProjectRepository projectRepository;

  InvitationCubit({this.projectRepository}) : super(InvitationInitial());

  List<InvitationModel> inviteReceivedList;

  void getAllInvitationsOfReceived(String id) async{
    try{
      emit(ReceivedInvitationLoading());
      inviteReceivedList = await projectRepository.getAllInvitations(id,InvitationModel.GUEST);
      if(inviteReceivedList != null){
        emit(ReceivedInvitationsLoaded(inviteReceivedList));
      }else{
        emit(InvitationReceivedFailure());
      }
    }catch(e){
      print(e.toString());
      emit(InvitationReceivedFailure());
    }
  }

  void addInviteToProject(InvitationModel inviteModel) async {
    bool result = await projectRepository.saveProjectToInvitationsDb(inviteModel.toMap(),inviteModel.id);
    if(result){
      emit(InvitationUpdated());
    }else{
      emit(InvitationNotUpdated());
    }
  }

  void removeInviteFromProject(InvitationModel inviteModel) async {
    bool result = await projectRepository.deleteProjectInviteFromDb(inviteModel.id);
    if(result){
      emit(InvitationUpdated());
    }else{
      emit(InvitationNotUpdated());
    }
  }

}