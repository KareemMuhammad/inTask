import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskaty/blocs/project_bloc/project_state.dart';
import 'package:taskaty/models/project_model.dart';
import 'package:taskaty/models/user_model.dart';
import 'package:taskaty/repo/project_repository.dart';

class ProjectCubit extends Cubit<ProjectState>{
  final ProjectRepository projectRepository;

  ProjectCubit({this.projectRepository}) : super(ProjectInitial());

  List<ProjectModel> projectsList;

  final String _authId = FirebaseAuth.instance.currentUser.uid;

  ProjectModel _currentProject;

  ProjectModel get getCurrentProject => _currentProject;


  set setCurrentProject(ProjectModel value) {
    _currentProject = value;
  }

  void getAllProjects(AppUser user) async{
    try{
      emit(ProjectLoading());
      projectsList = await projectRepository.getAllProjects(user);
      if(projectsList != null){
        emit(ProjectsLoaded(projectsList));
      }else{
        emit(ProjectFailure());
      }
    }catch(e){
      print(e.toString());
      emit(ProjectFailure());
    }
  }

  // *** INSERT Project IN DATABASE
  void addProject(ProjectModel projectModel,AppUser user) async {
    emit(ProjectLoading());
    bool result = await projectRepository.saveProjectToDb(projectModel.toMap(),projectModel.id);
    if (result) {
      getAllProjects(user);
    }else{
      emit(ProjectFailure());
    }
  }

  void editProject(ProjectModel projectModel,AppUser user) async {
    emit(ProjectLoading());
    bool result = await projectRepository.updateCurrentProject(projectModel.toMap(),projectModel.id);
    if (result) {
      loadCurrentProject(projectModel.id);
      emit(SingleProjectLoaded(projectModel));
    }else{
      emit(ProjectFailure());
    }
  }

  void deleteProject(ProjectModel project,AppUser user) async {
    bool result = await projectRepository.deleteProjectFromDb(project.id);
    if (result) {
      emit(ProjectDeleted());
    }else{
      emit(ProjectFailure());
    }
  }

  void loadCurrentProject(String id)async{
    _currentProject = await projectRepository.getProjectById(id);
  }

}