import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskaty/blocs/upcoming_task_bloc/upcoming_task_cubit.dart';
import 'package:taskaty/blocs/upcoming_task_bloc/upcoming_task_state.dart';
import 'package:taskaty/models/task_model.dart';
import 'package:taskaty/utils/shared.dart';
import 'package:taskaty/widgets/shared/shared_widgets.dart';
import 'package:taskaty/widgets/stateful/CurrentTaskList.dart';

class SeeAllMyTaskPage extends StatefulWidget {

  @override
  State<SeeAllMyTaskPage> createState() => _SeeAllMyTaskPageState();
}

class _SeeAllMyTaskPageState extends State<SeeAllMyTaskPage> {

  void _navigateToPreviousScreen(BuildContext context) {
    Navigator.of(context).pop();
  }

  final TextEditingController _searchTextController = TextEditingController();
  List<MyTask> searchedForTasks;
  List<MyTask> currentTasks;
  bool _isSearching = false;

  void addSearchedFOrItemsToSearchedList(String searchedProduct) {
    searchedForTasks = currentTasks.where((task) =>
        task.task.toLowerCase().contains(searchedProduct)).toList();
    setState(() {});
  }

  void _clearSearch() {
    setState(() {
      _searchTextController.clear();
    });
  }

  List<Widget> _buildAppBarActions() {
    if (_isSearching) {
      return [
        IconButton(
          onPressed: () {
            _clearSearch();
            Navigator.pop(context);
          },
          icon: const Icon(Icons.clear, color: white),
        ),
      ];
    } else {
      return [
        IconButton(
          onPressed: _startSearch,
          icon: const Icon(
            Icons.search,
            color: white,
          ),
        ),
      ];
    }
  }

  void _startSearch() {
    ModalRoute.of(context).addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearching() {
    _clearSearch();

    setState(() {
      _isSearching = false;
    });
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchTextController,
      cursorColor: Colors.grey[700],
      decoration: InputDecoration(
        hintText: 'Search..',
        border: InputBorder.none,
        hintStyle: const TextStyle(color: white, fontSize: 16),
      ),
      style: const TextStyle(color: white, fontSize: 18),
      onChanged: (searchedProduct) {
        addSearchedFOrItemsToSearchedList(searchedProduct);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<UpcomingTaskCubit>(context).getAllCurrentTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _isSearching
            ? BackButton(color: white,)
            : GestureDetector(
              onTap: (){
                _navigateToPreviousScreen(context);
              },
             child: const Icon(Icons.arrow_back, color: white,)),
        title: _isSearching ? _buildSearchField() : Text("My Tasks", style: TextStyle(color: white,fontSize: 20,fontFamily: 'OrelegaOne',),),
        actions: _buildAppBarActions(),
      ),
      body: BlocBuilder<UpcomingTaskCubit,MyUpcomingTaskState>(
        builder: (context,state) {
          if(state is UpTaskFailure){
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Data load error, please try again later!',
                style: TextStyle(
                  fontSize: 19,
                  color: darkNavy,
                ),
              ),
            );

          }else if(state is UpcomingTasksLoaded){
            currentTasks = state.upTasks;
            return currentTasks.isEmpty ?
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20,),
                  Image.asset('assets/list.png'),
                  Padding(padding: const EdgeInsets.all(4.0)),
                  Text(
                    "You don't have any tasks!",
                    style: TextStyle(
                        color: Colors.black38,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
            :Padding(
              padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 0),
              child: GridView.builder(
                itemCount: _searchTextController.text.isEmpty
                    ? currentTasks.length : searchedForTasks.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,childAspectRatio: 0.7),
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      Expanded(
                        child: CurrentTaskList(task: _searchTextController.text.isEmpty
                            ? currentTasks[index] : searchedForTasks[index],),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text('(${_searchTextController.text.isEmpty
                            ? currentTasks[index].projectName : searchedForTasks[index].projectName})',
                          style: TextStyle(letterSpacing: 1,fontWeight: FontWeight.w500,color: darkNavy,fontSize: 16),),
                      ),
                    ],
                  );
                },
              ),
            );
          }else{
            return GridView.builder(
              itemCount: 6,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,childAspectRatio: 0.9),
              itemBuilder: (BuildContext context, int index) {
                return loadTaskShimmer();
              },
            );
          }
        }
      ),
    );
  }
}