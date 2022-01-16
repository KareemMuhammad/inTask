import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taskaty/models/task_model.dart';

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

    });
    return snapshot.docs.map((doc) {
      return MyTask.fromSnapshot(doc);
    }).toList();
  }

  Future<List<MyTask>> getTaskByDate(String date,String id)async{
    QuerySnapshot snapshot = await _tasksCollection.where('assignee',arrayContains: id).where('date',isEqualTo: date)
        .get()
        .catchError((e) {

    });
    return snapshot.docs.map((doc) {
      return MyTask.fromSnapshot(doc);
    }).toList();
  }

  Future<List<MyTask>> getCurrentUserTasks(String id)async{
    QuerySnapshot snapshot = await _tasksCollection.where('assignee',arrayContains: id)
        .orderBy('date',descending: true)
        .get()
        .catchError((e) {

    });
    return snapshot.docs.map((doc) {
      return MyTask.fromSnapshot(doc);
    }).toList();
  }

 static Future<String> uploadAudio(String record)async{
    String audio;
    UploadTask task = FirebaseStorage.instance.ref().child("$record").putFile(File(record));
    TaskSnapshot snapshot = await task.then((snapshot) async {
      audio = await snapshot.ref.getDownloadURL();
      return snapshot;
    });
    return audio;
  }

  static Future<List<String>> uploadImages(List<XFile> images)async{
    String imageUrl1;
    List<String> converted = [];
    for (XFile file in images) {
      UploadTask task = FirebaseStorage.instance.ref().child("${file.name}").putFile(File(file.path));
      TaskSnapshot snapshot = await task.then((snapshot) async {
        imageUrl1 = await snapshot.ref.getDownloadURL();
        converted.add(imageUrl1);
        return snapshot;
      });
    }
    return converted;
  }

  static Future<String> uploadFile(String fileLink,File file)async{
    String converted;
    UploadTask task = FirebaseStorage.instance.ref().child("$fileLink").putFile(file);
    TaskSnapshot snapshot = await task.then((snapshot) async {
      converted = await snapshot.ref.getDownloadURL();
      return snapshot;
    });
    return converted;
  }

}