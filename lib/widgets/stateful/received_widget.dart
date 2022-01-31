import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskaty/blocs/invitation_bloc/invitation_cubit.dart';
import 'package:taskaty/blocs/project_bloc/project_cubit.dart';
import 'package:taskaty/models/invitaion_model.dart';
import 'package:taskaty/models/project_model.dart';
import 'package:taskaty/utils/constants.dart';
import 'package:taskaty/utils/shared.dart';

class ReceivedWidget extends StatelessWidget {
  final InvitationModel invitationModel;

  const ReceivedWidget({Key key, this.invitationModel}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final InvitationCubit invitationCubit = BlocProvider.of<InvitationCubit>(context);
    final ProjectCubit projectCubit = BlocProvider.of<ProjectCubit>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        color: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ListTile(
                title: Text('${invitationModel.ownerName.split(' ')[0]} invited you to join ${invitationModel.project.name} project',
                  style: TextStyle(color: black,fontSize: 18),),
                subtitle: Text('${Utils.getProjectTimeAgo(invitationModel.date.split(' ')[0])}', style: TextStyle(color: Colors.grey[800],fontSize: 17),),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.green[800],
                      radius: 22,
                      child: IconButton(
                        onPressed: ()async{
                          final ProjectModel model = invitationModel.project;
                          model.teamMates.add(Utils.getCurrentUser(context));
                          model.teamIds.add(Utils.getCurrentUser(context).id);
                          await projectCubit.editProject(model);
                          invitationCubit.removeInviteFromProject(invitationModel);
                        },
                        icon: const Icon(Icons.done),
                        iconSize: 26,
                        color: white,
                      ),
                    ),
                    const SizedBox(width: 15,),
                    CircleAvatar(
                      backgroundColor: button,
                      radius: 22,
                      child: IconButton(
                        onPressed: (){
                          invitationCubit.removeInviteFromProject(invitationModel);
                        },
                        icon: const Icon(Icons.clear),
                        iconSize: 26,
                        color: white,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
