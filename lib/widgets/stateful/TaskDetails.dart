import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:taskaty/helper_functions/AudioRecordHelper.dart';
import 'package:taskaty/helper_functions/ReminderHelper.dart';
import 'package:taskaty/models/task_model.dart';
import 'package:taskaty/models/user_model.dart';
import 'package:taskaty/repo/task_repository.dart';
import 'package:taskaty/utils/constants.dart';
import 'package:taskaty/utils/shared.dart';

class TaskDetails extends StatefulWidget {
  final String _id;
   TaskDetails(this._id);
  @override
  _TaskDetailsState createState() => _TaskDetailsState(this._id);
}

class _TaskDetailsState extends State<TaskDetails> {
  final String _id;
  _TaskDetailsState(this._id);

  final TaskRepository _databaseHelper = TaskRepository();
  final LocalNotification _localNotification = LocalNotification();
  AudioPlayerHelper _audioPlayerHelper;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  MyTask _task;
  AppUser _assignedUser;
  bool _isLoading = false;
  bool _playing = false, _recordedAudio, _isSwitched = false;

  void _getTaskDetails(String id) async {
    MyTask currentTask = await _databaseHelper.getTaskById(id);
    if (currentTask != null) {
      _taskNameController.text = currentTask.task;
      _descriptionController.text = currentTask.description;
      setState(() {
        this._task = currentTask;
        this._recordedAudio = currentTask.audioDescription;
        if(this._task.assignee.length > 1) {
          _assignedUser = Utils
              .getCurrentUsers(context)
              .where((element) => element.id == _task.assignee[1])
              .first;
        }
      });
    }
    setState(() {
      this._isLoading = false;
    });
  }

  void _playRecording() async {
    this._audioPlayerHelper = AudioPlayerHelper(this._id);
    if (!this._playing && _recordedAudio != null) {
      var playing = await _audioPlayerHelper.startPlaying();
      if (playing) {
        setState(() {
          this._playing = true;
        });
      }
    } else {
      var stopped = await _audioPlayerHelper.stopPlaying();
      if (stopped) {
        setState(() {
          this._playing = false;
        });
      }
    }
  }

  void _ifOptedForReminder() async {
    int notificationId =
        await _localNotification.checkIfOptedForNotification(this._id);
    if (notificationId > 0) {
      setState(() {
        this._isSwitched = true;
      });
    } else {
      setState(() {
        this._isSwitched = false;
      });
    }
  }

  @override
  void initState() {
    this._isLoading = true;
    this._getTaskDetails(this._id);
    this._ifOptedForReminder();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return this._isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : dataContainer();
  }

  Container dataContainer() {
    return Container(
      child: this._task == null
          ? Center(
              child: Text(
                'No Task Available',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
              ),
            )
          : SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    child: Form(
                      key: this._formKey,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextFormField(
                              enabled: false,
                              controller: this._taskNameController,
                              decoration: InputDecoration(
                                labelText: 'Task Name',
                                alignLabelWithHint: true,
                                contentPadding: EdgeInsets.all(15.0),
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              enabled: false,
                              maxLines: null,
                              controller: this._descriptionController,
                              decoration: InputDecoration(
                                labelText: 'Description',
                                alignLabelWithHint: true,
                                contentPadding: EdgeInsets.all(15.0),
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4.0)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              child: this._recordedAudio != true
                                  ? null
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Recorded Audio',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15.0,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: _playRecording,
                                          icon: this._playing
                                              ? Icon(Icons.pause_circle_filled)
                                              : Icon(Icons.play_circle_filled),
                                          color: lightNavy,
                                        ),
                                      ],
                                    ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RaisedButton(
                                  padding:
                                      const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                  onPressed: () {},
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  color: white,
                                  child: Row(
                                    children: [
                                      Text(
                                        this._task.date,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15.0,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      const Padding(padding: EdgeInsets.all(10.0)),
                                      Icon(
                                        Icons.date_range,
                                        color: lightNavy,
                                      ),
                                    ],
                                  ),
                                ),
                                RaisedButton(
                                  padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                  onPressed: () {},
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  color: white,
                                  child: Row(
                                    children: [
                                      Text(
                                        this._task.time,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15.0,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      const Padding(padding: EdgeInsets.all(10.0)),
                                      Icon(
                                        Icons.timer,
                                        color: lightNavy,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                           _assignedUser != null ?
                           _assignWidget() : const SizedBox(),

                            const SizedBox(height: 20),

                            _task.image != null && _task.image.isNotEmpty ?
                            _imagesWidget() : const SizedBox(),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ),
    );
  }

  Widget _assignWidget(){
    return Column(
     children: [
       const SizedBox(height: 20),
       Row(
         mainAxisAlignment: MainAxisAlignment.start,
         crossAxisAlignment: CrossAxisAlignment.center,
         children: [
           Text(
             'Assigned to',
             style: TextStyle(
               color: Colors.grey[600],
               fontWeight: FontWeight.w500,
               fontSize: 15.0,
               letterSpacing: 1.0,
             ),
           ),
           const SizedBox(width: 5,),
           Text(
             '${_assignedUser.name}',
             style: TextStyle(
               color: Colors.grey[900],
               fontWeight: FontWeight.w500,
               fontSize: 16.0,
               letterSpacing: 1.0,
             ),
           ),
         ],
       ),
      ]
    );
  }

  Widget _imagesWidget(){
    return Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Images',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              fontSize: 15.0,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            children: [
              Container(
                height: SizeConfig.screenHeight * 0.7,
                width: SizeConfig.screenWidth,
                child: Swiper(
                  loop: false,
                  itemCount: _task.image.length,
                  pagination: new SwiperPagination(
                    alignment: Alignment.bottomCenter,
                    builder: new DotSwiperPaginationBuilder(
                        color: Colors.grey[500], activeColor: lightNavy),
                  ),
                  itemBuilder: (BuildContext context,int imageIndex){
                    return CachedNetworkImage(
                      imageBuilder: (context, imageProvider) =>
                          Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.fitWidth,
                                image: imageProvider,
                              ),
                            ),
                          ),
                      width: double.maxFinite,
                      height: double.maxFinite,
                      imageUrl: _task.image[imageIndex],
                      progressIndicatorBuilder: (context, url, downloadProgress) =>
                          Image.asset('assets/image-not-found.png'),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    );
                  },
                ),
              ),
            ],
          ),
        ]
    );
  }
}
