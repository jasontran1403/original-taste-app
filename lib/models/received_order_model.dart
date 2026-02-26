import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:original_taste/helper/services/json_decoder.dart';
import 'package:original_taste/models/identifier_model.dart';

class ReceivedOrderModel extends IdentifierModel {
  final String orderId, customer, amount, paymentStatus, receivedStatus;
  final int items;

  ReceivedOrderModel(super.id, this.orderId, this.customer, this.amount, this.paymentStatus, this.receivedStatus, this.items);

  static ReceivedOrderModel fromJSON(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);

    String orderId = decoder.getString('order_id');
    String customer = decoder.getString('customer');
    String amount = decoder.getString('amount');
    String paymentStatus = decoder.getString('payment_status');
    String receivedStatus = decoder.getString('received_status');
    int items = decoder.getInt('items');

    return ReceivedOrderModel(decoder.getId,orderId,customer,amount,paymentStatus,receivedStatus,items);
  }

  static List<ReceivedOrderModel> listFromJSON(List<dynamic> list) {
    return list.map((e) => ReceivedOrderModel.fromJSON(e)).toList();
  }

  static List<ReceivedOrderModel>? _dummyList;

  static Future<List<ReceivedOrderModel>> get dummyList async {
    if (_dummyList == null) {
      dynamic data = json.decode(await getData());
      _dummyList = listFromJSON(data);
    }

    return _dummyList!;
  }

  static Future<String> getData() async {
    return await rootBundle.loadString('assets/data/received_order.json');
  }
}
