import 'package:cloud_firestore/cloud_firestore.dart';

class MyTask {

  static const String PROJECT_ID = "projectId";
  static const String PROJECT_NAME = "projectName";

  String _id;
  String _projectId;
  String _task;
  String _description;
  String _date;
  String _time;
  String _token;
  String _holderId;
  String _projectName;
  List<dynamic> _images;
  List<dynamic> _assignee;
  bool _audioDescription;
  String _status;
  int _timestamp;

  MyTask(this._id, this._task, this._description, this._date, this._time,
      this._audioDescription, this._timestamp,this._token,this._status,this._holderId,this._assignee,this._images,this._projectId,this._projectName);

  //convert task object to map object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (this.id != null) {
      map['id'] = this.id ?? '';
    }
    map['taskName'] = this.task ?? '';
    map['description'] = this.description ?? '';
    map['date'] = this.date ?? '';
    map['time'] = this.time ?? '';
    map['audioDescription'] = this.audioDescription ? 1 : 0;
    map['timestamp'] = this.timestamp;
    map['token'] = this.token ?? '';
    map['holderId'] = this.holderId ?? '';
    map['status'] = this.status ?? '';
    map['images'] = this.image ?? [];
    map['assignee'] = this.assignee ?? [];
    map[PROJECT_ID] = this.projectId ?? '';
    map[PROJECT_NAME] = this.projectName ?? '';

    return map;
  }

  MyTask.fromSnapshot(DocumentSnapshot doc) {
    this.id = (doc.data() as Map)['id'] ?? '';
    this.task = (doc.data() as Map)['taskName'] ?? '';
    this.description = (doc.data() as Map)['description'] ?? '';
    this.date = (doc.data() as Map)['date'] ?? '';
    this.time = (doc.data() as Map)['time'] ?? '';
    this.audioDescription = (doc.data() as Map)['audioDescription'] > 0 ? true : false;
    this.timestamp = (doc.data() as Map)['timestamp'];
    this.token = (doc.data() as Map)['token'] ?? '';
    this.status = (doc.data() as Map)['status'] ?? 'To Do';
    this.holderId = (doc.data() as Map)['holderId'] ?? '';
    this.image = (doc.data() as Map)['images'] ?? [];
    this.assignee = (doc.data() as Map)['assignee'] ?? [];
    this.projectId = (doc.data() as Map)[PROJECT_ID] ?? '';
    this.projectName = (doc.data() as Map)[PROJECT_NAME] ?? '';
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }


  String get projectId => _projectId;

  set projectId(String value) {
    _projectId = value;
  }


  String get projectName => _projectName;

  set projectName(String value) {
    _projectName = value;
  }

  String get task => _task;

  set task(String value) {
    _task = value;
  }

  String get description => _description;

  set description(String value) {
    _description = value;
  }

  String get date => _date;

  set date(String value) {
    _date = value;
  }

  String get time => _time;

  set time(String value) {
    _time = value;
  }

  String get token => _token;

  set token(String value) {
    _token = value;
  }

  String get holderId => _holderId;

  set holderId(String value) {
    _holderId = value;
  }

  bool get audioDescription => _audioDescription;

  set audioDescription(bool value) {
    _audioDescription = value;
  }

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  int get timestamp => _timestamp;

  set timestamp(int value) {
    _timestamp = value;
  }

  List<dynamic> get image => _images;

  set image(List<dynamic> value) {
    _images = value;
  }

  List<dynamic> get assignee => _assignee;

  set assignee(List<dynamic> value) {
    _assignee = value;
  }
}
