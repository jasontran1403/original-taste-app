import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:original_taste/helper/services/json_decoder.dart';
import 'package:original_taste/models/identifier_model.dart';

class SellerListModel extends IdentifierModel {
  final String image, title, category, website, address, email, phone, industry, revenue;
  final double rating;
  final int reviews, stock, progress, happyClient, sells;
  final List<String> actions;

  SellerListModel(
    super.id,
    this.image,
    this.title,
    this.category,
    this.website,
    this.address,
    this.email,
    this.phone,
    this.industry,
    this.revenue,
    this.rating,
    this.reviews,
    this.stock,
    this.progress,
    this.happyClient,
    this.sells,
    this.actions,
  );

  static SellerListModel fromJSON(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);

    String image = decoder.getString('image');
    String title = decoder.getString('title');
    String category = decoder.getString('category');
    String website = decoder.getString('website');
    String address = decoder.getString('address');
    String email = decoder.getString('email');
    String phone = decoder.getString('phone');
    String industry = decoder.getString('industry');
    String revenue = decoder.getString('revenue');
    double rating = decoder.getDouble('rating');
    int reviews = decoder.getInt('reviews');
    int stock = decoder.getInt('stock');
    int progress = decoder.getInt('progress');
    int happyClient = decoder.getInt('happy_clients');
    int sells = decoder.getInt('sells');
    List<String> actions = decoder.getObjectList('actions');

    return SellerListModel(
      decoder.getId,
      image,
      title,
      category,
      website,
      address,
      email,
      phone,
      industry,
      revenue,
      rating,
      reviews,
      stock,
      progress,
      happyClient,
      sells,
      actions,
    );
  }

  static List<SellerListModel> listFromJSON(List<dynamic> list) {
    return list.map((e) => SellerListModel.fromJSON(e)).toList();
  }

  static List<SellerListModel>? _dummyList;

  static Future<List<SellerListModel>> get dummyList async {
    if (_dummyList == null) {
      dynamic data = json.decode(await getData());
      _dummyList = listFromJSON(data);
    }

    return _dummyList!;
  }

  static Future<String> getData() async {
    return await rootBundle.loadString('assets/data/seller_list.json');
  }
}
