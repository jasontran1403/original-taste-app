import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:original_taste/helper/services/json_decoder.dart';
import 'package:original_taste/models/identifier_model.dart';

class AllOrderListModel extends IdentifierModel {
  final String orderId, createdAt, customer, priority, total, paymentStatus, deliveryNumber, orderStatus;
  final int items;

  AllOrderListModel(
    super.id,
    this.orderId,
    this.createdAt,
    this.customer,
    this.priority,
    this.total,
    this.paymentStatus,
    this.deliveryNumber,
    this.orderStatus,
    this.items,
  );

  static AllOrderListModel fromJSON(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);

    String orderId = decoder.getString('Order ID');
    String createdAt = decoder.getString('Created at');
    String customer = decoder.getString('Customer');
    String priority = decoder.getString('Priority');
    String total = decoder.getString('Total');
    String paymentStatus = decoder.getString('Payment Status');
    String deliveryNumber = decoder.getString('Delivery Number');
    String orderStatus = decoder.getString('Order Status');
    int items = decoder.getInt('Items');

    return AllOrderListModel(decoder.getId, orderId, createdAt, customer, priority, total, paymentStatus, deliveryNumber, orderStatus, items);
  }

  static List<AllOrderListModel> listFromJSON(List<dynamic> list) {
    return list.map((e) => AllOrderListModel.fromJSON(e)).toList();
  }

  static List<AllOrderListModel>? _dummyList;

  static Future<List<AllOrderListModel>> get dummyList async {
    if (_dummyList == null) {
      dynamic data = json.decode(await getData());
      _dummyList = listFromJSON(data);
    }

    return _dummyList!;
  }

  static Future<String> getData() async {
    return await rootBundle.loadString('assets/data/all_order_list.json');
  }
}
