import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/models/coupons_list_model.dart';

class CouponsListController extends MyController {
  String selectedOption = 'This Month';
  List<CouponsListModel> couponList = [];
  List<bool> selectedCheckboxes = [];
  bool isAllSelected = false;

  @override
  void onInit() {
    CouponsListModel.dummyList.then((value) {
      couponList = value;
      selectedCheckboxes = List.generate(couponList.length, (_) => false);
      update();
    });
    super.onInit();
  }

  void onSelectedOption(String time) {
    selectedOption = time;
    update();
  }

  void toggleSelectAll(bool? value) {
    isAllSelected = value ?? false;
    selectedCheckboxes = List.generate(couponList.length, (_) => isAllSelected);
    update();
  }

  void toggleCheckbox(int index, bool? value) {
    selectedCheckboxes[index] = value ?? false;
    isAllSelected = !selectedCheckboxes.contains(false);
    update();
  }
}
