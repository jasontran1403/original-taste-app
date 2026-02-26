import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:original_taste/helper/services/json_decoder.dart';
import 'package:original_taste/models/identifier_model.dart';

class EmailModel extends IdentifierModel {
  final String from, subject, date, category, content;
  bool unread, starred, important;
  final List<String> label;
  final List<Attachments> attachments;

  EmailModel(
    super.id,
    this.from,
    this.subject,
    this.date,
    this.category,
    this.content,
    this.unread,
    this.starred,
    this.important,
    this.label,
    this.attachments,
  );

  static EmailModel fromJSON(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);

    String from = decoder.getString('from');
    String subject = decoder.getString('subject');
    String date = decoder.getString('date');
    String category = decoder.getString('category');
    String content = decoder.getString('content');
    bool unread = decoder.getBool('unread');
    bool starred = decoder.getBool('starred');
    bool important = decoder.getBool('important');
    List<String>? label = decoder.getObjectListOrNull('labels');

    List<dynamic>? attachmentData = decoder.getObjectListOrNull('attachments');
    List<Attachments> attachments = [];
    if (attachmentData != null) {
      attachments = Attachments.listFromJSON(attachmentData);
    }

    return EmailModel(decoder.getId, from, subject, date, category, content, unread, starred, important, label!, attachments);
  }

  static List<EmailModel> listFromJSON(List<dynamic> list) {
    return list.map((e) => EmailModel.fromJSON(e)).toList();
  }

  static List<EmailModel>? _dummyList;

  static Future<List<EmailModel>> get dummyList async {
    if (_dummyList == null) {
      dynamic data = json.decode(await getData());
      _dummyList = listFromJSON(data);
    }

    return _dummyList!;
  }

  static Future<String> getData() async {
    return await rootBundle.loadString('assets/data/email.json');
  }
}

class Attachments extends IdentifierModel {
  final String type, name;

  Attachments(super.id, this.type, this.name);

  static Attachments fromJSON(Map<String, dynamic> json) {
    JSONDecoder decoder = JSONDecoder(json);

    String type = decoder.getString('type');
    String name = decoder.getString('name');

    return Attachments(decoder.getId, type, name);
  }

  static List<Attachments> listFromJSON(List<dynamic> list) {
    return list.map((e) => Attachments.fromJSON(e)).toList();
  }
}
