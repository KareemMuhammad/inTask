import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskaty/blocs/task_bloc/task_cubit.dart';
import 'package:taskaty/models/task_model.dart';
import 'package:taskaty/utils/shared.dart';
import 'package:taskaty/widgets/stateful/TaskList.dart';

class GetTaskByDate extends StatelessWidget {
  final String date;

  const GetTaskByDate({Key key, this.date}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final MyTaskCubit taskCubit = BlocProvider.of<MyTaskCubit>(context);
    final FirebaseAuth auth = FirebaseAuth.instance;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: white,
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          backgroundColor: darkNavy,
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('$date',style: TextStyle(color: white,fontSize: 19),),
          ),
        ),
        backgroundColor: white,
        body: FutureBuilder<List<MyTask>>(
          future: taskCubit.getTasksOfDate(date,auth.currentUser.uid),
          builder: (BuildContext context, AsyncSnapshot<List<MyTask>> snapshot) {
            return snapshot.data != null && snapshot.data.isNotEmpty ?
            GridView.builder(
                itemCount: snapshot.data.length ?? 0,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,childAspectRatio: 1),
                itemBuilder: (context,index){
                  return TaskList(task: snapshot.data[index],);
                }) : Center(child: Text('No Tasks at that date',style: TextStyle(color: Colors.grey[700],fontSize: 18),),);
          },
        )
    );
  }
}
