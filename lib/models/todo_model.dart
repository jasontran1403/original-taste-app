import 'dart:convert';
import 'package:flutter/services.dart';
import 'identifier_model.dart';
import 'package:original_taste/helper/services/json_decoder.dart';

class TodoModel extends IdentifierModel {
  final String taskName;
  final String createdDate;
  final String createdTime;
  final String dueDate;
  final String name;
  final String avatar;
  final String status;
  final String priority;
  late final bool checked;

  TodoModel(
    super.id,
    this.status,
    this.taskName,
    this.createdDate,
    this.createdTime,
    this.dueDate,
    this.name,
    this.avatar,
    this.priority,
    this.checked,
  );

  static TodoModel fromJSON(Map<String, dynamic> json) {
    final decoder = JSONDecoder(json);
    return TodoModel(
      decoder.getId,
      decoder.getString('status'),
      decoder.getString('taskName'),
      decoder.getString('createdDate'),
      decoder.getString('createdTime'),
      decoder.getString('dueDate'),
      decoder.getString('name'),
      decoder.getString('avatar'),
      decoder.getString('priority'),
      decoder.getBool('checked'),
    );
  }

  static List<TodoModel> listFromJSON(List<dynamic> list) => list.map((e) => fromJSON(e)).toList();

  static List<TodoModel>? _dummyList;
  static Future<List<TodoModel>> get dummyList async {
    if (_dummyList == null) {
      final data = json.decode(await getData());
      _dummyList = listFromJSON(data);
    }
    return _dummyList!;
  }

  static Future<String> getData() async => await rootBundle.loadString('assets/data/todo_data.json');
}
