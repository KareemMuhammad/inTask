import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskaty/blocs/auth_bloc/auth_state.dart';
import 'package:taskaty/models/user_model.dart';
import 'package:taskaty/repo/user_repository.dart';


class AuthCubit extends Cubit<AuthState>{
  final UserRepository userRepository;

  AuthCubit({this.userRepository}) : super(AuthInitial());

  AppUser _user;
  List<AppUser> _allUsers;
  User _fireUser;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  AppUser get getUser => _user;
  List<AppUser> get getAllUsersList => _allUsers;

  Future loadUserData()async{
    try {
      emit(AuthLoading());
        _fireUser = await userRepository.getCurrentUser();
        _user = await userRepository.getUserById(_fireUser.uid);
        if(_user != null) {
          if(_user.name.isEmpty){
            emit(AuthSetup(_user));
          }else {
            emit(AuthSuccessful(_user));
          }
        }else{
          emit(AuthFailure());
        }
    }catch(e){

      emit(AuthFailure());
    }
 }

  void loadUsers()async{
    try {
     _allUsers = await userRepository.getAllUsers();
    }catch(e){

    }
  }

  Future authUser()async{
    try {
      emit(AuthLoading());
      _fireUser = await userRepository.getCurrentUser();
      if(_fireUser != null) {
          loadUserData();
      }else{
        emit(AuthFailure());
      }
    }catch(e){

      emit(AuthFailure());
    }
  }


  Future signOut()async{
    try{
      if(_auth.currentUser != null) {
        await _auth.signOut();
        emit(AuthFailure());
      }
    }catch(e){
      emit(AuthFailure());

    }
  }

}