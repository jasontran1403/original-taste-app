import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/models/attribute_list_model.dart';

class AttributeListController extends MyController {
  List<AttributeListModel> attributeList = [];
  List<bool> selectedCheckboxes = [];
  bool isAllSelected = false;

  String selectedOption = 'This Month';

  @override
  void onInit() {
    AttributeListModel.dummyList.then((value) {
      attributeList = value;
      selectedCheckboxes = List.generate(attributeList.length, (_) => false);
      update();
    });
    super.onInit();
  }

  void toggleSelectAll(bool? value) {
    isAllSelected = value ?? false;
    selectedCheckboxes = List.generate(attributeList.length, (_) => isAllSelected);
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

  void togglePublished(AttributeListModel toggle){
    toggle.published = !toggle.published;
    update();
  }
}
