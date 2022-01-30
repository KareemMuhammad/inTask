import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskaty/blocs/invitation_bloc/invitation_cubit.dart';
import 'package:taskaty/blocs/project_bloc/project_cubit.dart';
import 'package:taskaty/blocs/project_bloc/project_state.dart';
import 'package:taskaty/blocs/search_bloc/search_cubit.dart';
import 'package:taskaty/blocs/search_bloc/search_state.dart';
import 'package:taskaty/helper_functions/SearchHelper.dart';
import 'package:taskaty/models/invitaion_model.dart';
import 'package:taskaty/models/notification_model.dart';
import 'package:taskaty/models/project_model.dart';
import 'package:taskaty/models/user_model.dart';
import 'package:taskaty/utils/constants.dart';
import 'package:taskaty/utils/shared.dart';
import 'package:taskaty/widgets/shared/custom_button.dart';
import 'package:taskaty/widgets/shared/shared_widgets.dart';
import 'package:uuid/uuid.dart';

class AddProjectScreen extends StatefulWidget {

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final TextEditingController textController = new TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<AppUser> searchedForUsers = [];
  List<dynamic> teamIds = [];
  SearchCubit searchCubit;
  String _projectName = '';

  @override
  Widget build(BuildContext context) {
    final ProjectCubit projectCubit = BlocProvider.of<ProjectCubit>(context);
    final InvitationCubit invitationCubit = BlocProvider.of<InvitationCubit>(context);
    searchCubit = BlocProvider.of<SearchCubit>(context);
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: darkNavy,
        title: Text(
          'Create New Project',
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
      body: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20,),
               Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18,vertical: 10),
                    child: TextFormField(
                      maxLength: 20,
                      textDirection: Utils.isRTL(_projectName.isNotEmpty ? _projectName : textController.text) ? TextDirection.rtl : TextDirection.ltr,
                      style: TextStyle(color: black,fontSize: 18,),
                      decoration: textInputDecorationSign('Project Name',Icons.drive_file_rename_outline),
                      controller: textController,
                      validator: (val) {
                        return val.isEmpty ? 'You must type a name for the project!' : null;
                      },
                      onChanged: (val){
                        setState(() {
                          _projectName = val;
                        });
                      },
                  ),),
                const SizedBox(height: 10,),
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
                     if(state is SearchLoading){
                       return spinKit;
                     }else if(state is SearchLoaded){
                       searchedForUsers = state.users;
                       teamIds = state.teamId;
                       return searchedForUsers.isNotEmpty?
                       ListView.builder(
                           shrinkWrap: true,
                           physics: const NeverScrollableScrollPhysics(),
                           itemCount: searchedForUsers.length,
                           itemBuilder: (context,index){
                             return searchedForUsers[index].id == Utils.getCurrentUser(context).id ? const SizedBox():
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
                     }else{
                       return const SizedBox();
                     }
               }),
                const SizedBox(height: 30,),
                BlocConsumer<ProjectCubit,ProjectState>(
                    listener: (context,state){
                      if(state is ProjectsLoaded){
                        for(AppUser user in searchedForUsers){
                          if(user.id != Utils.getCurrentUser(context).id) {
                            NotificationModel model = NotificationModel(id: '',
                                icon: Utils.APP_ICON,
                                title: textController.text,
                                body: '${Utils.getCurrentUser(context).name} invited you to a new project');
                            Utils.sendPushMessage(model, user.token);
                            final String id = Uuid().v1();
                            final String date = Utils.currentDate();
                            final InvitationModel inviteModel = InvitationModel(id,
                                Utils.getCurrentUser(context).id, state.projectsList.last,date, user.id);
                            invitationCubit.addInviteToProject(inviteModel);
                          }
                        }
                        teamIds.clear();
                        searchedForUsers.clear();
                        Navigator.pop(context);
                      }
                      },
                    builder: (context,state) {
                      return state is ProjectLoading ? spinKit
                        : Center(
                            child: RaisedGradientButton(
                                radius: 20,
                                width: SizeConfig.screenWidth * 0.6,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('CREATE PROJECT',style: TextStyle(fontSize: 18,color: white),),
                                ),
                                gradient: myGradient(),
                                onPressed: (){
                                  if(formKey.currentState.validate()) {
                                    teamIds.add(Utils.getCurrentUser(context).id);
                                    searchedForUsers.add(Utils.getCurrentUser(context));
                                    final String id = Uuid().v1();
                                    final String date = Utils.currentDate();
                                    final ProjectModel model = ProjectModel(id,
                                        Utils.getCurrentUser(context).id,textController.text,
                                        teamIds,searchedForUsers,date);
                                    projectCubit.addProject(model,Utils.getCurrentUser(context));
                                  }
                                }
                        ),
                      );
                    }
                ),
              ],
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
