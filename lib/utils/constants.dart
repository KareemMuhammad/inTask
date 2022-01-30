import 'dart:convert';
import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:taskaty/models/project_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:taskaty/blocs/auth_bloc/auth_cubit.dart';
import 'package:taskaty/blocs/project_bloc/project_cubit.dart';
import 'package:taskaty/models/notification_model.dart';
import 'package:taskaty/models/user_model.dart';
import 'package:taskaty/utils/shared.dart';
import 'package:uuid/uuid.dart';
import '../main.dart';
import 'package:intl/intl.dart' as intl;

class Utils{

  static const String FCM_URL = 'https://fcm.googleapis.com/fcm/send';
  static const List<String> splashes = ['assets/splash1.jpeg'];
  static const String TO_DO = "To Do";
  static const String DOING = "Doing";
  static const String DONE = "Done";
  static const String APP_ICON = "https://firebasestorage.googleapis.com/v0/b/taskaty-9dbe5.appspot.com/o/app_icon.jpeg?alt=media&token=709f7992-75e4-4d6f-b183-14c0eb1dbc60";

  static AppUser getCurrentUser(BuildContext context){
    final AppUser currentUser = BlocProvider.of<AuthCubit>(context).getUser;
    return currentUser;
  }

  static List<AppUser> getCurrentUsers(BuildContext context){
    final List<AppUser> currentUser = BlocProvider.of<AuthCubit>(context).getAllUsersList;
    return currentUser;
  }

  static ProjectModel getCurrentProject(BuildContext context){
    final ProjectModel model = BlocProvider.of<ProjectCubit>(context).getCurrentProject;
    return model;
  }

  static setCurrentProject(BuildContext context,ProjectModel model){
    BlocProvider.of<ProjectCubit>(context).setCurrentProject = model;
  }

  static Future<File>  storeFile(String filename, List<int> bytes) async {
    final dir = await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static String getProjectTimeAgo(String date){
    DateTime time = DateTime.parse(date);
    String timeAgo = timeago.format(time,locale: 'en_short');
    return timeAgo;
  }

  static bool isRTL(String text) {
    return intl.Bidi.detectRtlDirectionality(text);
  }

  static String currentDate(){
    DateTime currentPhoneDate = DateTime.now();
    String dateFormat = DateFormat('yyyy-MM-dd').format(currentPhoneDate);
    String timeFormat = DateFormat('kk:mm:ss').format(currentPhoneDate);
    String format = '$dateFormat $timeFormat';
    return format;
  }

  static String getInitials(String name) => name.isNotEmpty
      ? name.trim().split(RegExp(' +')).map((s) => s[0]).take(2).join()
      : '';

  static showSnack(String text,String title,BuildContext context,Color color)async{
    await Flushbar(
      messageText: Text('$text',style: TextStyle(color: white,fontFamily: '',fontSize: 17),),
      titleText: Text('$title',style: TextStyle(color: white,fontFamily: '',fontSize: 17,fontWeight: FontWeight.w300),),
      backgroundColor: color,
      icon: Icon(Icons.info,color: white,),
      duration: Duration(seconds: 2),
    ).show(context);
  }

  static Future<void> sendPushMessage(NotificationModel model,String token) async {
    var client = http.Client();
    if (token == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }
    try {
      await client.post(
        Uri.parse(FCM_URL),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=${remoteConfigService.getKey}',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              NotificationModel.BODY: '${model.body}',
              NotificationModel.TITLE: '${model.title}',
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              NotificationModel.BODY: '${model.body}',
              NotificationModel.TITLE: '${model.title}',
              'status': 'done',
              NotificationModel.ICON : '${model.icon}',
              NotificationModel.NOT_ID : '${Uuid().v1()}'
            },
            'to': token,
          },
        ),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e.toString());
    }
  }
}