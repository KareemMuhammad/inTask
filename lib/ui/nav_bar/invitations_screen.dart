import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskaty/blocs/invitation_bloc/invitation_cubit.dart';
import 'package:taskaty/blocs/invitation_bloc/invitation_state.dart';
import 'package:taskaty/blocs/project_bloc/project_cubit.dart';
import 'package:taskaty/utils/constants.dart';
import 'package:taskaty/utils/shared.dart';
import 'package:taskaty/widgets/shared/shared_widgets.dart';
import 'package:taskaty/widgets/stateful/received_widget.dart';

class InvitationsScreen extends StatefulWidget {
  @override
  _InvitationsScreenState createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen> {
  @override
  void initState() {
    BlocProvider.of<InvitationCubit>(context).emit(InvitationInitial());
    BlocProvider.of<InvitationCubit>(context).getAllInvitationsOfReceived(Utils.getCurrentUser(context).id);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final ProjectCubit projectCubit = BlocProvider.of<ProjectCubit>(context);
    final InvitationCubit invitationCubit = BlocProvider.of<InvitationCubit>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Invitations Screen',
          style: TextStyle(
            color: white,
            fontFamily: 'OrelegaOne',
          ),
        ),
      ),
      backgroundColor: white,
      body: BlocConsumer<InvitationCubit,InvitationState>(
            listener: (ctx,state){
               if(state is InvitationUpdated){
                 invitationCubit.getAllInvitationsOfReceived(Utils.getCurrentUser(context).id);
                 projectCubit.getAllProjects(Utils.getCurrentUser(context));
               }
            },
            builder: (ctx,state){
              if(state is ReceivedInvitationLoading){
                return ListView.builder(
                        itemCount: 4,
                        itemBuilder: (context,index){
                          return loadUpcomingShimmer();
                    });
              }else if(state is ReceivedInvitationsLoaded){
                return state.receivedList.isEmpty ?
                _loadingWidget()
                    :ListView.builder(
                      itemCount: state.receivedList.length,
                      itemBuilder: (ctx,index){
                        return ReceivedWidget(invitationModel: state.receivedList[index],);
                  },
                );
              }else{
                return _loadingWidget();
              }
            },
          ),
    );
  }

  Widget _loadingWidget(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20,),
          Icon(Icons.email,color: Colors.grey[700],size: 30,),
          Padding(padding: const EdgeInsets.all(4.0)),
          Text(
            "You don't have any invitations!",
            style: TextStyle(
                color: Colors.black38,
                fontSize: 18.0,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
