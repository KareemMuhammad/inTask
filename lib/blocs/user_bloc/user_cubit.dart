import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskaty/blocs/user_bloc/user_state.dart';
import 'package:taskaty/models/user_model.dart';
import 'package:taskaty/repo/user_repository.dart';

class UserCubit extends Cubit<UserState>{
  final UserRepository userRepository;

  UserCubit({this.userRepository}) : super(UserInitial());

  AppUser _user;
  User _fireUser ;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  AppUser get getUser => _user;

  Future loadUserData()async{
    try {
      emit(UserLoading());
        _fireUser = await userRepository.getCurrentUser();
        _user = await userRepository.getUserById(_fireUser.uid);
        print(_user.name);
        if(_user != null) {
          emit(UserLoaded(_user));
        }else{
          emit(UserLoadError());
        }
    }catch(e){
      print(e.toString());
      emit(UserLoadError());
    }
 }

  Future resetPassword(String email)async{
    try{
      await _auth.sendPasswordResetEmail(email: email);
      emit(UserPasswordReset());
    }catch(e){
      emit(UserLoadError());
      print(e.toString());
    }
  }

  Future updateUserInfo(dynamic name,String key)async{
    try {
      await userRepository.updateInfo(name, _auth.currentUser.uid,key);
    }catch(e){
      emit(UserLoadError());
      print(e.toString());
    }
  }

  Future<bool> authUserEmail(dynamic email)async{
    try {
       bool result = await userRepository.authenticateUserEmail(email);
       return result;
    }catch(e){
      print(e.toString());
      return false;
    }
  }

}