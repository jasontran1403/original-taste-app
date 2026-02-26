import 'package:flutter/material.dart';
import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/models/product_grid_model.dart';

class ProductGridController extends MyController {
  List<ProductGridModel> productGrid = [];
  String selectedOption = 'This Month';

  bool showCategories = true;
  Map<String, bool> categories = {
    "All Categories": true,
    "Fashion Men , Women & Kid's": false,
    "Eye Ware & Sunglass": false,
    "Watches": false,
    "Electronics Items": false,
    "Furniture": false,
    "Headphones": false,
    "Beauty & Health": false,
    "Foot Ware": false,
  };

  bool showPrices = true;
  Map<String, bool> priceOptions = {
    "All Price": false,
    "Below \$200 (145)": false,
    "\$200 - \$500 (1,885)": false,
    "\$500 - \$800 (2,276)": false,
    "\$800 - \$1000 (12,676)": false,
    "\$1000 - \$1100 (13,123)": false,
  };
  RangeValues currentRangeValues = const RangeValues(40, 80);

  bool showRatingOptions = true;

  Map<String, bool> ratingOptions = {
    "1 & Above (437)": false,
    "2 & Above (657)": false,
    "3 & Above (1,897)": false,
    "4 & Above (3,571)": false,
  };


  void toggleRating(String key, bool? value) {
    ratingOptions.updateAll((k, _) => false);
    ratingOptions[key] = value ?? false;
    update();
  }


  bool showGenderOptions = true;
  Map<String, bool> genderOptions = {"Men (1,834)": false, "Women (2,890)": false, "Kid's (1,231)": false};

  bool showSizeOptions = true;
  Map<String, bool> sizeOptions = {"S (1,437)": false, "M (2,675)": false, "L (4,870)": false, "XL (7,543)": false, "XXL (1,099)": false};

  void onSelectedOption(String time) {
    selectedOption = time;
    update();
  }

  void toggleCategory(String category, bool? value) {
    if (category == "All Categories") {
      categories.updateAll((key, _) => value ?? false);
    } else {
      categories[category] = value ?? false;
      categories["All Categories"] = !categories.entries.skip(1).any((entry) => entry.value == false);
    }
    update();
  }

  void toggleCategoryVisibility() {
    showCategories = !showCategories;
    update();
  }

  void togglePrice(String key, bool? value) {
    if (key == "All Price") {
      priceOptions.updateAll((k, _) => value ?? false);
    } else {
      priceOptions[key] = value ?? false;
      priceOptions["All Price"] = !priceOptions.entries.skip(1).any((entry) => entry.value == false);
    }
    update();
  }

  void toggleGender(String key, bool? value) {
    genderOptions[key] = value ?? false;
    update();
  }

  void toggleSize(String key, bool? value) {
    sizeOptions[key] = value ?? false;
    update();
  }

  @override
  void onInit() {
    ProductGridModel.dummyList.then((value) {
      productGrid = value;
      update();
    });
    super.onInit();
  }
}