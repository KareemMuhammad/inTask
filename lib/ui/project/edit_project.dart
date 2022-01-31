import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskaty/blocs/project_bloc/project_cubit.dart';
import 'package:taskaty/blocs/project_bloc/project_state.dart';
import 'package:taskaty/blocs/search_bloc/search_cubit.dart';
import 'package:taskaty/blocs/search_bloc/search_state.dart';
import 'package:taskaty/helper_functions/SearchHelper.dart';
import 'package:taskaty/models/project_model.dart';
import 'package:taskaty/models/user_model.dart';
import 'package:taskaty/utils/constants.dart';
import 'package:taskaty/utils/shared.dart';
import 'package:taskaty/widgets/shared/custom_button.dart';
import 'package:taskaty/widgets/shared/delete_product_dialog.dart';
import 'package:taskaty/widgets/shared/shared_widgets.dart';

class EditProject extends StatefulWidget {
  @override
  _EditProjectState createState() => _EditProjectState();
}

class _EditProjectState extends State<EditProject> {
  final TextEditingController _nameController = TextEditingController();
  List<AppUser> searchedForUsers;
  List<dynamic> teamIds ;
  String _projectName = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  SearchCubit searchCubit;

  @override
  void initState() {
    super.initState();
    if(Utils.getCurrentProject(context).name.isNotEmpty) {
      this._nameController.text = Utils.getCurrentProject(context).name ?? '';
    }
    if(Utils.getCurrentProject(context).teamMates.isNotEmpty){
       Utils.getCurrentProject(context).teamMates.forEach((user) {
         BlocProvider.of<SearchCubit>(context).setUsersList = user;
      });
      searchedForUsers = Utils.getCurrentProject(context).teamMates;
      teamIds = Utils.getCurrentProject(context).teamIds;
    }else{
      searchedForUsers = [];
      teamIds = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProjectCubit projectCubit = BlocProvider.of<ProjectCubit>(context);
    searchCubit = BlocProvider.of<SearchCubit>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Project',
          style: TextStyle(
            color: white,
            fontFamily: 'OrelegaOne',
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: (){
            BlocProvider.of<SearchCubit>(context).clearAll();
            teamIds.clear();
            searchedForUsers.clear();
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: white,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                const SizedBox(height: 25,),
                TextFormField(
                  controller: this._nameController,
                  textDirection: Utils.isRTL(_projectName.isNotEmpty ? _projectName : _nameController.text) ? TextDirection.rtl : TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: 'Project Name',
                    alignLabelWithHint: true,
                    contentPadding: EdgeInsets.all(15.0),
                    labelStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                      color: Colors.grey[900]
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: darkNavy, width: 2.0),
                      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: darkNavy, width: 2.0),
                      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                    ),
                  ),
                  onChanged: (val){
                    setState(() {
                      _projectName = val;
                    });
                  },
                ),
                const SizedBox(height: 20,),
                Text(
                  'Add Teammates',
                  style: TextStyle(
                    color: Colors.grey[900],
                    fontWeight: FontWeight.w500,
                    fontSize: 17.0,
                    fontFamily: 'OrelegaOne',
                    letterSpacing: 1.0,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18,vertical: 10),
                  child: TextFormField(
                    readOnly: true,
                    showCursor: true,
                    autofocus: false,
                    style: TextStyle(color: black,fontSize: 18,),
                    decoration: textInputDecorationSign('search..',Icons.group),
                    onTap: ()async{
                      await showSearch(context: context,
                          delegate: DataSearch(Utils.getCurrentUsers(context)));
                    },
                  ),
                ),
                const SizedBox(height: 10,),
                BlocBuilder<SearchCubit,SearchState>(
                    builder: (ctx,state){
                      if(state is SearchInitial){
                        return searchedForUsers.isNotEmpty?
                        ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: searchedForUsers.length,
                            itemBuilder: (context,index){
                              return searchedForUsers[index].id == Utils.getCurrentUser(context).id ?
                              const SizedBox():
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8,8,8,8),
                                child: ListTile(
                                    leading: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: darkNavy,
                                      child: Center(
                                        child: Text('${Utils.getInitials(searchedForUsers[index].name)}',
                                          style: TextStyle(fontSize: 17,color: white,),),
                                      ),
                                    ),
                                    title: Text('${searchedForUsers[index].name}',style: TextStyle(fontSize: 18,color: black),),
                                    trailing: IconButton(
                                        onPressed: (){
                                          searchCubit.removeFromUsersList(searchedForUsers[index]);
                                        },
                                        icon: Icon(Icons.delete,color: button,))
                                ),
                              );
                            }) : const SizedBox();
                      } else if(state is SearchLoading){
                        return spinKit;
                      }else if(state is SearchLoaded){
                        searchedForUsers = state.users;
                        teamIds = state.teamId;
                        return searchedForUsers.isNotEmpty?
                        ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: searchedForUsers.length,
                            itemBuilder: (context,index){
                              return searchedForUsers[index].id == Utils.getCurrentUser(context).id ?
                              const SizedBox():
                              Padding(
                                padding: const EdgeInsets.fromLTRB(15,8,8,8),
                                child: ListTile(
                                    contentPadding: const EdgeInsets.all(8),
                                    leading: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: darkNavy,
                                      child: Center(
                                        child: Text('${Utils.getInitials(searchedForUsers[index].name)}',
                                          style: TextStyle(fontSize: 17,color: white,),),
                                      ),
                                    ),
                                    title: Text('${searchedForUsers[index].name}',style: TextStyle(fontSize: 18,color: black),),
                                    trailing: IconButton(
                                        onPressed: (){
                                          searchCubit.removeFromUsersList(searchedForUsers[index]);
                                        },
                                        icon: Icon(Icons.delete,color: button,))
                                ),
                              );
                            }) : const SizedBox();
                      }else{
                        return const SizedBox();
                      }
                    }),
                const SizedBox(height: 30,),
                BlocConsumer<ProjectCubit,ProjectState>(
                    listener: (context,state){
                      if(state is SingleProjectLoaded){
                        Scaffold.of(context)
                            .showSnackBar(SnackBar(content: Text('Project Updated')));
                        teamIds.clear();
                        searchedForUsers.clear();
                        projectCubit.getAllProjects(Utils.getCurrentUser(context));
                      }else if(state is ProjectDeleted){
                        teamIds.clear();
                        searchedForUsers.clear();
                        projectCubit.getAllProjects(Utils.getCurrentUser(context));
                        int count = 0;
                        Navigator.of(context).popUntil((_) => count++ >= 2);
                      }
                    },
                    builder: (context,state) {
                      return state is ProjectLoading ? spinKit
                          : Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                RaisedGradientButton(
                                    radius: 20,
                                    width: SizeConfig.screenWidth * 0.3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Save',style: TextStyle(fontSize: 20,color: white),),
                                    ),
                                    gradient: myGradient(),
                                    onPressed: (){
                                      if(_formKey.currentState.validate()){
                                        final ProjectModel model = ProjectModel(Utils.getCurrentProject(context).id,
                                            Utils.getCurrentProject(context).ownerId,_nameController.text,
                                            teamIds,searchedForUsers,Utils.getCurrentProject(context).date);
                                         projectCubit.editProject(model);
                                      }
                                    }
                                 ),
                                RaisedGradientButton(
                                    radius: 20,
                                    width: SizeConfig.screenWidth * 0.3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Delete',style: TextStyle(fontSize: 20,color: white),),
                                    ),
                                    gradient: myGradient(),
                                    onPressed: (){
                                      showDialog(context: context, builder: (_){
                                        return Dialog(
                                          backgroundColor: white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                                          child: DeleteProdDialog(projectCubit: projectCubit,),
                                        );
                                      });
                                    }
                                ),

                              ],
                      );
                    }
                ),
                const SizedBox(height: 15,),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchCubit.clearAll();
    teamIds.clear();
    searchedForUsers.clear();
    super.dispose();
  }

}
