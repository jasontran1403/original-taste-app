import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:original_taste/helper/services/json_decoder.dart';
import 'package:original_taste/models/identifier_model.dart';

class ProductListModel extends IdentifierModel {
  final String name, image, category;
  final int stock, sold, reviews;
  final double price, rating;
  final List sizes;

  ProductListModel(super.id, this.name, this.image, this.category, this.stock, this.sold, this.reviews, this.price, this.rating, this.sizes);

  static ProductListModel fromJSON(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);

    String name = decoder.getString('name');
    String image = decoder.getString('image');
    String category = decoder.getString('category');
    int stock = decoder.getInt('stock');
    int sold = decoder.getInt('sold');
    int reviews = decoder.getInt('reviews');
    double price = decoder.getDouble('price');
    double rating = decoder.getDouble('rating');

    List<dynamic>? sizes = decoder.getObjectListOrNull('sizes');

    return ProductListModel(decoder.getId, name, image, category, stock, sold, reviews, price, rating, sizes!);
  }

  static List<ProductListModel> listFromJSON(List<dynamic> list) {
    return list.map((e) => ProductListModel.fromJSON(e)).toList();
  }

  static List<ProductListModel>? _dummyList;

  static Future<List<ProductListModel>> get dummyList async {
    if (_dummyList == null) {
      dynamic data = json.decode(await getData());
      _dummyList = listFromJSON(data);
    }

    return _dummyList!;
  }

  static Future<String> getData() async {
    return await rootBundle.loadString('assets/data/product_list.json');
  }
}
