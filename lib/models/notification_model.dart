import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel{
  static const String TITLE = "title";
  static const String NOT_ID = "id";
  static const String BODY = "body";
  static const String ICON = "icon";

  String title;
  String body;
  String icon;
  String id;

  NotificationModel({this.title, this.body,this.icon,this.id});

  NotificationModel.fromMap(Map<String,dynamic> notMap){
    title = notMap[TITLE] ?? '';
    body = notMap[BODY] ?? '';
    icon = notMap[ICON] ?? '';
    id = notMap[NOT_ID] ?? '';
  }

  NotificationModel.fromSnapshot(DocumentSnapshot doc){
    title = (doc.data() as Map)[TITLE] ?? '';
    body = (doc.data() as Map)[BODY] ?? '';
    icon = (doc.data() as Map)[ICON] ?? '';
    id = (doc.data() as Map)[NOT_ID] ?? '';
  }

  Map<String,dynamic> toMap()=>{
    TITLE : title ?? '',
    BODY : body ?? '',
    ICON : icon ?? '',
    NOT_ID : id ?? ''
  };
}