import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:original_taste/helper/services/json_decoder.dart';
import 'package:original_taste/models/identifier_model.dart';

class PurchaseReturnModel extends IdentifierModel {
  final String returnId,orderBy,returnDate,total,returnStatus;
  final List<String> items;

  PurchaseReturnModel(super.id, this.returnId, this.orderBy, this.items, this.returnDate, this.total,this.returnStatus);

  static PurchaseReturnModel fromJSON(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);

    String returnID = decoder.getString('id');
    String orderBy = decoder.getString('orderBy');
    String returnDate = decoder.getString('returnDate');
    String total = decoder.getString('total');
    String returnStatus = decoder.getString('returnStatus');
    List<String> items = List<String>.from(decoder.getObjectListOrNull('items') ?? []);



    return PurchaseReturnModel(decoder.getId,returnID,orderBy,items,returnDate,total,returnStatus);
  }

  static List<PurchaseReturnModel> listFromJSON(List<dynamic> list) {
    return list.map((e) => PurchaseReturnModel.fromJSON(e)).toList();
  }

  static List<PurchaseReturnModel>? _dummyList;

  static Future<List<PurchaseReturnModel>> get dummyList async {
    if (_dummyList == null) {
      dynamic data = json.decode(await getData());
      _dummyList = listFromJSON(data);
    }

    return _dummyList!;
  }

  static Future<String> getData() async {
    return await rootBundle.loadString('assets/data/purchase_return.json');
  }
}
