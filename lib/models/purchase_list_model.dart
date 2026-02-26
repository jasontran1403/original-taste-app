import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:original_taste/models/identifier_model.dart';

import '../helper/services/json_decoder.dart';

class PurchaseListModel extends IdentifierModel {
  final String orderId, orderBy, purchaseStatus, date, total, paymentMethod, paymentStatus;
  final List items;

  PurchaseListModel(
    super.id,
    this.orderId,
    this.orderBy,
    this.purchaseStatus,
    this.date,
    this.total,
    this.paymentMethod,
    this.paymentStatus,
    this.items,
  );

  static PurchaseListModel fromJSON(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);

    String orderId = decoder.getString('id');
    String orderBy = decoder.getString('order_by');
    String purchaseStatus = decoder.getString('purchase_status');
    String date = decoder.getString('date');
    String total = decoder.getString('total');
    String paymentMethod = decoder.getString('payment_method');
    String paymentStatus = decoder.getString('payment_status');

    List<dynamic>? items = decoder.getObjectListOrNull('items');

    return PurchaseListModel(decoder.getId, orderId, orderBy, purchaseStatus, date, total, paymentMethod, paymentStatus, items!);
  }

  static List<PurchaseListModel> listFromJSON(List<dynamic> list) {
    return list.map((e) => PurchaseListModel.fromJSON(e)).toList();
  }

  static List<PurchaseListModel>? _dummyList;

  static Future<List<PurchaseListModel>> get dummyList async {
    if (_dummyList == null) {
      dynamic data = json.decode(await getData());
      _dummyList = listFromJSON(data);
    }

    return _dummyList!;
  }

  static Future<String> getData() async {
    return await rootBundle.loadString('assets/data/purchase_list.json');
  }
}
