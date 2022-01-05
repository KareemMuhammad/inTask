import 'package:device_preview/device_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:taskaty/blocs/project_bloc/project_cubit.dart';
import 'package:taskaty/blocs/search_bloc/search_cubit.dart';
import 'package:taskaty/blocs/search_bloc/search_state.dart';
import 'package:taskaty/blocs/task_bloc/task_cubit.dart';
import 'package:taskaty/blocs/upcoming_task_bloc/upcoming_task_cubit.dart';
import 'package:taskaty/blocs/user_bloc/user_cubit.dart';
import 'package:taskaty/helper_functions/ReminderHelper.dart';
import 'package:taskaty/repo/project_repository.dart';
import 'package:taskaty/repo/task_repository.dart';
import 'package:taskaty/repo/user_repository.dart';
import 'package:taskaty/ui/wrapper_screen.dart';
import 'package:taskaty/utils/shared.dart';
import 'blocs/auth_bloc/auth_cubit.dart';
import 'services/remote_config.dart';

final _auth = FirebaseAuth.instance;
RemoteConfigService remoteConfigService;
PackageInfo packageInfo;

Future firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if(_auth.currentUser != null) {
    User user = _auth.currentUser;
    LocalNotification().showNormalNotification(message.notification.title);
    print("Handling a background message: ${message.messageId}");
  }
}

Future initializeRemoteConfig() async {
  remoteConfigService = await RemoteConfigService.getInstance();
  await remoteConfigService.initialize();
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  packageInfo = await PackageInfo.fromPlatform();
  await Firebase.initializeApp();
  LocalNotification().initialize();
  await initializeRemoteConfig();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(
      DevicePreview(
          enabled: !kReleaseMode,
          builder: (context) => MyApp())
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(userRepository: UserRepository())..authUser(),
        ),
        BlocProvider(
          create: (context) => UserCubit(userRepository: UserRepository()),
        ),
        BlocProvider(
          create: (context) => UpcomingTaskCubit(taskRepository: TaskRepository()),
        ),
        BlocProvider(
          create: (context) => MyTaskCubit(taskRepository: TaskRepository()),
        ),
        BlocProvider(
          create: (context) => ProjectCubit(projectRepository: ProjectRepository()),
        ),
        BlocProvider(
          create: (context) => SearchCubit(SearchInitial()),
        ),
      ],
      child: MaterialApp(
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: AppBarTheme(
              color: darkNavy,
              iconTheme: IconThemeData(color: white)
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: WrapperScreen(),
      ),
    );
  }
}
