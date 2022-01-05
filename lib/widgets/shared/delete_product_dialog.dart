import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskaty/blocs/project_bloc/project_cubit.dart';
import 'package:taskaty/blocs/task_bloc/task_cubit.dart';
import 'package:taskaty/blocs/upcoming_task_bloc/upcoming_task_cubit.dart';
import 'package:taskaty/models/task_model.dart';
import 'package:taskaty/utils/constants.dart';
import 'package:taskaty/widgets/shared/shared_widgets.dart';
import '../../utils/shared.dart';
import 'custom_button.dart';

class DeleteProdDialog extends StatelessWidget {
  final ProjectCubit projectCubit;

  const DeleteProdDialog({Key key, this.projectCubit,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig.screenHeight * 0.5,
      padding: EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Column(
          children: [
           const SizedBox(height: 20,),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text('Once you delete a project, all its tasks will be lost too'
                    '\n do you really want to delete this project?',style: TextStyle(fontSize: 3 * SizeConfig.blockSizeVertical,color: darkNavy,)
                  ,textAlign: TextAlign.center,),
              ),
            ),
           const SizedBox(height: 15,),
            Padding(
              padding: const EdgeInsets.all(10),
              child: RaisedGradientButton(
                  width: SizeConfig.screenWidth * 0.3,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Delete',style: TextStyle(fontSize: 20,color: white),),
                  ),
                  gradient: myGradient(),
                  onPressed: ()async{
                    await manageDelete(context);
                    projectCubit.deleteProject(Utils.getCurrentProject(context), Utils.getCurrentUser(context));
                    Navigator.pop(context);
                  }
              ),
            ),
          ],
      ),
    );
  }

  Future manageDelete(BuildContext context) async{
    final List<MyTask> list = BlocProvider.of<MyTaskCubit>(context).tasksList;
    for(MyTask task in list){
      BlocProvider.of<MyTaskCubit>(context).deleteTask(task, Utils.getCurrentProject(context).id);
      BlocProvider.of<UpcomingTaskCubit>(context).deleteTask(task);
    }
  }
}
