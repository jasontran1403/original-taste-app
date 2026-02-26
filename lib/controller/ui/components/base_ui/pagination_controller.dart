import 'package:original_taste/controller/my_controller.dart';

class PaginationController extends MyController {
  int roundedPagination = 2;

  void goToRoundPagination(int page) {
    roundedPagination = page;
    update();
  }
}