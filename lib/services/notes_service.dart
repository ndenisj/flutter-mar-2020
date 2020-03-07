import 'dart:convert';

import 'package:restapi/model/api_response.dart';
import 'package:restapi/model/note.dart';
import 'package:restapi/model/note_manipulation.dart';
import 'package:restapi/model/notes_for_list.dart';
import 'package:http/http.dart' as http;

class NoteService {
  static const API = "http://api.notes.programmingaddict.com/";
  static const headers = {
    "apikey": "08d7c287-044e-f6cc-e98e-a709f9d6b450",
    "Content-Type": "application/json",
  };

  Future<APIResponse<List<NoteForList>>> getNoteList() {
    return http.get(API + "/notes", headers: headers)
    .then((data){
      if(data.statusCode == 200){
        final jsonData = json.decode(data.body);
        final notes = <NoteForList>[];
        for(var item in jsonData){
          notes.add(NoteForList.fromJson(item));
        }
        return APIResponse<List<NoteForList>>(
          data: notes
        );
      }
      return APIResponse<List<NoteForList>>(error: true, errorMessage: 'An error occured');
    }).catchError((_) => APIResponse<List<NoteForList>>(error: true, errorMessage: 'An error occured'));
  }

  Future<APIResponse<Note>> getNote(noteID) {
    return http.get(API + "/notes/"+noteID, headers: headers)
        .then((data){
      if(data.statusCode == 200){
        final jsonData = json.decode(data.body);
        return APIResponse<Note>(
            data: Note.fromJson(jsonData)
        );

      }

      return APIResponse<Note>(error: true, errorMessage: 'An error occured');
    }).catchError((_) => APIResponse<Note>(error: true, errorMessage: 'An error occured'));
  }

  Future<APIResponse<bool>> createNote(NoteManipulation item) {
    return http.post(API + "/notes", headers: headers, body: json.encode(item.toJson()))
        .then((data){
      if(data.statusCode == 201){
        return APIResponse<bool>(data: true);
      }

      return APIResponse<bool>(error: true, errorMessage: 'An error occured');
    }).catchError((_) => APIResponse<bool>(error: true, errorMessage: 'An error occured'));
  }

  Future<APIResponse<bool>> updateNote(noteID, NoteManipulation item) {
    return http.put(API + "/notes/"+noteID, headers: headers, body: json.encode(item.toJson()))
        .then((data){
      if(data.statusCode == 204){
        return APIResponse<bool>(data: true);
      }

      return APIResponse<bool>(error: true, errorMessage: 'An error occured');
    }).catchError((_) => APIResponse<bool>(error: true, errorMessage: 'An error occured'));
  }

  Future<APIResponse<bool>> deleteNote(noteID) {
    return http.delete(API + "/notes/"+noteID, headers: headers)
        .then((data){
      if(data.statusCode == 204){
        return APIResponse<bool>(data: true);
      }

      return APIResponse<bool>(error: true, errorMessage: 'An error occured');
    }).catchError((_) => APIResponse<bool>(error: true, errorMessage: 'An error occured'));
  }

}
