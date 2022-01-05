import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskaty/models/task_model.dart';
import 'package:taskaty/utils/constants.dart';

class TaskRepository{
  static const String TASKS_COLLECTION = "Tasks";

  final _tasksCollection = FirebaseFirestore.instance.collection(TaskRepository.TASKS_COLLECTION);

  Future<bool> saveTaskToDb(Map<String,dynamic> userMap,String id)async{
    try {
      await _tasksCollection.doc(id).set(userMap);
      return true;
    }catch(e){
      return false;
    }
  }

  Future<bool> deleteTaskFromDb(Map<String,dynamic> userMap,String id)async{
    try {
      await _tasksCollection.doc(id).delete();
      return true;
    }catch (e){
      return false;
    }
  }

  Future<bool> updateTask(MyTask task,String id)async{
    try {
      await _tasksCollection.doc(id).update(task.toMap());
      return true;
    }catch(e){
      return false;
    }
  }

  Future<bool> updateTaskStatus(String status,String id)async{
    try {
      await _tasksCollection.doc(id).update({'status': status});
      return true;
    }catch(e){
      return false;
    }
  }

  Future<MyTask> getTaskById(String id){
    try {
      return _tasksCollection.doc(id).get().then((doc) {
        return MyTask.fromSnapshot(doc);
      });
    }catch (e){
      return null;
    }
  }

  Future<List<MyTask>> getAllTasks(String projectId)async{
    QuerySnapshot snapshot = await _tasksCollection.where(MyTask.PROJECT_ID,isEqualTo: projectId)
        .orderBy('date',descending: true)
        .get()
        .catchError((e) {
      print(e.toString());
    });
    return snapshot.docs.map((doc) {
      return MyTask.fromSnapshot(doc);
    }).toList();
  }

  Future<List<MyTask>> getTaskByDate(String date,String id)async{
    QuerySnapshot snapshot = await _tasksCollection.where('assignee',arrayContains: id).where('date',isEqualTo: date)
        .get()
        .catchError((e) {
      print(e.toString());
    });
    return snapshot.docs.map((doc) {
      return MyTask.fromSnapshot(doc);
    }).toList();
  }

  Future<List<MyTask>> getCurrentUserTasks(String id)async{
    QuerySnapshot snapshot = await _tasksCollection.where('assignee',arrayContains: id)
        .where('status',isEqualTo: Utils.TO_DO)
        .orderBy('date',descending: true)
        .get()
        .catchError((e) {
      print(e.toString());
    });
    return snapshot.docs.map((doc) {
      return MyTask.fromSnapshot(doc);
    }).toList();
  }

}