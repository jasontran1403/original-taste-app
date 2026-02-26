import 'package:flutter/material.dart';
import 'package:original_taste/controller/my_controller.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CustomerDetailsController extends MyController {
  List<ChartSampleData>? chartData;
  TooltipBehavior? tooltipBehavior;
  final List<Map<String, String>> invoices = [
    {'id': '#INV2540', 'date': '16 May 2024'},
    {'id': '#INV0914', 'date': '17 Jan 2024'},
    {'id': '#INV3801', 'date': '09 Nov 2023'},
    {'id': '#INV4782', 'date': '21 Aug 2023'},
  ];
  final List<Map<String, String>> transactions = [
    {'id': '#INV2540', 'status': 'Completed', 'amount': '\$421.00', 'dueDate': '07 Jan, 2023', 'method': 'Mastercard'},
    {'id': '#INV3924', 'status': 'Cancel', 'amount': '\$736.00', 'dueDate': '03 Dec, 2023', 'method': 'Visa'},
    {'id': '#INV5032', 'status': 'Completed', 'amount': '\$347.00', 'dueDate': '28 Sep, 2023', 'method': 'Paypal'},
    {'id': '#INV1695', 'status': 'Pending', 'amount': '\$457.00', 'dueDate': '10 Aug, 2023', 'method': 'Mastercard'},
    {'id': '#INV8473', 'status': 'Completed', 'amount': '\$414.00', 'dueDate': '22 May, 2023', 'method': 'Visa'},
  ];

  @override
  void onInit() {
    chartData = <ChartSampleData>[
      ChartSampleData(x: 'Jan', y: 43),
      ChartSampleData(x: 'Feb', y: 45),
      ChartSampleData(x: 'Mar', y: 50),
      ChartSampleData(x: 'Apr', y: 55),
      ChartSampleData(x: 'May', y: 63),
      ChartSampleData(x: 'Jun', y: 68),
      ChartSampleData(x: 'Jul', y: 72),
      ChartSampleData(x: 'Aug', y: 70),
      ChartSampleData(x: 'Sep', y: 66),
      ChartSampleData(x: 'Oct', y: 57),
      ChartSampleData(x: 'Nov', y: 50),
      ChartSampleData(x: 'Dec', y: 45),
    ];
    tooltipBehavior = TooltipBehavior(enable: true);
    super.onInit();
  }
}

class ChartSampleData {
  ChartSampleData({
    this.x,
    this.y,
    this.xValue,
    this.yValue,
    this.secondSeriesYValue,
    this.thirdSeriesYValue,
    this.pointColor,
    this.size,
    this.text,
    this.open,
    this.close,
    this.low,
    this.high,
    this.volume,
  });

  final dynamic x;
  final num? y;
  final dynamic xValue;
  final num? yValue;
  final num? secondSeriesYValue;
  final num? thirdSeriesYValue;
  final Color? pointColor;
  final num? size;
  final String? text;
  final num? open;
  final num? close;
  final num? low;
  final num? high;
  final num? volume;
}

class ChartData {
  ChartData(this.x, this.y, this.y2);

  final double x;
  final double y;
  final double y2;
}
