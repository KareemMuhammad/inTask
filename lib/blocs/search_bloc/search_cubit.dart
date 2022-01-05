import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskaty/blocs/search_bloc/search_state.dart';
import 'package:taskaty/models/user_model.dart';

class SearchCubit extends Cubit<SearchState>{
  SearchCubit(SearchState initialState) : super(initialState);

  List<AppUser> _usersList = [];
  List<dynamic> _teamId = [];

  List<AppUser> get getUsersList => _usersList;

  set setUsersList(AppUser value) {
    emit(SearchLoading());
    if(!_usersList.contains(value)) {
      _usersList.add(value);
      _teamId.add(value.id);
    }
    emit(SearchLoaded(_usersList, _teamId));
  }

 void removeFromUsersList(AppUser value){
    emit(SearchLoading());
    if(_usersList.contains(value)) {
      _usersList.remove(value);
      _teamId.remove(value.id);
    }
    emit(SearchLoaded(_usersList,_teamId));
  }

  void clearAll(){
    _usersList.clear();
    _teamId.clear();
  }
}