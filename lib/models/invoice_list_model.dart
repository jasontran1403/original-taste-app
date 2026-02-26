import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:original_taste/helper/services/json_decoder.dart';
import 'package:original_taste/models/identifier_model.dart';

class InvoiceListModel extends IdentifierModel {
  final String invoiceId,billingName,orderDate,total,paymentMethod,status;

  InvoiceListModel(super.id,this.invoiceId, this.billingName, this.orderDate, this.total, this.paymentMethod, this.status);
  static InvoiceListModel fromJSON(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);

    String invoiceId = decoder.getString('invoice_id');
    String billingName = decoder.getString('billing_name');
    String orderDate = decoder.getString('order_date');
    String total = decoder.getString('total');
    String paymentMethod = decoder.getString('payment_method');
    String status = decoder.getString('status');

    return InvoiceListModel(decoder.getId,invoiceId,billingName,orderDate,total,paymentMethod,status);
  }

  static List<InvoiceListModel> listFromJSON(List<dynamic> list) {
    return list.map((e) => InvoiceListModel.fromJSON(e)).toList();
  }

  static List<InvoiceListModel>? _dummyList;

  static Future<List<InvoiceListModel>> get dummyList async {
    if (_dummyList == null) {
      dynamic data = json.decode(await getData());
      _dummyList = listFromJSON(data);
    }

    return _dummyList!;
  }

  static Future<String> getData() async {
    return await rootBundle.loadString('assets/data/invoice_list.json');
  }

}