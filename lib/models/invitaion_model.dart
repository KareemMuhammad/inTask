import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskaty/models/project_model.dart';

class InvitationModel{
  static const String ID = "id";
  static const String OWNER = "owner";
  static const String GUEST = "guest";
  static const String PROJECT = "project";
  static const String DATE = "date";

  String _id;
  String _ownerId;
  String _guestId;
  ProjectModel _project;
  String _date;

  InvitationModel(this._id, this._ownerId, this._project, this._date,this._guestId);

  String get date => _date;

  set date(String value) {
    _date = value;
  }


  String get guestId => _guestId;

  set guestId(String value) {
    _guestId = value;
  }

  ProjectModel get project => _project;

  set project(ProjectModel value) {
    _project = value;
  }

  String get ownerId => _ownerId;

  set ownerId(String value) {
    _ownerId = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  Map<String,dynamic> toMap()=>{
    ID : id ??'',
    OWNER : ownerId ??'',
    PROJECT : project.toMap() ?? {},
    DATE : date ?? '',
    GUEST : guestId ?? '',
  };

  InvitationModel.fromSnapshot(DocumentSnapshot doc){
    id = (doc.data() as Map)[ID] ?? '';
    ownerId = (doc.data() as Map)[OWNER] ?? '';
    project = (doc.data() as Map)[PROJECT] ?? {};
    date = (doc.data() as Map)[DATE] ?? '';
    guestId = (doc.data() as Map)[GUEST] ?? '';
  }
}