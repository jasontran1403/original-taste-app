import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/helper/widgets/my_text_utils.dart';

class ProfileController extends MyController {
  List<String> dummyTexts = List.generate(12, (index) => MyTextUtils.getDummyText(60));

  final Map<String, bool> filters = {
    'All Topics (23)': true,
    '#SaaS (21)': false,
    '#LatAm (5)': false,
    '#inbound (4)': false,
    '#Europe (25)': false,
    '#Performance-marketing (7)': false,
    '#Facebook-advertising (8)': false,
  };

}