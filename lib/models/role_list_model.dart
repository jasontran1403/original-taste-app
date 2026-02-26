import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:original_taste/helper/services/json_decoder.dart';
import 'package:original_taste/models/identifier_model.dart';

class RoleListModel extends IdentifierModel {
  final String role, workSpace;
  final List tag, users;
  late bool active;

  RoleListModel(super.id, this.role, this.workSpace, this.tag, this.users, this.active);

  static RoleListModel fromJSON(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);

    String role = decoder.getString('role');
    String workSpace = decoder.getString('workspace');
    List<String> tag = decoder.getObjectList('tags');
    List<String> users = decoder.getObjectList('users');
    bool active = decoder.getBool('active');

    return RoleListModel(decoder.getId, role, workSpace, tag, users, active);
  }

  static List<RoleListModel> listFromJSON(List<dynamic> list) {
    return list.map((e) => RoleListModel.fromJSON(e)).toList();
  }

  static List<RoleListModel>? _dummyList;

  static Future<List<RoleListModel>> get dummyList async {
    if (_dummyList == null) {
      dynamic data = json.decode(await getData());
      _dummyList = listFromJSON(data);
    }

    return _dummyList!;
  }

  static Future<String> getData() async {
    return await rootBundle.loadString('assets/data/role_list.json');
  }
}
