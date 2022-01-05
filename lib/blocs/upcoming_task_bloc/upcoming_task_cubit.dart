import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskaty/blocs/upcoming_task_bloc/upcoming_task_state.dart';
import 'package:taskaty/models/task_model.dart';
import 'package:taskaty/repo/task_repository.dart';

class UpcomingTaskCubit extends Cubit<MyUpcomingTaskState>{
  final TaskRepository taskRepository;

  UpcomingTaskCubit({this.taskRepository}) : super(UpTaskInitial());

  List<MyTask> currentTasks;

  final String _authId = FirebaseAuth.instance.currentUser.uid;

  void getAllCurrentTasks() async{
    try{
      emit(UpTaskLoading());
      currentTasks = await taskRepository.getCurrentUserTasks(_authId);
      if(currentTasks != null){
        emit(UpcomingTasksLoaded(currentTasks));
      }else{
        emit(UpTaskFailure());
      }
    }catch(e){
      emit(UpTaskFailure());
      print(e.toString());
    }
  }

  void deleteTask(MyTask task) async {
    bool result = await taskRepository.deleteTaskFromDb(task.toMap(),task.id);
    if (result) {
      getAllCurrentTasks();
    }else{
      emit(UpTaskFailure());
    }
  }

  void taskStatus(String status,String id) async {
    bool result = await taskRepository.updateTaskStatus(status,id);
    if (result) {
      getAllCurrentTasks();
    }else{
      emit(UpTaskFailure());
    }
  }

  void removeFromList(MyTask task){
    currentTasks.removeWhere((element) => element.id == task.id);
    emit(UpcomingTasksLoaded(currentTasks));
  }
  void addToList(MyTask task){
    currentTasks.add(task);
    emit(UpcomingTasksLoaded(currentTasks));
  }

  void editTaskOfList(MyTask task){
    final index = currentTasks.indexOf(currentTasks.where((bp) => bp.id == task.id).first);
    currentTasks[index] = task;
    emit(UpcomingTasksLoaded(currentTasks));
  }

}