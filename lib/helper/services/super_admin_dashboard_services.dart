// lib/helper/services/super_admin_dashboard_services.dart

import 'package:original_taste/helper/services/api_helper.dart';
import '../../../controller/ui/general/super_admin_dashboard_controller.dart'
    show SuperAdminDashboardPeriod;

const String _dashboardBase = '/api/superadmin/dashboard';

// ══════════════════════════════════════════════════════════════════
// PRIVATE HELPERS
// ══════════════════════════════════════════════════════════════════

double _d(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int)    return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}

Map<String, dynamic> _m(dynamic v) =>
    v is Map<String, dynamic> ? v : <String, dynamic>{};

List<T> _list<T>(dynamic raw, T Function(Map<String, dynamic>) fromJson) {
  if (raw == null) return [];
  return (raw as List).whereType<Map<String, dynamic>>().map(fromJson).toList();
}

// ══════════════════════════════════════════════════════════════════
// RESTAURANT MODELS
// ══════════════════════════════════════════════════════════════════

class SuperAdminOrderSummaryModel {
  final int totalOrders;
  final int pendingOrders;
  final int confirmedOrders;
  final int preparingOrders;
  final int readyOrders;
  final int deliveringOrders;
  final int completedOrders;
  final int cancelledOrders;
  final int failedOrders;

  const SuperAdminOrderSummaryModel({
    this.totalOrders      = 0,
    this.pendingOrders    = 0,
    this.confirmedOrders  = 0,
    this.preparingOrders  = 0,
    this.readyOrders      = 0,
    this.deliveringOrders = 0,
    this.completedOrders  = 0,
    this.cancelledOrders  = 0,
    this.failedOrders     = 0,
  });

  int get activeOrders =>
      pendingOrders + confirmedOrders + preparingOrders + readyOrders + deliveringOrders;

  factory SuperAdminOrderSummaryModel.fromJson(Map<String, dynamic> j) =>
      SuperAdminOrderSummaryModel(
        totalOrders:      j['totalOrders']      ?? 0,
        pendingOrders:    j['pendingOrders']    ?? 0,
        confirmedOrders:  j['confirmedOrders']  ?? 0,
        preparingOrders:  j['preparingOrders']  ?? 0,
        readyOrders:      j['readyOrders']      ?? 0,
        deliveringOrders: j['deliveringOrders'] ?? 0,
        completedOrders:  j['completedOrders']  ?? 0,
        cancelledOrders:  j['cancelledOrders']  ?? 0,
        failedOrders:     j['failedOrders']     ?? 0,
      );
}

class SuperAdminRevenueSummaryModel {
  final double completedRevenue;
  final double pendingRevenue;
  final double totalDiscount;
  final double totalVat;

  const SuperAdminRevenueSummaryModel({
    this.completedRevenue = 0,
    this.pendingRevenue   = 0,
    this.totalDiscount    = 0,
    this.totalVat         = 0,
  });

  factory SuperAdminRevenueSummaryModel.fromJson(Map<String, dynamic> j) =>
      SuperAdminRevenueSummaryModel(
        completedRevenue: _d(j['completedRevenue']),
        pendingRevenue:   _d(j['pendingRevenue']),
        totalDiscount:    _d(j['totalDiscount']),
        totalVat:         _d(j['totalVat']),
      );
}

class SuperAdminCustomerSummaryModel {
  final int newCustomers;
  final int returningCustomers;

  const SuperAdminCustomerSummaryModel({
    this.newCustomers       = 0,
    this.returningCustomers = 0,
  });

  int get total => newCustomers + returningCustomers;

  factory SuperAdminCustomerSummaryModel.fromJson(Map<String, dynamic> j) =>
      SuperAdminCustomerSummaryModel(
        newCustomers:       j['newCustomers']       ?? 0,
        returningCustomers: j['returningCustomers'] ?? 0,
      );
}

class SuperAdminPaymentMethodItem {
  final String method;
  final String label;
  final double amount;
  final int    count;

  const SuperAdminPaymentMethodItem({
    required this.method,
    required this.label,
    this.amount = 0,
    this.count  = 0,
  });

  factory SuperAdminPaymentMethodItem.fromJson(Map<String, dynamic> j) =>
      SuperAdminPaymentMethodItem(
        method: j['method'] ?? '',
        label:  j['label']  ?? j['method'] ?? '',
        amount: _d(j['amount']),
        count:  j['count'] ?? 0,
      );
}

class SuperAdminPaymentBreakdownModel {
  final List<SuperAdminPaymentMethodItem> methods;

  const SuperAdminPaymentBreakdownModel({this.methods = const []});

  double get totalAmount => methods.fold(0, (s, m) => s + m.amount);
  int    get totalCount  => methods.fold(0, (s, m) => s + m.count);

  factory SuperAdminPaymentBreakdownModel.fromJson(Map<String, dynamic> j) {
    final raw = j['methods'];
    return SuperAdminPaymentBreakdownModel(
      methods: raw is List
          ? raw.whereType<Map<String, dynamic>>()
          .map(SuperAdminPaymentMethodItem.fromJson)
          .toList()
          : [],
    );
  }
}

class SuperAdminTopProductModel {
  final int     productId;
  final String  productName;
  final String? productImageUrl;
  final double  totalQuantity;
  final double  totalRevenue;
  final int     orderCount;

  const SuperAdminTopProductModel({
    required this.productId,
    required this.productName,
    this.productImageUrl,
    this.totalQuantity = 0,
    this.totalRevenue  = 0,
    this.orderCount    = 0,
  });

  factory SuperAdminTopProductModel.fromJson(Map<String, dynamic> j) =>
      SuperAdminTopProductModel(
        productId:       j['productId']      ?? 0,
        productName:     j['productName']    ?? '',
        productImageUrl: j['productImageUrl'],
        totalQuantity:   _d(j['totalQuantity']),
        totalRevenue:    _d(j['totalRevenue']),
        orderCount:      j['orderCount']     ?? 0,
      );
}

class SuperAdminTopCustomerModel {
  final int?    customerId;
  final String  customerName;
  final String? customerPhone;
  final int     orderCount;
  final double  totalSpent;

  const SuperAdminTopCustomerModel({
    this.customerId,
    required this.customerName,
    this.customerPhone,
    this.orderCount = 0,
    this.totalSpent = 0,
  });

  factory SuperAdminTopCustomerModel.fromJson(Map<String, dynamic> j) =>
      SuperAdminTopCustomerModel(
        customerId:    j['customerId'],
        customerName:  j['customerName']  ?? 'Khách vãng lai',
        customerPhone: j['customerPhone'],
        orderCount:    j['orderCount']    ?? 0,
        totalSpent:    _d(j['totalSpent']),
      );
}

class SuperAdminTopUserModel {
  final int    userId;
  final String userName;
  final String fullName;
  final int    orderCount;
  final double totalRevenue;

  const SuperAdminTopUserModel({
    required this.userId,
    required this.userName,
    required this.fullName,
    this.orderCount   = 0,
    this.totalRevenue = 0,
  });

  factory SuperAdminTopUserModel.fromJson(Map<String, dynamic> j) =>
      SuperAdminTopUserModel(
        userId:       j['userId']       ?? 0,
        userName:     j['userName']     ?? '',
        fullName:     j['fullName']     ?? '',
        orderCount:   j['orderCount']   ?? 0,
        totalRevenue: _d(j['totalRevenue']),
      );
}

class SuperAdminOrderByTimeModel {
  final String timeBucket;
  final int    orderCount;
  final double revenue;

  const SuperAdminOrderByTimeModel({
    required this.timeBucket,
    this.orderCount = 0,
    this.revenue    = 0,
  });

  factory SuperAdminOrderByTimeModel.fromJson(Map<String, dynamic> j) =>
      SuperAdminOrderByTimeModel(
        timeBucket: j['timeBucket'] ?? '',
        orderCount: j['orderCount'] ?? 0,
        revenue:    _d(j['revenue']),
      );
}

class SuperAdminRegionBreakdownModel {
  final String region;
  final int    orderCount;
  final double revenue;

  const SuperAdminRegionBreakdownModel({
    required this.region,
    this.orderCount = 0,
    this.revenue    = 0,
  });

  factory SuperAdminRegionBreakdownModel.fromJson(Map<String, dynamic> j) =>
      SuperAdminRegionBreakdownModel(
        region:     j['region']     ?? '',
        orderCount: j['orderCount'] ?? 0,
        revenue:    _d(j['revenue']),
      );
}

class SuperAdminDashboardRecentOrderModel {
  final int     orderId;
  final String  orderCode;
  final String? customerName;
  final int?    createdAt;
  final double  totalAmount;
  final double  discountAmount;
  final double  vatAmount;
  final double  finalAmount;
  final String  status;
  final String  paymentStatus;

  const SuperAdminDashboardRecentOrderModel({
    required this.orderId,
    required this.orderCode,
    this.customerName,
    this.createdAt,
    this.totalAmount    = 0,
    this.discountAmount = 0,
    this.vatAmount      = 0,
    this.finalAmount    = 0,
    this.status         = '',
    this.paymentStatus  = '',
  });

  factory SuperAdminDashboardRecentOrderModel.fromJson(Map<String, dynamic> j) =>
      SuperAdminDashboardRecentOrderModel(
        orderId:        j['orderId']        ?? 0,
        orderCode:      j['orderCode']      ?? '',
        customerName:   j['customerName'],
        createdAt:      j['createdAt'],
        totalAmount:    _d(j['totalAmount']),
        discountAmount: _d(j['discountAmount']),
        vatAmount:      _d(j['vatAmount']),
        finalAmount:    _d(j['finalAmount']),
        status:         j['status']         ?? '',
        paymentStatus:  j['paymentStatus']  ?? '',
      );
}

// ── Top-level Restaurant Model ────────────────────────────────────

class SuperAdminRestaurantDashboardModel {
  final SuperAdminOrderSummaryModel               orderSummary;
  final SuperAdminRevenueSummaryModel             revenueSummary;
  final SuperAdminCustomerSummaryModel            customerSummary;
  final SuperAdminPaymentBreakdownModel           paymentBreakdown;
  final List<SuperAdminTopProductModel>           topProducts;
  final List<SuperAdminTopCustomerModel>          topCustomers;
  final List<SuperAdminTopUserModel>              topUsers;
  final List<SuperAdminOrderByTimeModel>          ordersByTime;
  final List<SuperAdminRegionBreakdownModel>      regionBreakdown;
  final List<SuperAdminDashboardRecentOrderModel> recentOrders;

  const SuperAdminRestaurantDashboardModel({
    required this.orderSummary,
    required this.revenueSummary,
    required this.customerSummary,
    required this.paymentBreakdown,
    required this.topProducts,
    required this.topCustomers,
    required this.topUsers,
    required this.ordersByTime,
    required this.regionBreakdown,
    required this.recentOrders,
  });

  factory SuperAdminRestaurantDashboardModel.fromJson(Map<String, dynamic> j) =>
      SuperAdminRestaurantDashboardModel(
        orderSummary:     SuperAdminOrderSummaryModel.fromJson(_m(j['orderSummary'])),
        revenueSummary:   SuperAdminRevenueSummaryModel.fromJson(_m(j['revenueSummary'])),
        customerSummary:  SuperAdminCustomerSummaryModel.fromJson(_m(j['customerSummary'])),
        paymentBreakdown: SuperAdminPaymentBreakdownModel.fromJson(_m(j['paymentBreakdown'])),
        topProducts:  _list(j['topProducts'],  SuperAdminTopProductModel.fromJson),
        topCustomers: _list(j['topCustomers'], SuperAdminTopCustomerModel.fromJson),
        topUsers:     _list(j['topUsers'],     SuperAdminTopUserModel.fromJson),
        ordersByTime: _list(j['ordersByTime'], SuperAdminOrderByTimeModel.fromJson),
        regionBreakdown: _list(j['regionBreakdown'], SuperAdminRegionBreakdownModel.fromJson),
        recentOrders: _list(j['recentOrders'], SuperAdminDashboardRecentOrderModel.fromJson),
      );
}

// ══════════════════════════════════════════════════════════════════
// POS MODELS
// ══════════════════════════════════════════════════════════════════

class SuperAdminPosOrderSummaryModel {
  final int offlineOrders;
  final int shopeeFoodOrders;
  final int grabFoodOrders;
  final int totalOrders;
  final int completedOrders;
  final int cancelledOrders;
  final int pendingOrders;
  final int offlineOrdersCompleted;
  final int offlineOrdersPending;
  final int shopeeFoodOrdersCompleted;
  final int shopeeFoodOrdersPending;
  final int grabFoodOrdersCompleted;
  final int grabFoodOrdersPending;

  const SuperAdminPosOrderSummaryModel({
    this.offlineOrders    = 0,
    this.shopeeFoodOrders = 0,
    this.grabFoodOrders   = 0,
    this.totalOrders      = 0,
    this.completedOrders  = 0,
    this.cancelledOrders  = 0,
    this.pendingOrders    = 0,
    this.offlineOrdersCompleted    = 0,
    this.offlineOrdersPending      = 0,
    this.shopeeFoodOrdersCompleted = 0,
    this.shopeeFoodOrdersPending   = 0,
    this.grabFoodOrdersCompleted   = 0,
    this.grabFoodOrdersPending     = 0,
  });

  factory SuperAdminPosOrderSummaryModel.fromJson(Map<String, dynamic> j) =>
      SuperAdminPosOrderSummaryModel(
        offlineOrders:    j['offlineOrders']    ?? 0,
        shopeeFoodOrders: j['shopeeFoodOrders'] ?? 0,
        grabFoodOrders:   j['grabFoodOrders']   ?? 0,
        totalOrders:      j['totalOrders']      ?? 0,
        completedOrders:  j['completedOrders']  ?? 0,
        cancelledOrders:  j['cancelledOrders']  ?? 0,
        pendingOrders:    j['pendingOrders']    ?? 0,
        offlineOrdersCompleted:    j['offlineOrdersCompleted']    ?? 0,
        offlineOrdersPending:      j['offlineOrdersPending']      ?? 0,
        shopeeFoodOrdersCompleted: j['shopeeFoodOrdersCompleted'] ?? 0,
        shopeeFoodOrdersPending:   j['shopeeFoodOrdersPending']   ?? 0,
        grabFoodOrdersCompleted:   j['grabFoodOrdersCompleted']   ?? 0,
        grabFoodOrdersPending:     j['grabFoodOrdersPending']     ?? 0,
      );
}

class SuperAdminPosRevenueSummaryModel {
  final double totalRevenue;
  final double offlineRevenue;
  final double shopeeFoodRevenue;
  final double grabFoodRevenue;

  const SuperAdminPosRevenueSummaryModel({
    this.totalRevenue      = 0,
    this.offlineRevenue    = 0,
    this.shopeeFoodRevenue = 0,
    this.grabFoodRevenue   = 0,
  });

  factory SuperAdminPosRevenueSummaryModel.fromJson(Map<String, dynamic> j) =>
      SuperAdminPosRevenueSummaryModel(
        totalRevenue:      _d(j['totalRevenue']),
        offlineRevenue:    _d(j['offlineRevenue']),
        shopeeFoodRevenue: _d(j['shopeeFoodRevenue']),
        grabFoodRevenue:   _d(j['grabFoodRevenue']),
      );
}

class SuperAdminPosPieItemModel {
  final String key;
  final String label;
  final int    count;
  final double amount;

  const SuperAdminPosPieItemModel({
    required this.key,
    required this.label,
    this.count  = 0,
    this.amount = 0,
  });

  factory SuperAdminPosPieItemModel.fromJson(Map<String, dynamic> j) =>
      SuperAdminPosPieItemModel(
        key:    j['key']    ?? '',
        label:  j['label']  ?? '',
        count:  j['count']  ?? 0,
        amount: _d(j['amount']),
      );
}

class SuperAdminPosPaymentMethodItem {
  final String method;
  final String label;
  final double amount;
  final int    count;

  const SuperAdminPosPaymentMethodItem({
    required this.method,
    required this.label,
    this.amount = 0,
    this.count  = 0,
  });

  factory SuperAdminPosPaymentMethodItem.fromJson(Map<String, dynamic> j) =>
      SuperAdminPosPaymentMethodItem(
        method: j['method'] ?? '',
        label:  j['label']  ?? j['method'] ?? '',
        amount: _d(j['amount']),
        count:  j['count'] ?? 0,
      );
}

class SuperAdminPosPaymentBreakdownModel {
  final List<SuperAdminPosPaymentMethodItem> methods;
  final List<SuperAdminPosPieItemModel>      sourcePieItems;
  final List<SuperAdminPosPieItemModel>      categoryPieItems;

  const SuperAdminPosPaymentBreakdownModel({
    this.methods          = const [],
    this.sourcePieItems   = const [],
    this.categoryPieItems = const [],
  });

  double get totalAmount => methods.fold(0, (s, m) => s + m.amount);
  int    get totalCount  => methods.fold(0, (s, m) => s + m.count);

  factory SuperAdminPosPaymentBreakdownModel.fromJson(Map<String, dynamic> j) {
    final raw    = j['methods'];
    final srcRaw = j['sourcePieItems'];
    final catRaw = j['categoryPieItems'];
    return SuperAdminPosPaymentBreakdownModel(
      methods: raw is List
          ? raw.whereType<Map<String, dynamic>>()
          .map(SuperAdminPosPaymentMethodItem.fromJson).toList()
          : [],
      sourcePieItems: srcRaw is List
          ? srcRaw.whereType<Map<String, dynamic>>()
          .map(SuperAdminPosPieItemModel.fromJson).toList()
          : [],
      categoryPieItems: catRaw is List
          ? catRaw.whereType<Map<String, dynamic>>()
          .map(SuperAdminPosPieItemModel.fromJson).toList()
          : [],
    );
  }
}

class SuperAdminPosTopProductModel {
  final int     productId;
  final String  productName;
  final String? productImageUrl;
  final double  totalQuantity;
  final double  totalRevenue;
  final int     orderCount;

  const SuperAdminPosTopProductModel({
    required this.productId,
    required this.productName,
    this.productImageUrl,
    this.totalQuantity = 0,
    this.totalRevenue  = 0,
    this.orderCount    = 0,
  });

  factory SuperAdminPosTopProductModel.fromJson(Map<String, dynamic> j) =>
      SuperAdminPosTopProductModel(
        productId:       j['productId']      ?? 0,
        productName:     j['productName']    ?? '',
        productImageUrl: j['productImageUrl'],
        totalQuantity:   _d(j['totalQuantity']),
        totalRevenue:    _d(j['totalRevenue']),
        orderCount:      j['orderCount']     ?? 0,
      );
}

class SuperAdminPosOrderByTimeModel {
  final String timeBucket;
  final int    orderCount;
  final double revenue;

  const SuperAdminPosOrderByTimeModel({
    required this.timeBucket,
    this.orderCount = 0,
    this.revenue    = 0,
  });

  factory SuperAdminPosOrderByTimeModel.fromJson(Map<String, dynamic> j) =>
      SuperAdminPosOrderByTimeModel(
        timeBucket: j['timeBucket'] ?? '',
        orderCount: j['orderCount'] ?? 0,
        revenue:    _d(j['revenue']),
      );
}

class SuperAdminPosRecentOrderModel {
  final int     orderId;
  final String  orderCode;
  final String  orderSource;
  final int?    createdAt;
  final double  totalAmount;
  final double  finalAmount;
  final String  status;
  final String? paymentMethod;
  final String  paymentStatus;

  const SuperAdminPosRecentOrderModel({
    required this.orderId,
    required this.orderCode,
    this.orderSource   = 'OFFLINE',
    this.createdAt,
    this.totalAmount   = 0,
    this.finalAmount   = 0,
    this.status        = '',
    this.paymentMethod,
    this.paymentStatus = '',
  });

  factory SuperAdminPosRecentOrderModel.fromJson(Map<String, dynamic> j) =>
      SuperAdminPosRecentOrderModel(
        orderId:       j['orderId']       ?? 0,
        orderCode:     j['orderCode']     ?? '',
        orderSource:   j['orderSource']   ?? 'OFFLINE',
        createdAt:     j['createdAt'],
        totalAmount:   _d(j['totalAmount']),
        finalAmount:   _d(j['finalAmount']),
        status:        j['status']        ?? '',
        paymentMethod: j['paymentMethod'],
        paymentStatus: j['paymentStatus'] ?? '',
      );
}

// ── Top-level POS Dashboard Model ─────────────────────────────────

class SuperAdminPosDashboardModel {
  final SuperAdminPosOrderSummaryModel     orderSummary;
  final SuperAdminPosRevenueSummaryModel   revenueSummary;
  final SuperAdminPosPaymentBreakdownModel paymentBreakdown;
  final List<SuperAdminPosTopProductModel>  topProducts;
  final List<SuperAdminPosOrderByTimeModel> ordersByTime;
  final List<SuperAdminPosRecentOrderModel> recentOrders;

  const SuperAdminPosDashboardModel({
    required this.orderSummary,
    required this.revenueSummary,
    required this.paymentBreakdown,
    required this.topProducts,
    required this.ordersByTime,
    required this.recentOrders,
  });

  factory SuperAdminPosDashboardModel.fromJson(Map<String, dynamic> j) =>
      SuperAdminPosDashboardModel(
        orderSummary:     SuperAdminPosOrderSummaryModel.fromJson(_m(j['orderSummary'])),
        revenueSummary:   SuperAdminPosRevenueSummaryModel.fromJson(_m(j['revenueSummary'])),
        paymentBreakdown: SuperAdminPosPaymentBreakdownModel.fromJson(_m(j['paymentBreakdown'])),
        topProducts:  _list(j['topProducts'],  SuperAdminPosTopProductModel.fromJson),
        ordersByTime: _list(j['ordersByTime'], SuperAdminPosOrderByTimeModel.fromJson),
        recentOrders: _list(j['recentOrders'], SuperAdminPosRecentOrderModel.fromJson),
      );
}

// ══════════════════════════════════════════════════════════════════
// SERVICE
// ══════════════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════════════
// POS VEHICLE MODEL
// ══════════════════════════════════════════════════════════════════

class PosVehicle {
  final int    id;
  final String name;
  final String? avatarUrl;
  final String? address;
  final String? phone;
  final int?    storeId;    // ← thêm

  const PosVehicle({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.address,
    this.phone,
    this.storeId,           // ← thêm
  });

  factory PosVehicle.fromJson(Map<String, dynamic> j) => PosVehicle(
    id:        j['id']        ?? 0,
    name:      j['name']      ?? '',
    avatarUrl: j['avatarUrl'] as String?,
    address:   j['address']  as String?,
    phone:     j['phone']    as String?,
  );
}

// ══════════════════════════════════════════════════════════════════
// SERVICE
// ══════════════════════════════════════════════════════════════════

class SuperAdminDashboardService {
  // ── Vehicles ─────────────────────────────────────────────────────
  static Future<ApiResult<List<PosVehicle>>> getVehicles() async {
    return ApiHelper.get<List<PosVehicle>>(
      '$_dashboardBase/pos/vehicles',
      fromData: (d) => d != null
          ? (d as List).whereType<Map<String, dynamic>>()
          .map(PosVehicle.fromJson)
          .toList()
          : <PosVehicle>[],
    );
  }

  // ── POS ──────────────────────────────────────────────────────────
  static Future<ApiResult<SuperAdminPosDashboardModel>> getPosDashboard({
    SuperAdminDashboardPeriod period = SuperAdminDashboardPeriod.days30,
    DateTime? fromDate,
    DateTime? toDate,
    int? vehicleId,                                   // ← NEW: ID xe
  }) async {
    final params = <String, String>{'period': period.apiValue};

    if (vehicleId != null) params['vehicleId'] = vehicleId.toString();

    if (period == SuperAdminDashboardPeriod.custom) {
      if (fromDate != null) params['fromTs'] = fromDate.millisecondsSinceEpoch.toString();
      if (toDate   != null) params['toTs']   = toDate.millisecondsSinceEpoch.toString();
    }

    return ApiHelper.get<SuperAdminPosDashboardModel>(
      '$_dashboardBase/pos',
      queryParams: params,
      fromData: (d) => d != null
          ? SuperAdminPosDashboardModel.fromJson(d as Map<String, dynamic>)
          : null,
    );
  }

  // ── Restaurant (wholesale / retail) ──────────────────────────────
  static Future<ApiResult<SuperAdminRestaurantDashboardModel>> getRestaurantDashboard({
    SuperAdminDashboardPeriod period = SuperAdminDashboardPeriod.days30,
    DateTime? fromDate,
    DateTime? toDate,
    required String mode,
  }) async {
    final params = <String, String>{
      'period': period.apiValue,
      'mode':   mode,
    };

    if (period == SuperAdminDashboardPeriod.custom) {
      if (fromDate != null) params['fromTs'] = fromDate.millisecondsSinceEpoch.toString();
      if (toDate   != null) params['toTs']   = toDate.millisecondsSinceEpoch.toString();
    }

    return ApiHelper.get<SuperAdminRestaurantDashboardModel>(
      '$_dashboardBase/restaurant',
      queryParams: params,
      fromData: (d) => d != null
          ? SuperAdminRestaurantDashboardModel.fromJson(d as Map<String, dynamic>)
          : null,
    );
  }
}