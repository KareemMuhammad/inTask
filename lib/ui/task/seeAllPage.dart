import 'package:flutter/material.dart';
import 'package:taskaty/models/task_model.dart';
import 'package:taskaty/utils/shared.dart';
import 'package:taskaty/widgets/stateful/TaskList.dart';

class SeeAllPage extends StatefulWidget {
  final String title;
  final List<MyTask> tasksList;

  const SeeAllPage({Key key, this.title, this.tasksList}) : super(key: key);

  @override
  State<SeeAllPage> createState() => _SeeAllPageState();
}

class _SeeAllPageState extends State<SeeAllPage> {

  void _navigateToPreviousScreen(BuildContext context) {
    Navigator.of(context).pop();
  }

  final TextEditingController _searchTextController = TextEditingController();
  List<MyTask> searchedForTasks;
  bool _isSearching = false;

   void addSearchedFOrItemsToSearchedList(String searchedProduct) {
    searchedForTasks = widget.tasksList.where((task) =>
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
        title: _isSearching ? _buildSearchField() : Text("${widget.title}", style: TextStyle(color: white,fontSize: 20,),),
        actions: _buildAppBarActions(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 0),
        child: GridView.builder(
          itemCount: _searchTextController.text.isEmpty
              ? widget.tasksList.length : searchedForTasks.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,childAspectRatio: 0.8),
          itemBuilder: (BuildContext context, int index) {
            return TaskList(task: _searchTextController.text.isEmpty
                ? widget.tasksList[index] : searchedForTasks[index],);
          },
        ),
      ),
    );
  }
}
