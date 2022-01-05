import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskaty/blocs/auth_bloc/auth_cubit.dart';
import 'package:taskaty/blocs/project_bloc/project_cubit.dart';
import 'package:taskaty/blocs/project_bloc/project_state.dart';
import 'package:taskaty/blocs/upcoming_task_bloc/upcoming_task_cubit.dart';
import 'package:taskaty/blocs/upcoming_task_bloc/upcoming_task_state.dart';
import 'package:taskaty/blocs/user_bloc/user_cubit.dart';
import 'package:taskaty/blocs/user_bloc/user_state.dart';
import 'package:taskaty/models/user_model.dart';
import 'package:taskaty/repo/user_repository.dart';
import 'package:taskaty/services/notification_services.dart';
import 'package:taskaty/ui/nav_bar/edit_profile.dart';
import 'package:taskaty/ui/project/seeAllProjectsPage.dart';
import 'nav_bar/myTask_navBar.dart';
import 'package:taskaty/widgets/stateful/project_widget.dart';
import 'package:taskaty/utils/constants.dart';
import 'package:taskaty/utils/shared.dart';
import 'project/add_project_screen.dart';
import 'package:taskaty/widgets/shared/custom_button.dart';
import 'package:taskaty/widgets/shared/shared_widgets.dart';
import 'package:taskaty/widgets/stateful/CurrentTaskList.dart';
import 'package:url_launcher/url_launcher.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String message;
  PushNotificationServices fcm = PushNotificationServices(auth: FirebaseAuth.instance,
      usersRepository: UserRepository(),messaging: FirebaseMessaging.instance);

  @override
  void initState() {
    super.initState();
    fcm.initiate();
     message = DateTime.now().hour < 12 ? "Good morning" : "Good afternoon";
    BlocProvider.of<ProjectCubit>(context).getAllProjects(Utils.getCurrentUser(context));
    BlocProvider.of<UpcomingTaskCubit>(context).getAllCurrentTasks();
    BlocProvider.of<AuthCubit>(context).loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    final AppUser appUser = Utils.getCurrentUser(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: white,
      drawer: SafeArea(
        child: Drawer(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: BlocBuilder<UserCubit,UserState>(
              builder: (context,state) {
                return state is UserLoaded ?
                Column(
                  children: [
                  Align(
                        alignment: Alignment.topCenter,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: darkNavy,
                          child: Center(
                            child: Text('${Utils.getInitials(state.appUser.name)}',style: TextStyle(fontSize: 35,color: white,),),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${state.appUser.name}', style: TextStyle(
                        fontSize: 20,
                        color: darkNavy,
                      ),textAlign: TextAlign.center,),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 40),
                      child: new Divider(height: 1,color: black,),
                    ),
                  ListTile(
                        leading: Icon(Icons.person,size: 23,color: darkNavy,),
                        title: Text('Edit Profile', style: TextStyle(
                            fontSize: 19,
                            color: darkNavy,
                        ),),
                        onTap: (){
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen(appUser: state.appUser,)));
                        },
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Divider(height: 1,color: black,),
                    ),
                    ListTile(
                      leading: Icon(Icons.inbox,size: 23,color: darkNavy,),
                      title: Text('To Do Tasks', style: TextStyle(
                        fontSize: 19,
                        color: darkNavy,
                      ),),
                      onTap: (){
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (builder) {
                            return SeeAllMyTaskPage();
                          },
                        ));
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Divider(height: 1,color: black,),
                    ),
                   ListTile(
                        leading: Icon(Icons.rate_review_outlined,color: darkNavy,size: 23,),
                        title: Text('Rate Our App', style: TextStyle(
                          fontSize: 19,
                          color: darkNavy,
                        ),),
                        onTap: ()async{
                          await launch(APP_LINK);
                        },
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Divider(height: 1,color: black,),
                    ),
                    ListTile(
                      leading: Icon(Icons.logout,color: darkNavy,size: 23,),
                      title: Text('Logout', style: TextStyle(
                        fontSize: 19,
                        color: darkNavy,
                      ),),
                      onTap: (){
                        BlocProvider.of<AuthCubit>(context).signOut();
                        BlocProvider.of<UserCubit>(context).emit(UserInitial());
                        int count = 0;
                        Navigator.of(context).popUntil((_) => count++ >= 2);
                      },
                    ),
                  ],
                ) : Column(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: darkNavy,
                        child: Center(
                          child: Text('${Utils.getInitials(appUser.name)}',style: TextStyle(fontSize: 35,color: white,),),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${appUser.name}', style: TextStyle(
                        fontSize: 20,
                        color: darkNavy,
                      ),textAlign: TextAlign.center,),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 40),
                      child: new Divider(height: 1,color: black,),
                    ),
                    ListTile(
                      leading: Icon(Icons.person,size: 23,color: darkNavy,),
                      title: Text('Edit Profile', style: TextStyle(
                        fontSize: 19,
                        color: darkNavy,
                      ),),
                      onTap: (){
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen(appUser: appUser,)));
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Divider(height: 1,color: black,),
                    ),
                    ListTile(
                      leading: Icon(Icons.inbox,size: 23,color: darkNavy,),
                      title: Text('To Do Tasks', style: TextStyle(
                        fontSize: 19,
                        color: darkNavy,
                      ),),
                      onTap: (){
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (builder) {
                            return SeeAllMyTaskPage();
                          },
                        ));
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Divider(height: 1,color: black,),
                    ),
                    ListTile(
                      leading: Icon(Icons.rate_review_outlined,color: darkNavy,size: 23,),
                      title: Text('Rate Our App', style: TextStyle(
                        fontSize: 19,
                        color: darkNavy,
                      ),),
                      onTap: ()async{
                        await launch(APP_LINK);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Divider(height: 1,color: black,),
                    ),
                    ListTile(
                      leading: Icon(Icons.logout,color: darkNavy,size: 23,),
                      title: Text('Logout', style: TextStyle(
                        fontSize: 19,
                        color: darkNavy,
                      ),),
                      onTap: (){
                        BlocProvider.of<AuthCubit>(context).signOut();
                        BlocProvider.of<UserCubit>(context).emit(UserInitial());
                        int count = 0;
                        Navigator.of(context).popUntil((_) => count++ >= 2);
                      },
                    ),
                  ],
                );
              }
            ),
          ),
        ),
      ),
     body: SafeArea(
       child: SingleChildScrollView(
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.center,
           children: [
             Align(
               alignment: Alignment.topCenter,
               child: Container(
                   height: SizeConfig.screenHeight * 0.2,
                   width: SizeConfig.screenWidth,
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.only(bottomRight: Radius.circular(20),bottomLeft: Radius.circular(20)),
                     gradient: myGradient(),
                   ),
                   child: Stack(alignment: Alignment.topCenter,
                     children: [
                       Positioned(
                         child: Image.asset('assets/free_app_icon.png',height: 50,width: 50,),
                         top: 10,
                       ),
                       Positioned(
                           child: IconButton(
                            icon: Icon(Icons.menu),
                             color: white,
                             onPressed: () {
                               _scaffoldKey.currentState.openDrawer();
                             },
                       ),
                         left: 5,
                       ),
                       BlocBuilder<UserCubit,UserState>(
                         builder: (context,state) {
                           return state is UserLoaded ?
                           Positioned(
                             top: SizeConfig.screenHeight * 0.12,
                             child: Text('$message, ${state.appUser.name.split(' ')[0]}', style: TextStyle(
                               fontSize: 23,
                               color: white,
                             ),textAlign: TextAlign.center,),) :

                           Positioned(
                             top: SizeConfig.screenHeight * 0.12,
                             child: Text('$message, ${Utils.getCurrentUser(context).name.split(' ')[0]}', style: TextStyle(
                               fontSize: 23,
                               color: white,
                             ),textAlign: TextAlign.center,),);
                         }
                       ),

                     ],
                   ),
                 ),
               ),
             const SizedBox(height: 30,),

             BlocConsumer<ProjectCubit,ProjectState>(
                 builder: (ctx,state){
                   if(state is ProjectFailure){
                     return Text(
                       'Data load error, please try again later!',
                       style: TextStyle(
                         fontSize: 19,
                         color: darkNavy,
                       ),
                     );

                   }else if (state is ProjectsLoaded){
                     return state.projectsList.isNotEmpty ?
                     Column( crossAxisAlignment: CrossAxisAlignment.center,
                       children: [
                         Padding(
                           padding: const EdgeInsets.all(10.0),
                           child: Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             crossAxisAlignment: CrossAxisAlignment.center,
                             children: [
                               Text('Current Projects', style: TextStyle(
                                 fontSize: 19,
                                 color: darkNavy,
                                 fontWeight: FontWeight.w500,
                               ),),
                               GestureDetector(
                                 onTap: () {
                                   Navigator.of(context).push(MaterialPageRoute(
                                     builder: (builder) {
                                       return SeeAllProjectsPage(title: 'My Projects',tasksList: state.projectsList,);
                                     },
                                   ));
                                 },
                                 child: Text(
                                   'View all projects',
                                   style: TextStyle(
                                     fontSize: 19,
                                     color: darkNavy,
                                     fontWeight: FontWeight.w500,
                                   ),
                                 ),
                               ),
                             ],
                           ),
                         ),
                         Container(
                           height: SizeConfig.screenHeight * 0.2,
                           child: ListView.builder(
                               scrollDirection: Axis.horizontal,
                               itemCount: state.projectsList.take(4).length,
                               itemBuilder: (context,index) {
                               return ProjectWidget(model: state.projectsList[index]);
                             }
                           ),
                         ),
                       ],
                     )
                     : _emptyProjectsWidget(context);

                   }else{
                     return Container(
                       height: SizeConfig.screenHeight * 0.2,
                       child: ListView.builder(
                           scrollDirection: Axis.horizontal,
                           itemCount: 4,
                           itemBuilder: (context,index){
                             return loadProjectsShimmer();
                           }),
                     );
                   }
                 }, listener: (ctx,state){}),

             const SizedBox(height: 50,),

             BlocConsumer<UpcomingTaskCubit,MyUpcomingTaskState>(
                 builder: (ctx,state){
                   if(state is UpTaskFailure){
                     return Padding(
                       padding: const EdgeInsets.all(8.0),
                       child: Text(
                         'Data load error, please try again later!',
                         style: TextStyle(
                           fontSize: 19,
                           color: darkNavy,
                         ),
                       ),
                     );

                   }else if (state is UpcomingTasksLoaded){
                     return state.upTasks.isNotEmpty ?
                     Column(crossAxisAlignment: CrossAxisAlignment.center,
                       children: [
                         Padding(
                           padding: const EdgeInsets.all(10.0),
                           child: Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             crossAxisAlignment: CrossAxisAlignment.center,
                             children: [
                               Text('To Do Tasks', style: TextStyle(
                                 fontSize: 19,
                                 color: darkNavy,
                                 fontWeight: FontWeight.w500,
                               ),),
                               GestureDetector(
                                 onTap: () {
                                   Navigator.of(context).push(MaterialPageRoute(
                                     builder: (builder) {
                                       return SeeAllMyTaskPage();
                                     },
                                   ));
                                 },
                                 child: Text(
                                   'View all tasks',
                                   style: TextStyle(
                                     fontSize: 19,
                                     color: darkNavy,
                                     fontWeight: FontWeight.w500,
                                   ),
                                 ),
                               ),
                             ],
                           ),
                         ),
                         Container(
                           height: SizeConfig.screenHeight * 0.36,
                           child: ListView.builder(
                               scrollDirection: Axis.horizontal,
                               itemCount: state.upTasks.take(4).length,
                               itemBuilder: (context,index){
                                 return Column(
                                   children: [
                                     Expanded(child: CurrentTaskList(task: state.upTasks[index])),
                                     Padding(
                                       padding: const EdgeInsets.all(5.0),
                                       child: Text('(${ state.upTasks[index].projectName})',
                                         style: TextStyle(letterSpacing: 1,fontWeight: FontWeight.w500,color: darkNavy,fontSize: 16),),
                                     ),
                                     const SizedBox(height: 10,),
                                   ],
                                 );
                               }),
                         ),
                       ],
                     )
                         : Center(
                           child: Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             crossAxisAlignment: CrossAxisAlignment.center,
                             children: [
                               const SizedBox(height: 20,),
                               Image.asset('assets/list.png'),
                               Padding(padding: const EdgeInsets.all(4.0)),
                               Text(
                                 "You don't have any To Do tasks!",
                                 style: TextStyle(
                                     color: Colors.black38,
                                     fontSize: 18.0,
                                     fontWeight: FontWeight.w500),
                               ),
                             ],
                           ),
                     );

                   }else{
                     return Container(
                       height: SizeConfig.screenHeight * 0.3,
                       child: ListView.builder(
                           scrollDirection: Axis.horizontal,
                           itemCount: 4,
                           itemBuilder: (context,index){
                             return loadUpcomingShimmer();
                           }),
                     );
                   }
                 }, listener: (ctx,state){}),
           ],
         ),
       ),
     ),
      bottomNavigationBar: Container(
        height: 25,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
          color: lightNavy
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: this._navigateToAddProjectScreen,
        backgroundColor: lightNavy,
        foregroundColor: Colors.white,
        child: Icon(Icons.drive_file_rename_outline,color: white,),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _navigateToAddProjectScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return AddProjectScreen();
        },
      ),
    );
  }

  _emptyProjectsWidget(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const SizedBox(height: 15,),
          Text('You are not contributed in any project yet!', style: TextStyle(
            fontSize: 20,
            color: darkNavy,
          ),textAlign: TextAlign.center,),
          const SizedBox(height: 15,),
          Center(
            child: RaisedGradientButton(
                width: SizeConfig.screenWidth * 0.4,
                height: SizeConfig.screenHeight * 0.1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Go create one!',style: TextStyle(fontSize: SizeConfig.blockSizeVertical * 2.6,color: white),),
                ),
                gradient: myGradient(),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AddProjectScreen()));
                }
            ),
          ),
        ],
      ),
    );
  }

}
