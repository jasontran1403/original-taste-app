import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/models/all_order_list_model.dart';

class OrdersListController extends MyController {
  List<AllOrderListModel> allOrder = [];
  String selectedOption = 'This Month';

  void onSelectedOption(String time) {
    selectedOption = time;
    update();
  }

  @override
  void onInit() {
    AllOrderListModel.dummyList.then((value) {
      allOrder = value;
      update();
    },);
    super.onInit();
  }
}