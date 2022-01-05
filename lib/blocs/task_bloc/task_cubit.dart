import 'package:bloc/bloc.dart';
import 'package:taskaty/blocs/task_bloc/task_state.dart';
import 'package:taskaty/models/task_model.dart';
import 'package:taskaty/repo/task_repository.dart';

class MyTaskCubit extends Cubit<MyTaskState>{
  final TaskRepository taskRepository;

  MyTaskCubit({this.taskRepository}) : super(TaskInitial());

  List<MyTask> _tasksList;


  List<MyTask> get tasksList => _tasksList;

  void getAllProjectTasks(String projectId) async{
    try{
      emit(TaskLoading());
      _tasksList = await taskRepository.getAllTasks(projectId);
      if(_tasksList != null){
        emit(TaskLoaded(_tasksList));
      }else{
        emit(TaskFailure());
      }
    }catch(e){
      emit(TaskFailure());
      print(e.toString());
    }
  }

  // *** INSERT TASK IN DATABASE
  void addTask(MyTask task) async {
    emit(TaskLoading());
    bool result = await taskRepository.saveTaskToDb(task.toMap(),task.id);
    if (result) {
      emit(TaskUpdated());
    }else{
      emit(TaskNotUpdated());
    }
  }

  // *** UPDATE TASK IN DATABASE ***
  void editTask(MyTask task) async {
    emit(TaskLoading());
    bool result = await taskRepository.updateTask(task,task.id);
    if (result) {
      emit(TaskUpdated());
    }else{
      emit(TaskNotUpdated());
    }
  }

  void deleteTask(MyTask task,String projectId) async {
    bool result = await taskRepository.deleteTaskFromDb(task.toMap(),task.id);
    if (result) {
      getAllProjectTasks(projectId);
    }else{
      emit(TaskFailure());
    }
  }

  void taskStatus(String status,String id,String projectId) async {
    bool result = await taskRepository.updateTaskStatus(status,id);
    if (result) {
      getAllProjectTasks(projectId);
    }else{
      emit(TaskFailure());
    }
  }

  Future<List<MyTask>> getTasksOfDate(String date,String userId)async{
    return taskRepository.getTaskByDate(date, userId);
  }


}