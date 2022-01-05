import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser{

  static const String ID = "id";
  static const String PHONE = "phone";
  static const String NAME = "name";
  static const String EMAIL = "email";
  static const String TOKEN = "token";

   String id;
   String phone;
   String name;
   String token;
   String email;


  AppUser({
      this.id,
      this.phone,
      this.name,
      this.token,
      this.email,
  });

  Map<String,dynamic> toMap()=>{
    ID : id ??'',
    PHONE : phone ??'',
    NAME : name ??'',
    TOKEN : token ?? '',
    EMAIL : email ?? '',
  };

  AppUser.fromSnapshot(DocumentSnapshot doc){
    id = (doc.data() as Map)[ID] ?? '';
    phone = (doc.data() as Map)[PHONE] ?? '';
    name = (doc.data() as Map)[NAME] ?? '';
    token = (doc.data() as Map)[TOKEN] ?? '';
    email = (doc.data() as Map)[EMAIL] ?? '';
  }

  AppUser.fromMap(Map<String,dynamic> map){
    id = map[ID] ?? '';
    name = map[NAME] ?? '';
    phone = map[PHONE] ?? '';
    token = map[TOKEN] ?? '';
    email = map[EMAIL] ?? '';
  }

}