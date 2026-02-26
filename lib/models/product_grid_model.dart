import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:original_taste/helper/services/json_decoder.dart';
import 'package:original_taste/models/identifier_model.dart';

class ProductGridModel extends IdentifierModel {
  final String image, name;
  final double rating;
  final int review, originalPrice, discountedPrice, discountPercentage;
  bool isFavorite;

  ProductGridModel(
    super.id,
    this.image,
    this.name,
    this.rating,
    this.review,
    this.originalPrice,
    this.discountedPrice,
    this.discountPercentage,
    this.isFavorite,
  );

  static ProductGridModel fromJSON(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);

    String image = decoder.getString('image');
    String name = decoder.getString('name');
    double rating = decoder.getDouble('rating');
    int review = decoder.getInt('reviews');
    int originalPrice = decoder.getInt('original_price');
    int discountedPrice = decoder.getInt('discounted_price');
    int discountPercentage = decoder.getInt('discount_percentage');
    bool isFavourite = decoder.getBool('is_favorite');

    return ProductGridModel(decoder.getId, image, name, rating, review, originalPrice, discountedPrice, discountPercentage, isFavourite);
  }

  static List<ProductGridModel> listFromJSON(List<dynamic> list) {
    return list.map((e) => ProductGridModel.fromJSON(e)).toList();
  }

  static List<ProductGridModel>? _dummyList;

  static Future<List<ProductGridModel>> get dummyList async {
    if (_dummyList == null) {
      dynamic data = json.decode(await getData());
      _dummyList = listFromJSON(data);
    }

    return _dummyList!;
  }

  static Future<String> getData() async {
    return await rootBundle.loadString('assets/data/product_grid.json');
  }
}
