import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:original_taste/helper/services/json_decoder.dart';
import 'package:original_taste/models/identifier_model.dart';

class PurchaseOrder extends IdentifierModel {
  final String name, email, orderDate, total, status;

  PurchaseOrder(super.id, this.name, this.email, this.orderDate, this.total, this.status);

  static PurchaseOrder fromJSON(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);

    String name = decoder.getString('name');
    String email = decoder.getString('email');
    String orderDate = decoder.getString('orderDate');
    String total = decoder.getString('total');
    String status = decoder.getString('status');

    return PurchaseOrder(decoder.getId, name, email, orderDate, total, status);
  }

  static List<PurchaseOrder> listFromJSON(List<dynamic> list) {
    return list.map((e) => PurchaseOrder.fromJSON(e)).toList();
  }

  static List<PurchaseOrder>? _dummyList;

  static Future<List<PurchaseOrder>> get dummyList async {
    if (_dummyList == null) {
      dynamic data = json.decode(await getData());
      _dummyList = listFromJSON(data);
    }

    return _dummyList!;
  }

  static Future<String> getData() async {
    return await rootBundle.loadString('assets/data/purchase_order.json');
  }
}
