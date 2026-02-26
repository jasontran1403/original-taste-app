import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/helper/widgets/my_text_utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SellersDetailsController extends MyController {
  List<String> dummyTexts = List.generate(12, (index) => MyTextUtils.getDummyText(60));
  String selectedOption = 'This Month';
  List<ChartData>? chartData;
  TooltipBehavior? tooltipBehavior;

  @override
  void onInit() {
    chartData = <ChartData>[
      ChartData(2018, 35, 42),
      ChartData(2019, 40, 50),
      ChartData(2020, 45, 58),
      ChartData(2021, 60, 72),
      ChartData(2022, 68, 80),
      ChartData(2023, 75, 90),
      ChartData(2024, 82, 95),
    ];
    tooltipBehavior = TooltipBehavior(enable: true);
    super.onInit();
  }

  void onSelectedOption(String time) {
    selectedOption = time;
    update();
  }

  List latestAddedProduct = [
    {
      "productName": "Black T-shirt",
      "image": "assets/product/p-1.png",
      "tagId": "ID46765",
      "category": "Fashion",
      "addDate": "08/05/2023",
      "variants": 4,
      "status": {"label": "Published", "type": "success"},
    },
    {
      "productName": "Olive Green Leather Bag",
      "image": "assets/product/p-2.png",
      "tagId": "ID36192",
      "category": "Hand Bag",
      "addDate": "10/05/2023",
      "variants": 2,
      "status": {"label": "Pending", "type": "pending"},
    },
    {
      "productName": "Women Golden Dress",
      "image": "assets/product/p-3.png",
      "tagId": "ID37729",
      "category": "Fashion",
      "addDate": "20/05/2023",
      "variants": 5,
      "status": {"label": "Published", "type": "success"},
    },
    {
      "productName": "Gray Cap For Men",
      "image": "assets/product/p-4.png",
      "tagId": "ID09260",
      "category": "Cap",
      "addDate": "21/05/2023",
      "variants": 3,
      "status": {"label": "Published", "type": "success"},
    },
    {
      "productName": "Dark Green Cargo Pent",
      "image": "assets/product/p-5.png",
      "tagId": "ID24109",
      "category": "Fashion",
      "addDate": "23/05/2023",
      "variants": 6,
      "status": {"label": "Draft", "type": "draft"},
    },
  ];
}

class ChartData {
  ChartData(this.x, this.y, this.y2);
  final double x;
  final double y;
  final double y2;
}
