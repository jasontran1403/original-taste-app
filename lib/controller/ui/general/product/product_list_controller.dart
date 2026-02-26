import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/models/product_list_model.dart';

class ProductListController extends MyController {
  String selectedOption = 'This Month';
  List<ProductListModel> products = [];
  List<bool> selectedCheckboxes = [];
  bool isAllSelected = false;

  void onSelectedOption(String time) {
    selectedOption = time;
    update();
  }

  void toggleSelectAll(bool? value) {
    isAllSelected = value ?? false;
    selectedCheckboxes = List.generate(products.length, (_) => isAllSelected);
    update();
  }

  void toggleCheckbox(int index, bool? value) {
    selectedCheckboxes[index] = value ?? false;
    isAllSelected = !selectedCheckboxes.contains(false);
    update();
  }

  @override
  void onInit() {
    ProductListModel.dummyList.then((value) {
      products = value;
      selectedCheckboxes = List.generate(products.length, (_) => false);
      update();
    });
    super.onInit();
  }
}
