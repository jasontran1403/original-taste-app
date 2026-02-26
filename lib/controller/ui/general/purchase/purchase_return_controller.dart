import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/models/purchase_return_model.dart';

class PurchaseReturnController extends MyController {
  String selectedOption = 'This Month';
  List<PurchaseReturnModel> purchaseReturn = [];
  List<bool> selectedCheckboxes = [];
  bool isAllSelected = false;

  @override
  void onInit() {
    PurchaseReturnModel.dummyList.then((value) {
      purchaseReturn = value;
      selectedCheckboxes = List.generate(purchaseReturn.length, (_) => false);
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
    selectedCheckboxes = List.generate(purchaseReturn.length, (_) => isAllSelected);
    update();
  }

  void toggleCheckbox(int index, bool? value) {
    selectedCheckboxes[index] = value ?? false;
    isAllSelected = !selectedCheckboxes.contains(false);
    update();
  }
}