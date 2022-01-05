import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskaty/blocs/search_bloc/search_cubit.dart';
import 'package:taskaty/models/user_model.dart';
import 'package:taskaty/utils/constants.dart';
import 'package:taskaty/utils/shared.dart';

class DataSearch extends SearchDelegate<AppUser>{
  final List<AppUser> _usersList;

  DataSearch(this._usersList);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.clear),
          onPressed: (){
            query = "";
          }),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(icon: AnimatedIcon(
      icon: AnimatedIcons.menu_arrow,
      progress: transitionAnimation,
    )
        , onPressed: (){
          close(context, null);
        }
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<AppUser> suggestionLists = query.isNotEmpty? _usersList.
    where((user) => user.id != Utils.getCurrentUser(context).id
    && user.email.toLowerCase().contains(query)).toList():[];
    return ListView.builder(
      itemCount: suggestionLists.length,
      itemBuilder: (ctx,index){
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              children: [
                ListTile(
                  onTap: () {
                    BlocProvider.of<SearchCubit>(context).setUsersList = suggestionLists[index];
                    Navigator.pop(context);
                  },
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: darkNavy,
                    child: Center(
                      child: Text('${Utils.getInitials(suggestionLists[index].name)}',style: TextStyle(fontSize: 17,color: white,),),
                    ),
                  ),
                  title:  Text(suggestionLists[index].email,style: TextStyle(fontSize: 20,color: darkNavy)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                  child: Divider(
                    height: 1,
                    color: Colors.grey[700],
                  ),
                )
              ]),
        );
      },);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<AppUser> suggestionLists = query.isNotEmpty? _usersList.
    where((user) => user.id != Utils.getCurrentUser(context).id
    && user.email.toLowerCase().contains(query)).toList():[];
    return ListView.builder(
        itemCount: suggestionLists.length,
        itemBuilder: (ctx,index){
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      BlocProvider.of<SearchCubit>(context).setUsersList = suggestionLists[index];
                      Navigator.pop(context);
                    },
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: darkNavy,
                      child: Center(
                        child: Text('${Utils.getInitials(suggestionLists[index].name)}',style: TextStyle(fontSize: 17,color: white,),),
                      ),
                    ),
                    title: Text(suggestionLists[index].email,style: TextStyle(fontSize: 20,color: darkNavy)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                    child: Divider(
                      height: 1,
                      color: Colors.grey[700],
                    ),
                  )
                ]),
          );
        },);
  }

}