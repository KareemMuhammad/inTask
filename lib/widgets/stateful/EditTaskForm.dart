import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:search_choices/search_choices.dart';
import 'package:taskaty/blocs/task_bloc/task_cubit.dart';
import 'package:taskaty/blocs/task_bloc/task_state.dart';
import 'package:taskaty/blocs/upcoming_task_bloc/upcoming_task_cubit.dart';
import 'package:taskaty/helper_functions/AudioRecordHelper.dart';
import 'package:taskaty/helper_functions/ReminderHelper.dart';
import 'package:taskaty/models/task_model.dart';
import 'package:taskaty/models/user_model.dart';
import 'package:taskaty/utils/constants.dart';
import 'package:taskaty/utils/shared.dart';
import 'package:taskaty/widgets/shared/custom_button.dart';
import 'package:taskaty/widgets/shared/shared_widgets.dart';

class EditTaskForm extends StatefulWidget {
  final MyTask _task;
  EditTaskForm(this._task);
  @override
  _EditTaskFormState createState() => _EditTaskFormState(this._task);
}

class _EditTaskFormState extends State<EditTaskForm> {
  final MyTask _task;
  _EditTaskFormState(this._task);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AudioPlayerHelper _audioPlayerHelper;
  AudioRecordHelper _audioRecordHelper;
  final LocalNotification _localNotification = LocalNotification();
  final ImagePicker imagePicker = ImagePicker();

  List<dynamic> _taskImages;
  List<XFile> imageFileList = [];
  List<String> deletedImages = [];
  AppUser _assignedUser;
  String _date, _time, _taskName, _description;
  bool _isSwitched = false, _recordedAudio, _playing;
  int _day, _month, _year, _hour, _minute, _notificationId;

  //TEXT EDITING CONTROLLER
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _validateTaskName(String value) {
    if (value.length <= 0) {
      return 'Task Name is required';
    }
    return null;
  }

  String _validateTaskDescription(String value) {
    if (value.length <= 0) {
      return 'Task Description is required';
    }
    return null;
  }

  void selectImages() async {
    final List<XFile> selectedImages = await imagePicker.pickMultiImage();
    if (selectedImages != null && selectedImages.isNotEmpty) {
      imageFileList.addAll(selectedImages);
    }
    print("Image List Length:" + imageFileList.length.toString());
    setState((){});
  }

  void manageDeleteUrls()async{
    for(String url in deletedImages){
      await FirebaseStorage.instance.refFromURL(url).delete();
    }
  }

  void _pickDate() async {
    DateTime selectedDate = DateTime.now();
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(selectedDate.year),
        lastDate: DateTime(selectedDate.year + 2),
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
      },);
    if (picked != null && picked != selectedDate) {
      this._day = picked.day;
      this._month = picked.month;
      this._year = picked.year;
      setState(() {
        this._date = '${this._day}/${this._month}/${this._year}';
      });
    }
  }

  void _pickTime() async {
    TimeOfDay selectedTime = TimeOfDay.now();
    final TimeOfDay picked =
        await showTimePicker(context: context, initialTime: selectedTime);
    if (picked != null && picked != selectedTime) {
      String meridian;
      this._minute = picked.minute;
      String minute =
          this._minute < 10 ? '0${this._minute}' : '${this._minute}';
      this._hour = picked.hour;
      String hour = this._hour < 10 ? '0${this._hour}' : '${this._hour}';
      if (this._hour >= 12) {
        meridian = 'PM';
      } else {
        meridian = 'AM';
      }
      setState(() {
        this._time = '$hour:$minute $meridian';
      });
    }
  }

  void _updateTask() async{
    if (_formKey.currentState.validate() &&
        this._day != null &&
        this._month != null &&
        this._year != null &&
        this._hour != null &&
        this._minute != null) {
      BlocProvider.of<MyTaskCubit>(context).emit(TaskLoading());
      _formKey.currentState.save();
      int timestamp = DateTime(this._year, this._month, this._day, this._hour, this._minute)
              .millisecondsSinceEpoch;
      this._task.task = this._taskName;
      this._task.description = this._description;
      this._task.date = this._date;
      this._task.time = this._time;
      this._task.audioDescription = this._recordedAudio;
      this._task.timestamp = timestamp;
      this._task.projectName = Utils.getCurrentProject(context).name;
      this._reminder(timestamp - DateTime.now().millisecondsSinceEpoch);

      List<dynamic> urlList = _taskImages;
      String imageUrl1;
      if (imageFileList != null && imageFileList.isNotEmpty)
        for (XFile filePath in imageFileList) {
          UploadTask task = FirebaseStorage.instance.ref().child(
              "${filePath.name}").putFile(File(filePath.path));
          TaskSnapshot snapshot = await task.then((snapshot) async {
            imageUrl1 = await snapshot.ref.getDownloadURL();
            urlList.add(imageUrl1);
            return snapshot;
          });
        }
      this._task.image = urlList;
      if (deletedImages.isNotEmpty) {
        manageDeleteUrls();
      }
      List<String> idsList;
      if(_assignedUser != null) {
        idsList = [_task.holderId, _assignedUser.id];
      }else{
        idsList = [_task.holderId];
      }
      this._task.assignee =  idsList;
      BlocProvider.of<MyTaskCubit>(context).editTask(this._task);
      BlocProvider.of<UpcomingTaskCubit>(context).editTaskOfList(_task);
    } else {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Task Update Failed')));
    }
  }

  void _deleteRecordedAudio() async {
    this._audioRecordHelper = AudioRecordHelper(this._task.id);
    if (this._recordedAudio != null) {
      bool deleted = await _audioRecordHelper.deleteRecording();
      if (deleted) {
        setState(() {
          this._recordedAudio = false;
        });
      }
    }
  }

  void _playRecording() async {
    _audioPlayerHelper = AudioPlayerHelper(this._task.id);
    if (!this._playing && this._recordedAudio != null) {
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
        await _localNotification.checkIfOptedForNotification(this._task.id);
    if (notificationId > 0) {
      setState(() {
        this._notificationId = notificationId;
        this._isSwitched = true;
      });
    } else {
      setState(() {
        this._isSwitched = false;
      });
    }
  }

  void _structimestamp() {
    DateTime timestamp =
        DateTime.fromMillisecondsSinceEpoch(this._task.timestamp);
    this._day = timestamp.day;
    this._month = timestamp.month;
    this._year = timestamp.year;
    this._hour = timestamp.hour;
    this._minute = timestamp.minute;
  }

  void _reminder(int timestampInMS) {
    if (this._notificationId != null) {
      _localNotification.unsubscribeNotification(this._notificationId);
      if (this._isSwitched) {
        _localNotification.subscribeNotification(
            this._notificationId, this._task.id, this._taskName, timestampInMS);
      }
    } else {
      if (this._isSwitched) {
        int notificationId = DateTime.now().millisecondsSinceEpoch;
        notificationId = (notificationId / 1000).floor();
        _localNotification.subscribeNotification(
            notificationId, this._task.id, this._taskName, timestampInMS);
      }
    }
  }

  @override
  void dispose() {
    if (this._audioRecordHelper != null) {
      _audioRecordHelper.dispose();
    }

    super.dispose();
  }

  @override
  void initState() {
    _taskNameController.text = this._task.task;
    _descriptionController.text = this._task.description;
    this._taskName = this._task.task;
    this._description = this._task.description;
    this._recordedAudio = this._task.audioDescription;
    this._date = this._task.date;
    this._time = this._task.time;
    if(_task.assignee.length > 1) {
      this._assignedUser = Utils
          .getCurrentUsers(context)
          .where((element) => element.id == _task.assignee[1])
          .first;
    }
    this._playing = false;
    if(_task.image.isNotEmpty) {
      this._taskImages = _task.image;
    }else{
      this._taskImages = [];
    }
    this._ifOptedForReminder();
    this._structimestamp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final MyTaskCubit taskCubit = BlocProvider.of<MyTaskCubit>(context);
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                      maxLength: 20,
                      controller: this._taskNameController,
                      decoration: InputDecoration(
                        labelText: 'Task Name',
                        alignLabelWithHint: true,
                        contentPadding: EdgeInsets.all(15.0),
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        ),
                      ),
                      validator: this._validateTaskName,
                      onSaved: (input) => _taskName = input,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
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
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        ),
                      ),
                      onSaved: (input) => _description = input,
                      validator: this._validateTaskDescription,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      child: this._recordedAudio != true
                          ? null
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                Padding(padding: EdgeInsets.all(10.0)),
                                IconButton(
                                  onPressed: _deleteRecordedAudio,
                                  icon: Icon(Icons.delete),
                                  color: Colors.red[300],
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RaisedButton(
                          onPressed: this._pickDate,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          color: Colors.white,
                          child: Row(
                            children: [
                              Text(
                                this._date == null ? 'Select Date' : this._date,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15.0,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(width: 5,),
                              Icon(
                                Icons.date_range,
                                color: lightNavy,
                              ),
                            ],
                          ),
                        ),
                        RaisedButton(
                          onPressed: this._pickTime,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          color: Colors.white,
                          child: Row(
                            children: [
                              Text(
                                this._time == null ? 'Select Time' : this._time,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15.0,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(width: 5,),
                              Icon(
                                Icons.timer,
                                color: lightNavy,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Assign to',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                            fontSize: 15.0,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    _buildSearchBar(),
                    const SizedBox(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text('Add Images',textAlign: TextAlign.center ,
                          style: TextStyle(color: Colors.grey[600], fontSize: 15,fontWeight: FontWeight.w500,letterSpacing: 1),),
                        IconButton(
                          icon: const Icon(Icons.add_circle),
                          iconSize: 25,
                          color: lightNavy,
                          onPressed: (){
                            selectImages();
                          },
                        ),
                        const SizedBox(width: 10,),
                        IconButton(
                          icon: const Icon(Icons.camera_alt),
                          iconSize: 25,
                          color: lightNavy,
                          onPressed: ()async{
                            XFile camFile =  await imagePicker.pickImage(source: ImageSource.camera);
                            setState(() {
                              if(camFile != null)
                                imageFileList.add(camFile);
                            });
                          },
                        ),
                      ],
                    ),
                   _taskImages != null && _taskImages.isNotEmpty ?
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0,8.0,8.0,0),
                      child: GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _taskImages.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                          itemBuilder: (BuildContext context, int index) {
                            return _taskImages[index] == null ? SizedBox() :
                            Stack(
                              children: [
                                Card(
                                  elevation: 4,
                                  color: white,
                                  child: CachedNetworkImage(
                                    imageUrl: _taskImages[index],
                                    fit: BoxFit.cover,
                                    progressIndicatorBuilder: (context, url, downloadProgress) =>
                                        Image.asset('assets/image-not-found.png'),
                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: InkWell(
                                      onTap: ()async{
                                        setState(() {
                                          deletedImages.add(_taskImages[index]);
                                          _taskImages.removeAt(index);
                                        });
                                      },
                                      child: CircleAvatar(
                                          backgroundColor: lightNavy,
                                          radius: 13,
                                          child: Icon(Icons.close,size: 18,color: white,)
                                      ),),
                                  ),
                                ),
                              ],
                            );
                          }),
                    )
                    : const SizedBox(),
                    imageFileList.isNotEmpty?
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: imageFileList.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                                elevation: 4,
                                color: white,
                                child: Image.file(File(imageFileList[index].path), fit: BoxFit.cover,));
                          }),
                    ): const SizedBox(),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.notifications_active,
                          color: lightNavy,
                        ),
                        const Padding(padding: EdgeInsets.all(10.0)),
                        Text(
                          'Remind Me',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                            fontSize: 16.0,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: Switch(
                              value: _isSwitched,
                              onChanged: (value) {
                                setState(() {
                                  _isSwitched = value;
                                });
                              },
                              activeTrackColor: lightNavy,
                              activeColor: white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          BlocConsumer<MyTaskCubit,MyTaskState>(
              builder: (ctx,state){
                if(state is TaskLoading){
                  return spinKit;
                }else{
                  return Container(
                    height: 65,
                    width: 250,
                    padding: const EdgeInsets.all(10.0),
                    child: RaisedGradientButton(
                      radius: 20,
                      gradient: myGradient(),
                      onPressed: this._updateTask,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle,
                            color: Colors.white,
                          ),
                          Padding(padding: const EdgeInsets.all(10.0)),
                          Text(
                            'UPDATE TASK',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18.0,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }, listener: (ctx,state){
            if(state is TaskUpdated){
              taskCubit.getAllProjectTasks(Utils.getCurrentProject(context).id);
              Scaffold.of(context).showSnackBar(SnackBar(content: Text('Task Updated')));
              Navigator.pop(context);
            }
          }),

          const SizedBox(height: 15,),
        ],
      ),
    );
  }

  List<DropdownMenuItem<AppUser>> getCategoriesDropdown(){
    List<DropdownMenuItem<AppUser>> items =  [];
    for(int i = 0; i < Utils.getCurrentProject(context).teamMates.length; i++){
      if(Utils.getCurrentProject(context).teamMates[i].id != FirebaseAuth.instance.currentUser.uid)
        items.insert(0, DropdownMenuItem(child: Text(Utils.getCurrentProject(context).teamMates[i].name),
            value: Utils.getCurrentProject(context).teamMates[i]));
    }
    setState(() {});
    return items;
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        color: white,
        child: SearchChoices.single(
          onClear: (){
            setState(() {
              _assignedUser = null;
            });
          },
          items: getCategoriesDropdown(),
          underline: const SizedBox(),
          value: _assignedUser,
          hint: "Select one",
          searchHint: "search..",
          onChanged: (AppUser value) {
            setState(() {
              _assignedUser = value;
            });
          },
          doneButton: "Done",
          displayItem: (item, selected) {
            return (Row(children: [
              selected
                  ? const Icon(
                Icons.radio_button_checked,
                color: Colors.grey,
              )
                  : const Icon(
                Icons.radio_button_unchecked,
                color: Colors.grey,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: item,
              ),
            ]));
          },
          isExpanded: true,
        ),
      ),
    );
  }

}
