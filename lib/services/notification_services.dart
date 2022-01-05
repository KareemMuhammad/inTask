import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:taskaty/repo/user_repository.dart';

class PushNotificationServices{
  final FirebaseAuth auth;
  final FirebaseMessaging messaging;
  final UserRepository usersRepository;

  const PushNotificationServices({this.usersRepository, this.auth, this.messaging,});

  Future initiate() async{
    if(auth.currentUser != null) {
      if(Platform.isIOS){
        NotificationSettings settings = await messaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          print('User granted permission');
        } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
          print('User granted provisional permission');
        } else {
          print('User declined or has not accepted permission');
        }
      }
          final String token = await FirebaseMessaging.instance.getToken();
          usersRepository.updateUserToken(token,auth.currentUser.uid);

      messaging.getInitialMessage().then((message) {
        if(message != null) {

        }
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('On message listen!');
        RemoteNotification notification = message.notification;
        if (notification != null) {

        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('A new onMessageOpenedApp event was published!');

      });
    }
  }

}