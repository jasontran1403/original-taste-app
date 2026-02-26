import 'package:flutter/material.dart';
import 'package:original_taste/controller/my_controller.dart';

class AttributeEditController extends MyController {
  late TextEditingController attributeVariantController ,attributeValueController,attributeIDController;



  String? selectedCategory;

  @override
  void onInit() {
    attributeVariantController = TextEditingController(text: "Brand");
    attributeValueController = TextEditingController(text: "Dyson , H&M, Nike , GoPro , Huawei , Rolex , Zara , Thenorthface");
    attributeIDController = TextEditingController(text: "BR-3922");
    super.onInit();
  }

  final List<String> categories = ['DropDown', 'Radio'];
}
