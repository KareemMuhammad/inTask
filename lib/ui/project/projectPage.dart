import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskaty/blocs/task_bloc/task_cubit.dart';
import 'package:taskaty/blocs/task_bloc/task_state.dart';
import 'package:taskaty/helper_functions/ReminderHelper.dart';
import 'package:taskaty/models/project_model.dart';
import 'package:taskaty/models/task_model.dart';
import 'package:taskaty/ui/project/edit_project.dart';
import 'package:taskaty/widgets/shared/custom_button.dart';
import 'package:taskaty/widgets/shared/shared_widgets.dart';
import '../task/seeAllPage.dart';
import '../task/viewTaskPage.dart';
import 'package:taskaty/utils/constants.dart';
import 'package:taskaty/utils/shared.dart';
import 'package:taskaty/widgets/stateful/GetTaskByDate.dart';
import 'package:taskaty/widgets/stateful/TaskList.dart';
import '../../helper_functions/DateTimeHelper.dart';
import '../task/addTaskPage.dart';

class ProjectPage extends StatefulWidget {
  final ProjectModel projectModel;

  const ProjectPage({Key key, this.projectModel}) : super(key: key);
  @override
  _ProjectPageState createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  LocalNotification _localNotification = LocalNotification();
  List<MyTask> _allToDoTasks;
  List<MyTask> _allDoingTasks;
  List<MyTask> _allDoneTasks;
  String weekDay,month;

  String _date = 'Task Manager';

  void _navigateToAddTaskScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return AddTaskPage();
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<MyTaskCubit>(context).getAllProjectTasks(widget.projectModel.id);
    var now = new DateTime.now();
    Utils.setCurrentProject(context, widget.projectModel);
    weekDay = getWeekday(now.weekday);
     month = getMonth(now.month);
    int day = now.day;
    this._date = '$weekDay $day, $month';
    _localNotification.init(this.selectNotification, this.onDidReceiveLocalNotification);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: CustomScrollView(
          slivers: [
            buildSliverAppBar(),
            SliverList(
                delegate: SliverChildListDelegate(
              [
                BlocBuilder<MyTaskCubit,MyTaskState>(
                  builder: (BuildContext context, state) {
                    if (state is TaskLoaded) {
                      _allToDoTasks = state.tasks.where((element) => element.status == Utils.TO_DO).toList();
                      _allDoingTasks = state.tasks.where((element) => element.status == Utils.DOING).toList();
                      _allDoneTasks = state.tasks.where((element) => element.status == Utils.DONE).toList();
                      return state.tasks.isEmpty ?
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20,),
                            Image.asset('assets/list.png'),
                            Padding(padding: const EdgeInsets.all(4.0)),
                            Text(
                              "You don't have any tasks!",
                              style: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 15,),
                            Center(
                              child: RaisedGradientButton(
                                  width: SizeConfig.screenWidth * 0.4,
                                  height: SizeConfig.screenHeight * 0.1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Go add one!',style: TextStyle(fontSize: SizeConfig.blockSizeVertical * 2.2,color: white),),
                                  ),
                                  gradient: myGradient(),
                                  onPressed: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => AddTaskPage()));
                                  }
                              ),
                            ),
                          ],
                        ),
                      ):
                      Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Text(
                                    "To Do",
                                    style: TextStyle(
                                        color: black,
                                        fontSize: 20.0,
                                        fontFamily: 'OrelegaOne',
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 5,),
                                  Icon(
                                    Icons.radio_button_checked,
                                    color: Colors.lightBlue[300],
                                    size: 15.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          _allToDoTasks.isEmpty?
                          Center(child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Icon(Icons.inbox,color: Colors.grey[600],),
                                Text(
                                  "To Do list is empty",
                                  style: TextStyle(
                                      color: Colors.black38,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ))
                              :  Container(
                                height: SizeConfig.screenHeight * 0.3,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _allToDoTasks.length,
                                    itemBuilder: (context,index){
                                      return new TaskList(task: _allToDoTasks[index] );
                                    }),
                          ),
                          _allToDoTasks.isEmpty?
                          const SizedBox()
                              : Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(1,5,10,10),
                                  child: GestureDetector(
                                    onTap: (){
                                      Navigator.of(context).push(MaterialPageRoute(
                                        builder: (builder) {
                                          return SeeAllPage(title: Utils.TO_DO,tasksList: _allToDoTasks,);
                                        },
                                      ));
                                    },
                                    child: Text(
                                      "See all",
                                      style: TextStyle(
                                          color: black,
                                          fontSize: 16.0,
                                          fontFamily: 'OrelegaOne',
                                          fontWeight: FontWeight.w500,decoration: TextDecoration.underline),
                                    ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Text(
                                    "Doing",
                                    style: TextStyle(
                                        color: black,
                                        fontFamily: 'OrelegaOne',
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 5,),
                                  Icon(
                                    Icons.radio_button_checked,
                                    color: button,
                                    size: 15.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          _allDoingTasks.isEmpty?
                          Center(child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Icon(Icons.inbox,color: Colors.grey[600],),
                                Text(
                                  "Doing list is empty",
                                  style: TextStyle(
                                      color: Colors.black38,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ))
                              : Container(
                                height: SizeConfig.screenHeight * 0.3,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _allDoingTasks.length,
                                    itemBuilder: (context,index){
                                      return new TaskList(task: _allDoingTasks[index] );
                                    }),
                          ),
                          _allDoingTasks.isEmpty?
                          const SizedBox()
                              :  Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(1,5,10,10),
                                  child: GestureDetector(
                                    onTap: (){
                                      Navigator.of(context).push(MaterialPageRoute(
                                        builder: (builder) {
                                          return SeeAllPage(title: Utils.DOING,tasksList: _allDoingTasks,);
                                        },
                                      ));
                                    },
                                    child: Text(
                                      "See all",
                                      style: TextStyle(
                                          color: black,
                                          fontFamily: 'OrelegaOne',
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w500,decoration: TextDecoration.underline),
                                    ),
                                  ),
                                ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Text(
                                    "Done",
                                    style: TextStyle(
                                        color: black,
                                        fontSize: 20.0,
                                        fontFamily: 'OrelegaOne',
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 5,),
                                  Icon(
                                    Icons.radio_button_checked,
                                    color: Colors.green,
                                    size: 15.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                         _allDoneTasks.isEmpty?
                         Center(child: Padding(
                           padding: const EdgeInsets.all(10.0),
                           child: Column(
                             children: [
                               Icon(Icons.inbox,color: Colors.grey[600],),
                               Text(
                                 "Done list is empty",
                                 style: TextStyle(
                                     color: Colors.black38,
                                     fontSize: 16.0,
                                     fontWeight: FontWeight.w500),
                               ),
                             ],
                           ),
                         ))
                         :Container(
                           height: SizeConfig.screenHeight * 0.3,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _allDoneTasks.length,
                                itemBuilder: (context,index){
                                  return new TaskList(task: _allDoneTasks[index] ,);
                                }),
                          ),
                          _allDoneTasks.isEmpty?
                          const SizedBox()
                              : Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(1,5,10,10),
                                 child: GestureDetector(
                                  onTap: (){
                                    Navigator.of(context).push(MaterialPageRoute(
                                      builder: (builder) {
                                        return SeeAllPage(title: Utils.DONE,tasksList: _allDoneTasks,);
                                      },
                                    ));
                                  },
                                  child: Text(
                                    "See all",
                                    style: TextStyle(
                                        color: black,
                                        fontSize: 16.0,
                                        fontFamily: 'OrelegaOne',
                                        fontWeight: FontWeight.w500,decoration: TextDecoration.underline),
                                  ),
                                ),
                            ),
                          ),
                          const SizedBox(height: 20,),
                        ],
                      );
                    }else if(state is TaskFailure){
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Center(
                          child: Text(
                            'Data load error, please try again later!',
                            style: TextStyle(
                              fontSize: 19,
                              color: darkNavy,
                            ),
                          ),
                        ),
                      );
                    }else {
                      return GridView.builder(
                        itemCount: 6,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,childAspectRatio: 0.9),
                        itemBuilder: (BuildContext context, int index) {
                          return loadTaskShimmer();
                        },
                      );
                    }
                  },
                ),
              ]
            ))
          ],
        ),
      bottomNavigationBar: buildBottomNavigationBar(context),
      floatingActionButton: FloatingActionButton(
        onPressed: this._navigateToAddTaskScreen,
        mini: true,
        backgroundColor: lightNavy,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
    );
  }

  Widget buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: SizeConfig.screenWidth * 0.25,
      pinned: true,
      stretch: true,
      backgroundColor: darkNavy,
      actions: [
       Utils.getCurrentUser(context).id == widget.projectModel.ownerId ?
       IconButton(
            onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(
                builder: (builder) {
                  return EditProject();
                },
              ));
            },
            icon: Icon(Icons.drive_file_rename_outline),
            color: white,) : const SizedBox(),
      ],
      flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('${Utils.getCurrentProject(context) == null ?
                widget.projectModel.name : Utils.getCurrentProject(context).name}',maxLines: 2,
                      style: TextStyle(color: white,fontSize: 20,overflow: TextOverflow.clip,),
                    ),
              ) ,
            ),
            background: Container(
              decoration: BoxDecoration(
               gradient:  myGradient(),
              ),
            )
      ),
    );
  }

  BottomNavigationBar buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.dashboard,
            color: Color(0xffbebebe),
          ),
          activeIcon: Icon(
            Icons.dashboard,
            color: lightNavy,
          ),
          label: ' '
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.date_range,
            color: Color(0xffbebebe),
          ),
          activeIcon: Icon(
            Icons.date_range,
            color: Theme.of(context).primaryColor,
          ),
          label: ' ',
        ),
      ],
      onTap: (index) async{
        if (index == 1) {
          await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            builder: (BuildContext context, Widget child) {
              return Theme(
                data: ThemeData.light().copyWith(
                  primaryColor: darkNavy,
                  accentColor: lightNavy,
                  colorScheme: ColorScheme.light(primary: lightNavy),
                  buttonTheme: ButtonThemeData(
                      textTheme: ButtonTextTheme.primary
                  ),
                ),
                child: child,
              );
            },
          ).then((value) {
              if(value != null) {
                _date = value.toString().split(' ')[0];
                _date = '${value.day}/${value.month}/${value.year}';
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => GetTaskByDate(date: _date,)));
              }
          });
        }
      },
    );
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewTaskPage(payload),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Future selectNotification(String payload) {
    return Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return ViewTaskPage(payload);
    }));
  }
}
