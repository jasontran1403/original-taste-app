import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/helper/widgets/my_text_utils.dart';

class CardsController extends MyController {
  List<String> dummyTexts =
  List.generate(12, (index) => MyTextUtils.getDummyText(60));
}