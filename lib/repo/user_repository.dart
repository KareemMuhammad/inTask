import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskaty/models/user_model.dart';

class UserRepository{
 static const String USERS_COLLECTION = "Users";
 static const String NOTIFICATIONS_COLLECTION = "Notifications";

 final _usersCollection = FirebaseFirestore.instance.collection(UserRepository.USERS_COLLECTION);
 final _notificationsCollection = FirebaseFirestore.instance.collection(UserRepository.NOTIFICATIONS_COLLECTION);

 Future<AppUser> getUserById(String id){
  return _usersCollection.doc(id).get().then((doc){
   return AppUser.fromSnapshot(doc);
  });
 }

 Future<List<AppUser>> getAllUsers()async{
  QuerySnapshot snapshot = await _usersCollection.get()
      .catchError((e) {

  });
  return snapshot.docs.map((doc) {
   return AppUser.fromSnapshot(doc);
  }).toList();
 }

 Future saveUserToDb(Map<String,dynamic> userMap,String id)async{
  await _usersCollection.doc(id).set(userMap);
 }


 Future saveNotificationToDb(Map<String,dynamic> userMap,String id)async{
  await _notificationsCollection.doc(id).set(userMap);
 }

 Future<bool> authenticateUser(User user) async {
  QuerySnapshot result = await _usersCollection
      .where(AppUser.PHONE, isEqualTo: user.phoneNumber)
      .get();
  final List<DocumentSnapshot> docs = result.docs;

  return docs.length == 0 || docs.isEmpty ? true : false;
 }

 Future<bool> authenticateUserEmail(String email) async {
  QuerySnapshot result = await _usersCollection
      .where(AppUser.PHONE, isEqualTo: email)
      .get();
  final List<DocumentSnapshot> docs = result.docs;

  return docs.length == 0 || docs.isEmpty ? true : false;
 }

 Future<User> getCurrentUser() async {
  return FirebaseAuth.instance.currentUser;
 }

 Future updateInfo(dynamic info,String id,String key)async{
  await _usersCollection.doc(id).update({key : info});
 }

 Future updateCurrentUser(Map<String,dynamic> map,String id)async{
  await _usersCollection.doc(id).update(map);
 }

 Future updateUserToken(String token,String id)async{
  await  _usersCollection.doc(id).update({AppUser.TOKEN : token });
 }

}