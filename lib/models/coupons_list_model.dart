import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:original_taste/models/identifier_model.dart';

import '../helper/services/json_decoder.dart';

class CouponsListModel extends IdentifierModel {
  final String image, name, category, sku, startDate, endDate, status;
  final double price, discount;
  final List<String> actions;
  final bool checked;

  CouponsListModel(
    super.id,
    this.image,
    this.name,
    this.category,
    this.sku,
    this.startDate,
    this.endDate,
    this.status,
    this.price,
    this.discount,
    this.actions,
    this.checked,
  );

  static CouponsListModel fromJSON(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);

    String image = decoder.getString('image');
    String name = decoder.getString('name');
    String category = decoder.getString('category');
    String sku = decoder.getString('sku');
    String startDate = decoder.getString('start_date');
    String endDate = decoder.getString('end_date');
    String status = decoder.getString('status');
    double price = decoder.getDouble('price');
    double discount = decoder.getDouble('discount');
    bool checked = decoder.getBool('checked');
    List<String> actions = decoder.getObjectList('actions');

    return CouponsListModel(decoder.getId, image, name, category, sku, startDate, endDate, status, price, discount, actions, checked);
  }

  static List<CouponsListModel> listFromJSON(List<dynamic> list) {
    return list.map((e) => CouponsListModel.fromJSON(e)).toList();
  }

  static List<CouponsListModel>? _dummyList;

  static Future<List<CouponsListModel>> get dummyList async {
    if (_dummyList == null) {
      dynamic data = json.decode(await getData());
      _dummyList = listFromJSON(data);
    }

    return _dummyList!;
  }

  static Future<String> getData() async {
    return await rootBundle.loadString('assets/data/coupons_list.json');
  }
}
