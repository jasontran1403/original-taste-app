import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:original_taste/helper/services/json_decoder.dart';
import 'package:original_taste/models/identifier_model.dart';

class WarehouseListModel extends IdentifierModel {
  final String warehouseId, warehouseName, location, manager, contactNumber, warehouseRevenue;
  final int stockAvailable, stockShipping;

  WarehouseListModel(
    super.id,
    this.warehouseId,
    this.warehouseName,
    this.location,
    this.manager,
    this.contactNumber,
    this.warehouseRevenue,
    this.stockAvailable,
    this.stockShipping,
  );

  static WarehouseListModel fromJSON(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);

    String warehouseId = decoder.getString('warehouse_id');
    String warehouseName = decoder.getString('warehouse_name');
    String location = decoder.getString('location');
    String manager = decoder.getString('manager');
    String contactNumber = decoder.getString('contact_number');
    int stockAvailable = decoder.getInt('stock_available');
    int stockShipping = decoder.getInt('stock_shipping');
    String warehouseRevenue = decoder.getString('warehouse_revenue');

    return WarehouseListModel(
      decoder.getId,
      warehouseId,
      warehouseName,
      location,
      manager,
      contactNumber,
      warehouseRevenue,
      stockAvailable,
      stockShipping,
    );
  }

  static List<WarehouseListModel> listFromJSON(List<dynamic> list) {
    return list.map((e) => WarehouseListModel.fromJSON(e)).toList();
  }

  static List<WarehouseListModel>? _dummyList;

  static Future<List<WarehouseListModel>> get dummyList async {
    if (_dummyList == null) {
      dynamic data = json.decode(await getData());
      _dummyList = listFromJSON(data);
    }

    return _dummyList!;
  }

  static Future<String> getData() async {
    return await rootBundle.loadString('assets/data/warehouse_list.json');
  }
}
