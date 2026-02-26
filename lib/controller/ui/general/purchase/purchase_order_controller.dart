import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/models/purchase_order.dart';

class PurchaseOrderController extends MyController {
  List<PurchaseOrder> purchaseOrder =[];
  String selectedOption = 'This Month';

  @override
  void onInit() {
    PurchaseOrder.dummyList.then((value) {
      purchaseOrder = value;
      update();
    });
    super.onInit();
  }

  void onSelectedOption(String time) {
    selectedOption = time;
    update();
  }
}