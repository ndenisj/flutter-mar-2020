import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:restapi/model/note.dart';
import 'package:restapi/model/note_manipulation.dart';
import 'package:restapi/services/notes_service.dart';

class NoteModify extends StatefulWidget {

  final String noteID;
  NoteModify({this.noteID});

  @override
  _NoteModifyState createState() => _NoteModifyState();
}

class _NoteModifyState extends State<NoteModify> {
  bool get isEditing => widget.noteID != null;

  NoteService get noteService => GetIt.I<NoteService>();
  String errorMessage;
  Note note;

  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if(isEditing) {
      setState(() {
        _isLoading = true;
      });
      noteService.getNote(widget.noteID)
          .then((response) {
        setState(() {
          _isLoading = false;
        });
        if (response.error) {
          errorMessage = response.errorMessage ?? 'An error occured';
        }
        note = response.data;
        _titleController.text = note.noteTitle;
        _contentController.text = note.noteContent;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Update Note' : 'Create Note'),),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _isLoading ? Center(child: CircularProgressIndicator()) : Column(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Note Title'
              ),
            ),
            SizedBox(height: 15,),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                  hintText: 'Note Content'
              ),
            ),
            SizedBox(height: 10,),
            RaisedButton(
              onPressed: () async{
                if(isEditing){
                  // update note in API
                  setState(() {
                    _isLoading = true;
                  });
                  // create note in API
                  final note = NoteManipulation(
                    noteTitle: _titleController.text,
                    noteContent: _titleController.text,
                  );
                  final result = await noteService.updateNote(widget.noteID, note);

                  final title = 'Done';
                  final text = result.error ? (result.errorMessage ?? 'An error occured') : 'Note successfully updated';

                  showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(title),
                        content: Text(text),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('Ok'),
                            onPressed: (){
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      )
                  )
                      .then((data){
                    if(result.data){
                      Navigator.of(context).pop();
                    }
                  });
                } else {
                  setState(() {
                    _isLoading = true;
                  });
                  // create note in API
                  final note = NoteManipulation(
                    noteTitle: _titleController.text,
                    noteContent: _titleController.text,
                  );
                  final result = await noteService.createNote(note);

                  final title = 'Done';
                  final text = result.error ? (result.errorMessage ?? 'An error occured') : 'Note successfully created';

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(title),
                      content: Text(text),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('Ok'),
                          onPressed: (){
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    )
                  )
                  .then((data){
                    if(result.data){
                      Navigator.of(context).pop();
                    }
                  });
                }
              },
              color: Theme.of(context).primaryColor,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
