import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:original_taste/helper/services/json_decoder.dart';
import 'package:original_taste/models/identifier_model.dart';

class CustomerListModel extends IdentifierModel {
  final String customerId, name, avatar, status, amountPaid, amountDue, date, paymentMethod;

  CustomerListModel(super.id, this.customerId, this.name, this.avatar, this.status, this.amountPaid, this.amountDue, this.date, this.paymentMethod);

  static CustomerListModel fromJSON(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);

    String customerId = decoder.getString('id');
    String name = decoder.getString('name');
    String avatar = decoder.getString('avatar');
    String status = decoder.getString('status');
    String amountPaid = decoder.getString('amount_paid');
    String amountDue = decoder.getString('amount_due');
    String date = decoder.getString('date');
    String paymentMethod = decoder.getString('payment_method');

    return CustomerListModel(decoder.getId, customerId, name, avatar, status, amountPaid, amountDue, date, paymentMethod);
  }

  static List<CustomerListModel> listFromJSON(List<dynamic> list) {
    return list.map((e) => CustomerListModel.fromJSON(e)).toList();
  }

  static List<CustomerListModel>? _dummyList;

  static Future<List<CustomerListModel>> get dummyList async {
    if (_dummyList == null) {
      dynamic data = json.decode(await getData());
      _dummyList = listFromJSON(data);
    }

    return _dummyList!;
  }

  static Future<String> getData() async {
    return await rootBundle.loadString('assets/data/customer_list.json');
  }
}
