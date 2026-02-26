import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/models/warehouse_list_model.dart';

class WarehouseController extends MyController {
  List<WarehouseListModel> warehouseList = [];
  List<bool> selectedCheckboxes = [];
  bool isAllSelected = false;
  String selectedOption = 'This Month';

  @override
  void onInit() {
    WarehouseListModel.dummyList.then((value) {
      warehouseList = value;
      selectedCheckboxes = List.generate(warehouseList.length, (_) => isAllSelected);
      update();
    });
    super.onInit();
  }

  void toggleSelectAll(bool? value) {
    isAllSelected = value ?? false;
    selectedCheckboxes = List.generate(warehouseList.length, (_) => isAllSelected);
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