import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/models/customer_list_model.dart';

class CustomerListController extends MyController {
  List<CustomerListModel> customerList = [];
  List<bool> selectedCheckboxes = [];
  bool isAllSelected = false;
  String selectedOption = 'This Month';


  @override
  void onInit() {
    CustomerListModel.dummyList.then((value) {
      customerList = value;
      update();
    });
    super.onInit();
  }

  void toggleSelectAll(bool? value) {
    isAllSelected = value ?? false;
    selectedCheckboxes = List.generate(customerList.length, (_) => isAllSelected);
    update();
  }

  void toggleCheckbox(int index, bool? value) {
    selectedCheckboxes[index] = value ?? false;
    isAllSelected = !selectedCheckboxes.contains(false);
    update();
  }

  void onSelectedOption(String time) {
    selectedOption = time;
    update();
  }
}