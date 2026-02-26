import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:original_taste/helper/services/json_decoder.dart';
import 'package:original_taste/models/identifier_model.dart';

class CategoryListModel extends IdentifierModel {
  final String category,image,price,createdBy,categoryId;
  final int stock;

  CategoryListModel(super.id, this.category, this.image, this.price, this.createdBy, this.categoryId, this.stock);

  static CategoryListModel fromJSON(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);

    String category = decoder.getString('category');
    String image = decoder.getString('image');
    String price = decoder.getString('price');
    String createdBy = decoder.getString('createdBy');
    String categoryId = decoder.getString('id');
    int stock = decoder.getInt('stock');

    return CategoryListModel(decoder.getId, category, image, price, createdBy, categoryId, stock);
  }

  static List<CategoryListModel> listFromJSON(List<dynamic> list) {
    return list.map((e) => CategoryListModel.fromJSON(e)).toList();
  }

  static List<CategoryListModel>? _dummyList;

  static Future<List<CategoryListModel>> get dummyList async {
    if (_dummyList == null) {
      dynamic data = json.decode(await getData());
      _dummyList = listFromJSON(data);
    }

    return _dummyList!;
  }

  static Future<String> getData() async {
    return await rootBundle.loadString('assets/data/category_list.json');
  }

}