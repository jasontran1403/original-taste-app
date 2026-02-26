import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/models/order_cart_model.dart';

class OrderCartController extends MyController {
  List<OrderCartModel> orderCartModel = [];

  @override
  void onInit() {
    OrderCartModel.dummyList.then((value) {
      orderCartModel = value;
      update();
    });
    super.onInit();
  }

  void incrementQuantity(OrderCartModel order) {
    order.quantity++;
    update();
  }

  void decrementQuantity(OrderCartModel order) {
    if (order.quantity > 1) {
      order.quantity--;
      update();
    }
  }

  void clearCart() {
    orderCartModel.clear();
    update();
  }

  double get totalCartAmount {
    return orderCartModel.fold(0, (sum, item) => sum + item.total);
  }
}
