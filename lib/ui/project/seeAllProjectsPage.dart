import 'package:flutter/material.dart';
import 'package:taskaty/models/project_model.dart';
import 'package:taskaty/utils/shared.dart';
import 'package:taskaty/widgets/stateful/project_widget.dart';

class SeeAllProjectsPage extends StatefulWidget {
  final String title;
  final List<ProjectModel> tasksList;

  const SeeAllProjectsPage({Key key, this.title, this.tasksList}) : super(key: key);

  @override
  State<SeeAllProjectsPage> createState() => _SeeAllProjectsPageState();
}

class _SeeAllProjectsPageState extends State<SeeAllProjectsPage> {

  void _navigateToPreviousScreen(BuildContext context) {
    Navigator.of(context).pop();
  }

  final TextEditingController _searchTextController = TextEditingController();
  List<ProjectModel> searchedForTasks;
  bool _isSearching = false;

  void addSearchedFOrItemsToSearchedList(String searchedProduct) {
    searchedForTasks = widget.tasksList.where((task) =>
        task.name.toLowerCase().contains(searchedProduct)).toList();
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
        padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 5),
        child: ListView.builder(
          itemCount: _searchTextController.text.isEmpty
              ? widget.tasksList.length : searchedForTasks.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              height: SizeConfig.screenHeight * 0.2,
              child: ProjectWidget(model: _searchTextController.text.isEmpty
                  ? widget.tasksList[index] : searchedForTasks[index],),
            );
          },
        ),
      ),
    );
  }

}