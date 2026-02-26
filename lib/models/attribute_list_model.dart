import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:original_taste/helper/services/json_decoder.dart';
import 'package:original_taste/models/identifier_model.dart';

class AttributeListModel extends IdentifierModel {
  final String code, variant, value, option, createdAt;
  late bool published;

  AttributeListModel(super.id, this.code, this.variant, this.value, this.option, this.createdAt, this.published);

  static AttributeListModel fromJSON(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);

    String code = decoder.getString('code');
    String variant = decoder.getString('variant');
    String value = decoder.getString('value');
    String option = decoder.getString('option');
    String createdAt = decoder.getString('created_on');
    bool published = decoder.getBool('published');

    return AttributeListModel(decoder.getId, code, variant, value, option, createdAt, published);
  }

  static List<AttributeListModel> listFromJSON(List<dynamic> list) {
    return list.map((e) => AttributeListModel.fromJSON(e)).toList();
  }

  static List<AttributeListModel>? _dummyList;

  static Future<List<AttributeListModel>> get dummyList async {
    if (_dummyList == null) {
      dynamic data = json.decode(await getData());
      _dummyList = listFromJSON(data);
    }

    return _dummyList!;
  }

  static Future<String> getData() async {
    return await rootBundle.loadString('assets/data/attribute_list.json');
  }
}
