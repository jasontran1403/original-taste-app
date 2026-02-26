import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:original_taste/helper/services/json_decoder.dart';
import 'package:original_taste/models/identifier_model.dart';

class RecentOrderModel extends IdentifierModel {
  final String orderId, date, productImage, customerName, email, phone, address, paymentType, status;

  RecentOrderModel(
    super.id,
    this.orderId,
    this.date,
    this.productImage,
    this.customerName,
    this.email,
    this.phone,
    this.address,
    this.paymentType,
    this.status,
  );

  static RecentOrderModel fromJSON(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);

    String orderId = decoder.getString('order_id');
    String date = decoder.getString('date');
    String productImage = decoder.getString('product_image');
    String customerName = decoder.getString('customer_name');
    String email = decoder.getString('email');
    String phone = decoder.getString('phone');
    String address = decoder.getString('address');
    String paymentType = decoder.getString('payment_type');
    String status = decoder.getString('status');

    return RecentOrderModel(decoder.getId, orderId, date, productImage, customerName, email, phone, address, paymentType, status);
  }

  static List<RecentOrderModel> listFromJSON(List<dynamic> list) {
    return list.map((e) => RecentOrderModel.fromJSON(e)).toList();
  }

  static List<RecentOrderModel>? _dummyList;

  static Future<List<RecentOrderModel>> get dummyList async {
    if (_dummyList == null) {
      dynamic data = json.decode(await getData());
      _dummyList = listFromJSON(data);
    }

    return _dummyList!;
  }

  static Future<String> getData() async {
    return await rootBundle.loadString('assets/data/recent_order.json');
  }
}
