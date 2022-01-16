import 'package:flutter/material.dart';
import 'package:taskaty/models/task_model.dart';
import 'package:taskaty/widgets/stateful/EditTaskForm.dart';

class EditTaskPage extends StatelessWidget {
  final MyTask _task;
  EditTaskPage(this._task);

  void _navigateToPreviousScreen(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            _navigateToPreviousScreen(context);
          },
        ),
        title: Text(
          'Update Task',
          style: TextStyle(
            fontFamily: 'OrelegaOne',
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: EditTaskForm(this._task),
      ),
    );
  }
}
