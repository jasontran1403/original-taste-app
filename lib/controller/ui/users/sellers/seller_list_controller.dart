import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/models/seller_list_model.dart';

class SellerListController extends MyController {
  List<SellerListModel> sellersList =[];
  Set<int> likedIndexes = {};




  @override
  void onInit() {
    SellerListModel.dummyList.then((value) {
      sellersList = value;
      update();
    },);
    super.onInit();
  }

  void toggleLike(int index) {
    if (likedIndexes.contains(index)) {
      likedIndexes.remove(index);
    } else {
      likedIndexes.add(index);
    }
    update();
  }
}