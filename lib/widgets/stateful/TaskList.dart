import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskaty/blocs/task_bloc/task_cubit.dart';
import 'package:taskaty/blocs/upcoming_task_bloc/upcoming_task_cubit.dart';
import 'package:taskaty/ui/task/editTaskPage.dart';
import '../../ui/task/viewTaskPage.dart';
import 'package:taskaty/utils/constants.dart';
import 'package:taskaty/utils/shared.dart';
import '../../models/task_model.dart';

class TaskList extends StatefulWidget {
  final MyTask task;

  const TaskList({Key key, this.task}) : super(key: key);
  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {

  void _dropDownAction(String action, MyTask task) async{
    switch (action) {
      case "View":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ViewTaskPage(task.id);
            },
          ),
        );

        break;
      case "Edit":
        {
          if(task.assignee.contains(Utils.getCurrentUser(context).id)) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return EditTaskPage(task);
                },
              ),
            );
          }
        }
        break;
      case "Delete":
        {
          if(task.holderId == Utils.getCurrentUser(context).id) {
            if (task.image.isNotEmpty) {
              await deleteTaskImageUrls(task.image);
            }
            BlocProvider.of<MyTaskCubit>(context).deleteTask(task,Utils.getCurrentProject(context).id);
            BlocProvider.of<UpcomingTaskCubit>(context).removeFromList(task);
          }
        }
        break;
      case "Done":
        if(task.assignee.contains(Utils.getCurrentUser(context).id))
        BlocProvider.of<MyTaskCubit>(context).taskStatus(Utils.DONE,task.id,Utils.getCurrentProject(context).id);
        BlocProvider.of<UpcomingTaskCubit>(context).taskStatus(Utils.DONE,task.id);
        break;
      case "To Do":
        if(task.assignee.contains(Utils.getCurrentUser(context).id))
        BlocProvider.of<MyTaskCubit>(context).taskStatus(Utils.TO_DO,task.id,Utils.getCurrentProject(context).id);
        BlocProvider.of<UpcomingTaskCubit>(context).taskStatus(Utils.TO_DO,task.id);
        break;
      case "Doing":
        if(task.assignee.contains(Utils.getCurrentUser(context).id))
        BlocProvider.of<MyTaskCubit>(context).taskStatus(Utils.DOING,task.id,Utils.getCurrentProject(context).id);
        BlocProvider.of<UpcomingTaskCubit>(context).taskStatus(Utils.DOING,task.id);
        break;
    }
  }

  Future deleteTaskImageUrls(List<String> imagesUrls)async{
    for(String url in imagesUrls){
      await FirebaseStorage.instance.refFromURL(url).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
                  margin: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                  color: white,
                  elevation: 6,
                  shadowColor: Colors.lightBlue[50],
                  child: Container(
                    width: SizeConfig.screenWidth * 0.4,
                    margin: const EdgeInsets.all(8.0),
                    child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 5.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.task.task,
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            color: black,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.clip,
                                          textAlign: TextAlign.start,
                                        ),
                                      ),

                                      dropdownButton(widget.task,context),
                                    ],
                                  ),
                                ),
                             Expanded(
                               child: Text(
                                      widget.task.description,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.grey[900],
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 1
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      textAlign: TextAlign.start,

                                    ),
                             ),

                                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    widget.task.assignee.length > 1 ?
                                    Row(
                                      children: [
                                        Icon(Icons.person,size: 17,color: Colors.grey[600],),
                                        Text(
                                          '${widget.task.assignee.length - 1}',
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.grey[800],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ): const SizedBox(),
                                    widget.task.image.isNotEmpty ?
                                    Icon(Icons.image,size: 17,color: Colors.grey[600],): const SizedBox(),
                                    widget.task.audioDescription ?
                                        Icon(Icons.mic,size: 17,color: Colors.grey[600],): const SizedBox(),
                                   ],
                                ),
                                Spacer(),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Column(
                                      children: [
                                        Text(
                                          widget.task.time,
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.grey[800],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 5,),
                                        Text(
                                          widget.task.date,
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.grey[800],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
    );
  }

  DropdownButton dropdownButton(MyTask task,BuildContext context) {
    List<DropdownMenuItem<dynamic>> todoItems = [
      DropdownMenuItem(
        child: Text(
          'View Task',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
        value: 'View',
      ),
      if(task.assignee.contains(Utils.getCurrentUser(context).id))
      DropdownMenuItem(
        child: Text(
          'Edit task',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
        value: 'Edit',
      ),
      if(task.holderId == Utils.getCurrentUser(context).id)
      DropdownMenuItem(
        child: Text(
          'Delete Task',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
        value: 'Delete',
      ),
      if(task.assignee.contains(Utils.getCurrentUser(context).id))
      DropdownMenuItem(
        child: Text(
          'Mark Doing',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
        value: 'Doing',
      ),
      if(task.assignee.contains(Utils.getCurrentUser(context).id))
      DropdownMenuItem(
        child: Text(
          'Mark Done',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
        value: 'Done',
      ),
    ];

    List<DropdownMenuItem<dynamic>> doingItems = [
      DropdownMenuItem(
        child: Text(
          'View Task',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
        value: 'View',
      ),
      if(task.assignee.contains(Utils.getCurrentUser(context).id))
      DropdownMenuItem(
        child: Text(
          'Edit task',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
        value: 'Edit',
      ),
      if(task.holderId == Utils.getCurrentUser(context).id)
        DropdownMenuItem(
          child: Text(
            'Delete Task',
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
          value: 'Delete',
        ),
      if(task.assignee.contains(Utils.getCurrentUser(context).id))
      DropdownMenuItem(
        child: Text(
          'Mark To Do',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
        value: 'To Do',
      ),
      if(task.assignee.contains(Utils.getCurrentUser(context).id))
      DropdownMenuItem(
        child: Text(
          'Mark Done',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
        value: 'Done',
      ),
    ];

    List<DropdownMenuItem<dynamic>> doneItems = [
      DropdownMenuItem(
        child: Text(
          'View Task',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
        value: 'View',
      ),
      if(task.assignee.contains(Utils.getCurrentUser(context).id))
      DropdownMenuItem(
        child: Text(
          'Edit task',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
        value: 'Edit',
      ),
      if(task.holderId == Utils.getCurrentUser(context).id)
      DropdownMenuItem(
        child: Text(
          'Delete Task',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
        value: 'Delete',
      ),
      if(task.assignee.contains(Utils.getCurrentUser(context).id))
      DropdownMenuItem(
        child: Text(
          'Mark To Do',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
        value: 'To Do',
      ),
      if(task.assignee.contains(Utils.getCurrentUser(context).id))
      DropdownMenuItem(
        child: Text(
          'Mark Doing',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
        value: 'Doing',
      ),
    ];

    return DropdownButton(
      underline: SizedBox(
        height: null,
        width: null,
      ),
      icon: Icon(
        Icons.more_horiz,
        color: Colors.grey[800],
      ),
      elevation: 2,
      items: task.status == Utils.TO_DO ? todoItems
           : task.status == Utils.DOING ? doingItems
           : doneItems,
      onChanged: (value) {
        this._dropDownAction(value, task);
      },
    );
  }
}
