import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:restapi/model/api_response.dart';
import 'package:restapi/model/notes_for_list.dart';
import 'package:restapi/services/notes_service.dart';
import 'package:restapi/views/note_delete.dart';
import 'package:restapi/views/note_modify.dart';

class NoteList extends StatefulWidget {
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  NoteService get service => GetIt.I<NoteService>();
  APIResponse<List<NoteForList>> _apiResponse;
  bool _isLoading = false;

  String formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  void initState() {
    _fetchNotes();
    super.initState();
  }

  _fetchNotes() async {
    setState(() {
      _isLoading = true;
    });

    _apiResponse = await service.getNoteList();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List of Notes'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
                  context, MaterialPageRoute(builder: (_) => NoteModify()))
              .then((_) {
            _fetchNotes();
          });
        },
        child: Icon(Icons.add),
      ),
      body: Builder(
        builder: (_) {
          if (_isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (_apiResponse?.error) {
            return Center(
              child: Text(_apiResponse.errorMessage),
            );
          }

          return ListView.separated(
              itemBuilder: (_, index) {
                return Dismissible(
                  key: ValueKey(_apiResponse.data[index].noteID),
                  direction: DismissDirection.startToEnd,
                  background: Container(
                    color: Colors.red,
                    padding: EdgeInsets.only(left: 16),
                    child: Align(
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  onDismissed: (direction) {},
                  confirmDismiss: (direction) async {
                    final result = await showDialog(
                        context: context, builder: (_) => NoteDelete());

                    if(result){
                      final deleteResult = await service.deleteNote(_apiResponse.data[index].noteID);
                      var message;
                      if(deleteResult !=null && deleteResult.data == true){
                        message = "Note deleted successfully";
                      } else{
                        message = deleteResult?.errorMessage ?? 'An error occured';
                      }

                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text('Done'),
                          content: Text(message),
                          actions: <Widget>[
                            FlatButton(child: Text('Ok'),onPressed: (){
                              Navigator.of(context).pop();
                            },)
                          ],
                        )
                      );

                      return deleteResult?.data ?? false;
                    }
                    return result;
                  },
                  child: ListTile(
                    title: Text(
                      _apiResponse.data[index].noteTitle,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    subtitle: Text(
                        "Last Edited: ${formatDateTime(_apiResponse.data[index].latestEditDateTime ?? _apiResponse.data[index].createDateTime)}"),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => NoteModify(
                                    noteID: _apiResponse.data[index].noteID,
                                  ))).then((_) {
                        _fetchNotes();
                      });
                    },
                  ),
                );
              },
              separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: Colors.green,
                  ),
              itemCount: _apiResponse.data.length);
        },
      ),
    );
  }
}
