import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskaty/models/user_model.dart';

class ProjectModel{

  static const String ID = "id";
  static const String OWNER = "owner";
  static const String NAME = "name";
  static const String TEAM_IDS = "teamIds";
  static const String TEAM = "teamMates";
  static const String DATE = "date";

  String _id;
  String _ownerId;
  String _name;
  String _date;
  List<dynamic> _teamIds;
  List<AppUser> _teamMates;

  ProjectModel(this._id, this._ownerId, this._name, this._teamIds, this._teamMates,this._date);

  List<AppUser> get teamMates => _teamMates;

  set teamMates(List<AppUser> value) {
    _teamMates = value;
  }


  List<dynamic> get teamIds => _teamIds;

  set teamIds(List<dynamic> value) {
    _teamIds = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get ownerId => _ownerId;

  set ownerId(String value) {
    _ownerId = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }


  String get date => _date;

  set date(String value) {
    _date = value;
  }

  Map<String,dynamic> toMap()=>{
    ID : id ??'',
    OWNER : ownerId ??'',
    NAME : name ??'',
    TEAM_IDS : teamIds.map((e) => e.toString()).toList() ?? [],
    TEAM : teamMates.map((e) => e.toMap()).toList() ?? [],
    DATE : date ?? '',
  };

  ProjectModel.fromMap(Map<String,dynamic> map){
   id = map[ID] ?? '';
   ownerId = map[OWNER] ?? '';
   name = map[NAME] ?? '';
   teamMates = teamList(map[TEAM] ?? []);
   teamIds = map[TEAM_IDS] ?? [];
   date = map[DATE] ?? '';
  }

  ProjectModel.fromSnapshot(DocumentSnapshot doc){
    id = (doc.data() as Map)[ID] ?? '';
    ownerId = (doc.data() as Map)[OWNER] ?? '';
    name = (doc.data() as Map)[NAME] ?? '';
    teamMates = teamList((doc.data() as Map)[TEAM] ?? []);
    teamIds = (doc.data() as Map)[TEAM_IDS] ?? [];
    date = (doc.data() as Map)[DATE] ?? '';
  }

  List<AppUser> teamList (List<dynamic> admires){
    List<AppUser> convertedAdmires = [];
    for(Map item in admires){
      convertedAdmires.add(AppUser.fromMap(item));
    }
    return convertedAdmires;
  }

}