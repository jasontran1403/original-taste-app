import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/models/received_order_model.dart';

class ReceivedOrdersController extends MyController {
  List<ReceivedOrderModel> receivedOrder = [];
  String selectedOption = 'This Month';

  @override
  void onInit() {
    ReceivedOrderModel.dummyList.then((value) {
      receivedOrder = value;
      update();
    });
    super.onInit();
  }

  void onSelectedOption(String time) {
    selectedOption = time;
    update();
  }
}
