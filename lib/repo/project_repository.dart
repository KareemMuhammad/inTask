import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskaty/models/invitaion_model.dart';
import 'package:taskaty/models/project_model.dart';
import 'package:taskaty/models/user_model.dart';

class ProjectRepository{
  static const String PROJECTS_COLLECTION = "Projects";

  static const String INVITATIONS_COLLECTION = "Invitations";

  final _invitationsCollection = FirebaseFirestore.instance.collection(ProjectRepository.INVITATIONS_COLLECTION);
  final _projectsCollection = FirebaseFirestore.instance.collection(ProjectRepository.PROJECTS_COLLECTION);

  Future<bool> saveProjectToDb(Map<String,dynamic> userMap,String id)async{
    try {
      await _projectsCollection.doc(id).set(userMap);
      return true;
    }catch(e){

      return false;
    }
  }

  Future<bool> saveProjectToInvitationsDb(Map<String,dynamic> userMap,String id)async{
    try {
      await _invitationsCollection.doc(id).set(userMap);
      return true;
    }catch(e){
      print(e.toString());
      return false;
    }
  }

  Future<bool> deleteProjectInviteFromDb(String id)async{
    try {
      await _invitationsCollection.doc(id).delete();
      return true;
    }catch (e){
      return false;
    }
  }

  Future<bool> updateCurrentProject(Map<String,dynamic> map,String id)async{
    try {
      await _projectsCollection.doc(id).update(map);
      return true;
    }catch(e){

      return false;
    }
  }

  Future<bool> deleteProjectFromDb(String id)async{
    try {
      await _projectsCollection.doc(id).delete();
      return true;
    }catch (e){
      return false;
    }
  }

  Future<ProjectModel> getProjectById(String id){
    return _projectsCollection.doc(id).get().then((doc){
      return ProjectModel.fromSnapshot(doc);
    });
  }

  Future<List<ProjectModel>> getAllProjects(AppUser appUser)async{
    QuerySnapshot snapshot = await _projectsCollection.where(ProjectModel.TEAM_IDS,arrayContains: appUser.id)
        .orderBy(ProjectModel.DATE,descending: true).get()
        .catchError((e) {

    });
    return snapshot.docs.map((doc) {
      return ProjectModel.fromSnapshot(doc);
    }).toList();
  }

  Future<List<InvitationModel>> getAllInvitations(String guestId,String query)async{
    QuerySnapshot snapshot = await _invitationsCollection.where(query,isEqualTo: guestId)
        .orderBy(InvitationModel.DATE,descending: true).get()
        .catchError((e) {
      print(e.toString());
    });
    return snapshot.docs.map((doc) {
      return InvitationModel.fromSnapshot(doc);
    }).toList();
  }

}