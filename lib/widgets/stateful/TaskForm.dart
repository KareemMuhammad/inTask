import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:search_choices/search_choices.dart';
import 'package:taskaty/blocs/task_bloc/task_cubit.dart';
import 'package:taskaty/blocs/task_bloc/task_state.dart';
import 'package:taskaty/blocs/upcoming_task_bloc/upcoming_task_cubit.dart';
import 'package:taskaty/helper_functions/AudioRecordHelper.dart';
import 'package:taskaty/helper_functions/ReminderHelper.dart';
import 'package:taskaty/models/notification_model.dart';
import 'package:taskaty/models/user_model.dart';
import 'package:taskaty/repo/task_repository.dart';
import 'package:taskaty/utils/constants.dart';
import 'package:taskaty/utils/shared.dart';
import 'package:taskaty/widgets/shared/custom_button.dart';
import 'package:taskaty/widgets/shared/shared_widgets.dart';
import 'package:uuid/uuid.dart';
import '../../models/task_model.dart';

class TaskForm extends StatefulWidget {
  final String _id;
  TaskForm(this._id);
  @override
  _TaskFormState createState() => _TaskFormState(this._id);
}

class _TaskFormState extends State<TaskForm> {
  LocalNotification _localNotification = LocalNotification();

  final String _id;

  bool isAssigned = false;
  _TaskFormState(this._id);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  AudioRecordHelper _audioRecordHelper;

  String _date, _time, _taskName = '', _description = '', _recordedAudio;
  bool _isSwitched, _recording;
  int _day, _month, _year, _hour, _minute;
  final ImagePicker _imagePicker = ImagePicker();
  List<XFile> _imageFileList = [];
  AppUser _selectedUser;

  String _fileName;
  File _file;

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

  void _recordButtonClicked() async {
    if (this._recording) {
      String path = await _audioRecordHelper.stopRecording();
      if (path != null) {
        setState(() {
          this._recording = false;
          this._recordedAudio = '$path';
        });
      }
    } else {
      bool started = await _audioRecordHelper.startRecording();
      if (started) {
        setState(() {
          this._recording = true;
        });
      }
    }
  }

  void _deleteRecordedAudio() async {
    if (this._recordedAudio != null && this._recording == false) {
      bool deleted = await _audioRecordHelper.deleteRecording();
      if (deleted) {
        setState(() {
          this._recordedAudio = null;
        });
      }
    }
  }

  void _reminder(int timestampInMS) {
    if (this._isSwitched) {
      int notificationId = DateTime.now().millisecondsSinceEpoch;
      notificationId = (notificationId / 1000).floor();
      _localNotification.subscribeNotification(
          notificationId, this._id, this._taskName, timestampInMS);
    }
  }

  void _createTask() async{
    if (_formKey.currentState.validate() &&
        this._day != null &&
        this._month != null &&
        this._year != null &&
        this._hour != null &&
        this._minute != null) {
      BlocProvider.of<MyTaskCubit>(context).emit(TaskLoading());
      AppUser currentUser = Utils.getCurrentUser(context);
      _formKey.currentState.save();
      int timestamp = DateTime(this._year, this._month, this._day, this._hour, this._minute).millisecondsSinceEpoch;
      List<String> urlList = [];
      String fileLink = '';
      String audio = '';
      if(_recordedAudio != null){
       audio = await TaskRepository.uploadAudio(_recordedAudio);
      }
      if(_imageFileList.isNotEmpty){
       urlList = await TaskRepository.uploadImages(_imageFileList);
      }
      if(_file != null && _fileName != null){
        fileLink = await TaskRepository.uploadFile(_fileName,_file);
      }
      List<String> idsList;
      if(_selectedUser != null) {
       idsList = [currentUser.id, _selectedUser.id];
      }else{
        idsList = [currentUser.id];
      }
      MyTask task = MyTask(this._id, this._taskName, this._description, this._date,
          this._time, audio, timestamp,currentUser.token, Utils.TO_DO,currentUser.id,
          idsList,urlList,Utils.getCurrentProject(context).id,Utils.getCurrentProject(context).name,fileLink);
      this._reminder(timestamp - DateTime.now().millisecondsSinceEpoch);
      BlocProvider.of<MyTaskCubit>(context).addTask(task);
      BlocProvider.of<UpcomingTaskCubit>(context).addToList(task);
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Task Creation Failed')));
    }
  }

  void selectImages() async {
    final List<XFile> selectedImages = await _imagePicker.pickMultiImage();
    if (selectedImages != null && selectedImages.isNotEmpty) {
      _imageFileList.addAll(selectedImages);
    }
    print("Image List Length:" + _imageFileList.length.toString());
    setState((){});
  }

  @override
  void initState() {
    this._isSwitched = false;
    this._recording = false;
    this._audioRecordHelper = AudioRecordHelper(this._id);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _audioRecordHelper.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MyTaskCubit taskCubit = BlocProvider.of<MyTaskCubit>(context);
    return Column(
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
                  mainAxisSize: MainAxisSize.min,
                  verticalDirection: VerticalDirection.down,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Fields marked with (*) are mandatory',textAlign: TextAlign.center ,
                        style: TextStyle(color: Colors.grey[700], fontSize: 15, fontWeight: FontWeight.w500,),),
                    ),
                    const SizedBox(height: 20,),
                    TextFormField(
                      maxLength: 20,
                      textDirection: Utils.isRTL(_taskName.isNotEmpty ? _taskName : _nameController.text) ? TextDirection.rtl : TextDirection.ltr,
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: '* Task Name',
                        alignLabelWithHint: true,
                        contentPadding: const EdgeInsets.all(15.0),
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        ),
                      ),
                      onChanged: (val){
                        setState(() {
                          _taskName = val;
                        });
                      },
                      validator: this._validateTaskName,
                      onSaved: (input) => _taskName = input,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      maxLines: null,
                      controller: _descController,
                      textDirection: Utils.isRTL(_description.isNotEmpty ? _description : _descController.text) ? TextDirection.rtl : TextDirection.ltr,
                      decoration: InputDecoration(
                        labelText: '* Description',
                        alignLabelWithHint: true,
                        contentPadding: EdgeInsets.all(15.0),
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        ),
                      ),
                      onChanged: (val){
                        setState(() {
                          _description = val;
                        });
                      },
                      onSaved: (input) => _description = input,
                      validator: this._validateTaskDescription,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MaterialButton(
                          onPressed: this._pickDate,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          color: Colors.white,
                          child: Row(
                            children: [
                              Text(
                                this._date == null ? '* Select Date' : this._date,
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
                        MaterialButton(
                          onPressed: this._pickTime,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          color: white,
                          child: Row(
                            children: [
                              Text(
                                this._time == null ? '* Select Time' : this._time,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 25,horizontal: 15),
                      child:  Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Additional',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                                fontSize: 15.0,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                    ),
                    Container(
                      child: this._recordedAudio != null
                          ? null
                          : RaisedButton(
                            padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                            onPressed: this._recordButtonClicked,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            color: white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  this._recording == true
                                      ? 'Stop Recording'
                                      : 'Start Recording',
                                  style: TextStyle(
                                    color: this._recording == true
                                        ? Colors.red
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15.0,
                                    letterSpacing: 1.0,
                              ),
                            ),
                            Icon(
                              Icons.mic,
                              color: this._recording == true
                                  ? Colors.red
                                  : lightNavy,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      child: this._recordedAudio == null
                          ? null
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recorded Audio',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15.0,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            IconButton(
                              onPressed: _deleteRecordedAudio,
                              icon: const Icon(Icons.delete),
                              color: Colors.red[300],
                            ),
                        ],
                      ),
                    ),
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
                        IconButton(onPressed: (){
                          setState(() {
                            isAssigned = !isAssigned;
                          });
                        }, icon: Icon(Icons.group_add,color: lightNavy,)),
                      ],
                    ),
                    isAssigned ? _buildSearchBar() : const SizedBox(),

                    Row(mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                       Text('Add Images',textAlign: TextAlign.center ,
                            style: TextStyle(color: Colors.grey[600], fontSize: 15,
                                fontWeight: FontWeight.w500,letterSpacing: 1),),
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
                            XFile camFile =  await _imagePicker.pickImage(source: ImageSource.camera);
                            setState(() {
                              if(camFile != null)
                                _imageFileList.add(camFile);
                            });
                          },
                        ),
                      ],
                    ),
                    _displayChild1(),

                    _fileName != null ? Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(_fileName,style: TextStyle(
                            fontSize: 16, color: black,fontWeight: FontWeight.w500),),
                        IconButton(icon: Icon(Icons.close,color: lightNavy,size: 24,), onPressed: (){
                          setState(() {
                            _fileName = null;
                            _file = null;
                          });
                        })
                      ],
                    ):
                    Row(mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text('Attach a file ',textAlign: TextAlign.center ,
                          style: TextStyle(color: Colors.grey[600], fontSize: 15,
                              fontWeight: FontWeight.w500,letterSpacing: 1),),
                        const SizedBox(width: 10,),
                        IconButton(
                          icon: const Icon(Icons.attach_file),
                          iconSize: 25,
                          color: lightNavy,
                          onPressed: ()async{
                            try {
                              FilePickerResult result = await FilePicker.platform
                                  .pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['pdf', 'doc','docx'],
                              );
                              PlatformFile file = result.files.first;
                              if (file != null) {
                                setState(() {
                                  _fileName = file.name;
                                  _file = File(file.path);
                                });
                              }
                            }catch(ex){
                              print(ex.toString());
                            }
                          },
                        ),
                      ],
                    ),
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
                   onPressed: this._createTask,
                   gradient: myGradient(),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: const [
                       const Icon(
                         Icons.add_circle,
                         color: white,
                       ),
                       const Padding(padding: EdgeInsets.all(10.0)),
                       const Text(
                         'CREATE TASK',
                         style: const TextStyle(
                           color: white,
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
              if(_selectedUser != null) {
                NotificationModel model = NotificationModel(id: Uuid().v1(),
                    icon: Utils.APP_ICON,
                    title: '$_taskName',
                    body: '${Utils.getCurrentUser(context).name} assigned you a new task');
                Utils.sendPushMessage(model, _selectedUser.token);
              }
              taskCubit.getAllProjectTasks(Utils.getCurrentProject(context).id);
              Scaffold.of(context).showSnackBar(SnackBar(content: Text('Task Created')));
              Navigator.pop(context);
            }
          }),
          const SizedBox(height: 15,),
        ],
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
          items: getCategoriesDropdown(),
          underline: const SizedBox(),
          value: _selectedUser,
          hint: "Select one",
          searchHint: "search..",
          onChanged: (AppUser value) {
            setState(() {
              _selectedUser = value;
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

  Widget _displayChild1() {
    return _imageFileList.isNotEmpty ?
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _imageFileList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          itemBuilder: (BuildContext context, int index) {
            return _imageFileList[index] == null ? SizedBox() :
            Stack(
              children: [
                Card(
                  color: white,
                    elevation: 4,
                    child: Image.file(File(_imageFileList[index].path), fit: BoxFit.cover,)),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: ()async{
                        setState(() {
                          _imageFileList.removeAt(index);
                        });
                      },
                      child: CircleAvatar(
                          backgroundColor: lightNavy,
                          radius: 13,
                          child: const Icon(Icons.close,size: 18,color: white,)
                      ),),
                  ),
                ),
              ],
            );
          }),
    ) :
    const SizedBox();
  }

}
