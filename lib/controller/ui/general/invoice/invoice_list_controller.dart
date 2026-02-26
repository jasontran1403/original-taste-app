import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/models/invoice_list_model.dart';

class InvoiceListController extends MyController {
  String selectedOption = 'This Month';
  List<InvoiceListModel> invoiceModel = [];
  List<bool> selectedCheckboxes = [];
  bool isAllSelected = false;

  @override
  void onInit() {
    InvoiceListModel.dummyList.then((value) {
      invoiceModel = value;
      selectedCheckboxes = List.generate(invoiceModel.length, (_) => false);
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
    selectedCheckboxes = List.generate(invoiceModel.length, (_) => isAllSelected);
    update();
  }

  void toggleCheckbox(int index, bool? value) {
    selectedCheckboxes[index] = value ?? false;
    isAllSelected = !selectedCheckboxes.contains(false);
    update();
  }
}