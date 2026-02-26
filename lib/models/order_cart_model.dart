import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:original_taste/helper/services/json_decoder.dart';
import 'package:original_taste/models/identifier_model.dart';

class OrderCartModel extends IdentifierModel {
  final String name, image, color, size;
  int quantity;
  final double itemPrice, tax;

  OrderCartModel(super.id, this.name, this.image, this.color, this.size, this.quantity, this.itemPrice, this.tax);

  double get total => (itemPrice + tax) * quantity;

  static OrderCartModel fromJSON(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);

    return OrderCartModel(
      decoder.getId,
      decoder.getString('name'),
      decoder.getString('image'),
      decoder.getString('color'),
      decoder.getString('size'),
      decoder.getInt('quantity'),
      decoder.getDouble('item_price'),
      decoder.getDouble('tax'),
    );
  }

  static List<OrderCartModel> listFromJSON(List<dynamic> list) {
    return list.map((e) => OrderCartModel.fromJSON(e)).toList();
  }

  static List<OrderCartModel>? _dummyList;

  static Future<List<OrderCartModel>> get dummyList async {
    if (_dummyList == null) {
      dynamic data = json.decode(await getData());
      _dummyList = listFromJSON(data);
    }
    return _dummyList!;
  }

  static Future<String> getData() async {
    return await rootBundle.loadString('assets/data/order_cart.json');
  }
}
