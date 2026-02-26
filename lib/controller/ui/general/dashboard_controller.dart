import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/models/chart_model.dart';
import 'package:original_taste/models/recent_order_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

enum DurationFilter { all, oneMonth, sixMonths, oneYear }

extension DurationFilterExtension on DurationFilter {
  String get label {
    switch (this) {
      case DurationFilter.all:
        return "All";
      case DurationFilter.oneMonth:
        return "1M";
      case DurationFilter.sixMonths:
        return "6M";
      case DurationFilter.oneYear:
        return "1Y";
    }
  }
}

class DashboardController extends MyController {
  DurationFilter selectedFilter = DurationFilter.all;
  late List<ChartSampleData> conversionsData;
  late List<TimeDetails> worldClockData;
  List<RecentOrderModel > recentOrder = [];

  late MapShapeSource mapSource2;

  void updateFilter(DurationFilter newFilter) {
    selectedFilter = newFilter;
    update();
  }

  final List<ChartSampleData> chartData = [
    ChartSampleData(x: 'Jan', y: 10, yValue: 1000),
    ChartSampleData(x: 'Fab', y: 20, yValue: 2000),
    ChartSampleData(x: 'Mar', y: 15, yValue: 1500),
    ChartSampleData(x: 'Jun', y: 5, yValue: 500),
    ChartSampleData(x: 'Jul', y: 30, yValue: 3000),
    ChartSampleData(x: 'Aug', y: 20, yValue: 2000),
    ChartSampleData(x: 'Sep', y: 40, yValue: 4000),
    ChartSampleData(x: 'Oct', y: 60, yValue: 6000),
    ChartSampleData(x: 'Nov', y: 55, yValue: 5500),
    ChartSampleData(x: 'Dec', y: 38, yValue: 3000),
  ];
  final TooltipBehavior chart = TooltipBehavior(enable: true, format: 'point.x : point.yValue1 : point.yValue2');

  List<PageData> pageDataList = [
    PageData(path: 'larkon/ecommerce.html', views: 465, exitRate: 4.4),
    PageData(path: 'larkon/dashboard.html', views: 426, exitRate: 20.4),
    PageData(path: 'larkon/chat.html', views: 254, exitRate: 12.25),
    PageData(path: 'larkon/auth-login.html', views: 3369, exitRate: 5.2),
    PageData(path: 'larkon/email.html', views: 985, exitRate: 64.2),
    PageData(path: 'larkon/social.html', views: 653, exitRate: 2.4),
  ];

  @override
  void onInit() {
    conversionsData = <ChartSampleData>[
      ChartSampleData(x: 'David', y: 45, text: 'David 45%'),
      ChartSampleData(x: 'Steve', y: 15, text: 'Steve 15%'),
      ChartSampleData(x: 'Jack', y: 21, text: 'Jack 21%'),
      ChartSampleData(x: 'Others', y: 19, text: 'Others 19%'),
    ];

    final DateTime currentTime = DateTime.now().toUtc();

    worldClockData = <TimeDetails>[
      TimeDetails('Seattle', 47.60621, -122.332071, currentTime.subtract(const Duration(hours: 7))),
      TimeDetails('Belem', -1.455833, -48.503887, currentTime.subtract(const Duration(hours: 3))),
      TimeDetails('Greenland', 71.706936, -42.604303, currentTime.subtract(const Duration(hours: 2))),
      TimeDetails('Yakutsk', 62.035452, 129.675475, currentTime.add(const Duration(hours: 9))),
      TimeDetails('Delhi', 28.704059, 77.10249, currentTime.add(const Duration(hours: 5, minutes: 30))),
      TimeDetails('Brisbane', -27.469771, 153.025124, currentTime.add(const Duration(hours: 10))),
      TimeDetails('Harare', -17.825166, 31.03351, currentTime.add(const Duration(hours: 2))),
    ];

    mapSource2 = const MapShapeSource.asset('assets/data/world_map.json', shapeDataField: 'name');

    RecentOrderModel.dummyList.then((value) {
      recentOrder = value;
      update();
    });
    super.onInit();
  }
}

class TimeDetails {
  TimeDetails(this.countryName, this.latitude, this.longitude, this.date);

  final String countryName;
  final double latitude;
  final double longitude;
  final DateTime date;
}


class PageData {
  final String path;
  final int views;
  final double exitRate;

  PageData({required this.path, required this.views, required this.exitRate});
}
