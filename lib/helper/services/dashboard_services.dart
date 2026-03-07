// lib/helper/services/dashboard_services.dart
import 'package:original_taste/controller/ui/general/dashboard_controller.dart'
    show DashboardPeriod;
import 'package:original_taste/helper/services/api_helper.dart';

// ══════════════════════════════════════════════════════════════════
// RESTAURANT DASHBOARD MODELS
// ══════════════════════════════════════════════════════════════════

class OrderSummaryModel {
  final int totalOrders;
  final int pendingOrders;
  final int confirmedOrders;
  final int preparingOrders;
  final int readyOrders;
  final int deliveringOrders;
  final int completedOrders;
  final int cancelledOrders;
  final int failedOrders;

  const OrderSummaryModel({
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

  factory OrderSummaryModel.fromJson(Map<String, dynamic> j) => OrderSummaryModel(
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

// ── Revenue ──────────────────────────────────────────────────────

class RevenueSummaryModel {
  final double completedRevenue;
  final double pendingRevenue;
  final double totalDiscount;
  final double totalVat;

  const RevenueSummaryModel({
    this.completedRevenue = 0,
    this.pendingRevenue   = 0,
    this.totalDiscount    = 0,
    this.totalVat         = 0,
  });

  factory RevenueSummaryModel.fromJson(Map<String, dynamic> j) => RevenueSummaryModel(
    completedRevenue: _d(j['completedRevenue']),
    pendingRevenue:   _d(j['pendingRevenue']),
    totalDiscount:    _d(j['totalDiscount']),
    totalVat:         _d(j['totalVat']),
  );
}

// ── Customer ─────────────────────────────────────────────────────

class CustomerSummaryModel {
  final int newCustomers;
  final int returningCustomers;

  const CustomerSummaryModel({
    this.newCustomers       = 0,
    this.returningCustomers = 0,
  });

  int get total => newCustomers + returningCustomers;

  factory CustomerSummaryModel.fromJson(Map<String, dynamic> j) => CustomerSummaryModel(
    newCustomers:       j['newCustomers']       ?? 0,
    returningCustomers: j['returningCustomers'] ?? 0,
  );
}

// ── Payment ──────────────────────────────────────────────────────

class PaymentMethodItem {
  final String method;
  final String label;
  final double amount;
  final int    count;

  const PaymentMethodItem({
    required this.method,
    required this.label,
    this.amount = 0,
    this.count  = 0,
  });

  factory PaymentMethodItem.fromJson(Map<String, dynamic> j) => PaymentMethodItem(
    method: j['method'] ?? '',
    label:  j['label']  ?? j['method'] ?? '',
    amount: _d(j['amount']),
    count:  j['count'] ?? 0,
  );
}

class PaymentBreakdownModel {
  final List<PaymentMethodItem> methods;

  const PaymentBreakdownModel({this.methods = const []});

  double get totalAmount => methods.fold(0, (s, m) => s + m.amount);
  int    get totalCount  => methods.fold(0, (s, m) => s + m.count);

  factory PaymentBreakdownModel.fromJson(Map<String, dynamic> j) {
    final raw = j['methods'];
    return PaymentBreakdownModel(
      methods: raw is List
          ? raw.whereType<Map<String, dynamic>>().map(PaymentMethodItem.fromJson).toList()
          : [],
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// MODELS — TOP LISTS
// ══════════════════════════════════════════════════════════════════

class TopProductModel {
  final int     productId;
  final String  productName;
  final String? productImageUrl;
  final double  totalQuantity;
  final double  totalRevenue;
  final int     orderCount;

  const TopProductModel({
    required this.productId,
    required this.productName,
    this.productImageUrl,
    this.totalQuantity = 0,
    this.totalRevenue  = 0,
    this.orderCount    = 0,
  });

  factory TopProductModel.fromJson(Map<String, dynamic> j) => TopProductModel(
    productId:       j['productId']      ?? 0,
    productName:     j['productName']    ?? '',
    productImageUrl: j['productImageUrl'],
    totalQuantity:   _d(j['totalQuantity']),
    totalRevenue:    _d(j['totalRevenue']),
    orderCount:      j['orderCount']     ?? 0,
  );
}

class TopIngredientModel {
  final int    ingredientId;
  final String ingredientName;
  final String unit;
  final double totalQuantityUsed;
  final int    usageCount;

  const TopIngredientModel({
    required this.ingredientId,
    required this.ingredientName,
    this.unit              = '',
    this.totalQuantityUsed = 0,
    this.usageCount        = 0,
  });

  factory TopIngredientModel.fromJson(Map<String, dynamic> j) => TopIngredientModel(
    ingredientId:      j['ingredientId']      ?? 0,
    ingredientName:    j['ingredientName']    ?? '',
    unit:              j['unit']              ?? '',
    totalQuantityUsed: _d(j['totalQuantityUsed']),
    usageCount:        j['usageCount']        ?? 0,
  );
}

class TopCustomerModel {
  final int?    customerId;
  final String  customerName;
  final String? customerPhone;
  final int     orderCount;
  final double  totalSpent;

  const TopCustomerModel({
    this.customerId,
    required this.customerName,
    this.customerPhone,
    this.orderCount = 0,
    this.totalSpent = 0,
  });

  factory TopCustomerModel.fromJson(Map<String, dynamic> j) => TopCustomerModel(
    customerId:    j['customerId'],
    customerName:  j['customerName']  ?? 'Khách vãng lai',
    customerPhone: j['customerPhone'],
    orderCount:    j['orderCount']    ?? 0,
    totalSpent:    _d(j['totalSpent']),
  );
}

class TopUserModel {
  final int    userId;
  final String userName;
  final String fullName;
  final int    orderCount;
  final double totalRevenue;

  const TopUserModel({
    required this.userId,
    required this.userName,
    required this.fullName,
    this.orderCount   = 0,
    this.totalRevenue = 0,
  });

  factory TopUserModel.fromJson(Map<String, dynamic> j) => TopUserModel(
    userId:       j['userId']       ?? 0,
    userName:     j['userName']     ?? '',
    fullName:     j['fullName']     ?? '',
    orderCount:   j['orderCount']   ?? 0,
    totalRevenue: _d(j['totalRevenue']),
  );
}

// ══════════════════════════════════════════════════════════════════
// MODELS — TIME SERIES & REGION
// ══════════════════════════════════════════════════════════════════

class OrderByTimeModel {
  final String timeBucket;
  final int    orderCount;
  final double revenue;

  const OrderByTimeModel({
    required this.timeBucket,
    this.orderCount = 0,
    this.revenue    = 0,
  });

  factory OrderByTimeModel.fromJson(Map<String, dynamic> j) => OrderByTimeModel(
    timeBucket: j['timeBucket'] ?? '',
    orderCount: j['orderCount'] ?? 0,
    revenue:    _d(j['revenue']),
  );
}

class RegionBreakdownModel {
  final String region;
  final int    orderCount;
  final double revenue;

  const RegionBreakdownModel({
    required this.region,
    this.orderCount = 0,
    this.revenue    = 0,
  });

  factory RegionBreakdownModel.fromJson(Map<String, dynamic> j) => RegionBreakdownModel(
    region:     j['region']     ?? '',
    orderCount: j['orderCount'] ?? 0,
    revenue:    _d(j['revenue']),
  );
}

// ── Recent order ─────────────────────────────────────────────────

class DashboardRecentOrderModel {
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

  const DashboardRecentOrderModel({
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

  factory DashboardRecentOrderModel.fromJson(Map<String, dynamic> j) =>
      DashboardRecentOrderModel(
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

// ══════════════════════════════════════════════════════════════════
// TOP-LEVEL RESPONSE MODEL — RESTAURANT
// ══════════════════════════════════════════════════════════════════

class RestaurantDashboardModel {
  final OrderSummaryModel               orderSummary;
  final RevenueSummaryModel             revenueSummary;
  final CustomerSummaryModel            customerSummary;
  final PaymentBreakdownModel           paymentBreakdown;
  final List<TopProductModel>           topProducts;
  final List<TopIngredientModel>        topIngredients;
  final List<TopCustomerModel>          topCustomers;
  final List<TopUserModel>              topUsers;
  final List<OrderByTimeModel>          ordersByTime;
  final List<RegionBreakdownModel>      regionBreakdown;
  final List<DashboardRecentOrderModel> recentOrders;

  const RestaurantDashboardModel({
    required this.orderSummary,
    required this.revenueSummary,
    required this.customerSummary,
    required this.paymentBreakdown,
    required this.topProducts,
    required this.topIngredients,
    required this.topCustomers,
    required this.topUsers,
    required this.ordersByTime,
    required this.regionBreakdown,
    required this.recentOrders,
  });

  factory RestaurantDashboardModel.fromJson(Map<String, dynamic> j) =>
      RestaurantDashboardModel(
        orderSummary:     OrderSummaryModel.fromJson(_m(j['orderSummary'])),
        revenueSummary:   RevenueSummaryModel.fromJson(_m(j['revenueSummary'])),
        customerSummary:  CustomerSummaryModel.fromJson(_m(j['customerSummary'])),
        paymentBreakdown: PaymentBreakdownModel.fromJson(_m(j['paymentBreakdown'])),
        topProducts:      _list(j['topProducts'],    TopProductModel.fromJson),
        topIngredients:   _list(j['topIngredients'], TopIngredientModel.fromJson),
        topCustomers:     _list(j['topCustomers'],   TopCustomerModel.fromJson),
        topUsers:         _list(j['topUsers'],        TopUserModel.fromJson),
        ordersByTime:     _list(j['ordersByTime'],    OrderByTimeModel.fromJson),
        regionBreakdown:  _list(j['regionBreakdown'], RegionBreakdownModel.fromJson),
        recentOrders:     _list(j['recentOrders'],    DashboardRecentOrderModel.fromJson),
      );
}

// ══════════════════════════════════════════════════════════════════
// SERVICE FUNCTIONS — RESTAURANT
// ══════════════════════════════════════════════════════════════════

const String _dashboardBase = '/api/admin/dashboard';

class DashboardService {
  static Future<ApiResult<RestaurantDashboardModel>> getRestaurantDashboard({
    DashboardPeriod period = DashboardPeriod.days30,
    DateTime? fromDate,
    DateTime? toDate,
    required String mode,
  }) async {
    final params = <String, String>{
      'period': period.apiValue,
      'mode':   mode,
    };

    if (period == DashboardPeriod.custom) {
      if (fromDate != null) params['fromTs'] = fromDate.millisecondsSinceEpoch.toString();
      if (toDate   != null) params['toTs']   = toDate.millisecondsSinceEpoch.toString();
    }

    return ApiHelper.get<RestaurantDashboardModel>(
      '$_dashboardBase/restaurant',
      queryParams: params,
      fromData: (d) => d != null
          ? RestaurantDashboardModel.fromJson(d as Map<String, dynamic>)
          : null,
    );
  }
}

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
  return (raw as List)
      .whereType<Map<String, dynamic>>()
      .map(fromJson)
      .toList();
}

// ══════════════════════════════════════════════════════════════════
// POS DASHBOARD MODELS
// ══════════════════════════════════════════════════════════════════

class PosOrderSummaryModel {
  final int offlineOrders;
  final int shopeeFoodOrders;
  final int grabFoodOrders;
  final int totalOrders;
  final int completedOrders;
  final int cancelledOrders;
  final int pendingOrders;

  // Breakdown source × status (COMPLETED / PENDING, không tính CANCELLED)
  final int offlineOrdersCompleted;
  final int offlineOrdersPending;
  final int shopeeFoodOrdersCompleted;
  final int shopeeFoodOrdersPending;
  final int grabFoodOrdersCompleted;
  final int grabFoodOrdersPending;

  const PosOrderSummaryModel({
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

  factory PosOrderSummaryModel.fromJson(Map<String, dynamic> j) =>
      PosOrderSummaryModel(
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

class PosRevenueSummaryModel {
  final double totalRevenue;
  final double offlineRevenue;
  final double shopeeFoodRevenue;
  final double grabFoodRevenue;

  const PosRevenueSummaryModel({
    this.totalRevenue      = 0,
    this.offlineRevenue    = 0,
    this.shopeeFoodRevenue = 0,
    this.grabFoodRevenue   = 0,
  });

  factory PosRevenueSummaryModel.fromJson(Map<String, dynamic> j) =>
      PosRevenueSummaryModel(
        totalRevenue:      _d(j['totalRevenue']),
        offlineRevenue:    _d(j['offlineRevenue']),
        shopeeFoodRevenue: _d(j['shopeeFoodRevenue']),
        grabFoodRevenue:   _d(j['grabFoodRevenue']),
      );
}

class PosPaymentMethodItem {
  final String method;
  final String label;
  final double amount;
  final int    count;

  const PosPaymentMethodItem({
    required this.method,
    required this.label,
    this.amount = 0,
    this.count  = 0,
  });

  factory PosPaymentMethodItem.fromJson(Map<String, dynamic> j) =>
      PosPaymentMethodItem(
        method: j['method'] ?? '',
        label:  j['label']  ?? j['method'] ?? '',
        amount: _d(j['amount']),
        count:  j['count'] ?? 0,
      );
}

// ── Pie item — dùng cho cả sourcePieItems và categoryPieItems ────

class PosPieItemModel {
  final String key;    // "OFFLINE" / "SHOPEE_FOOD" / "GRAB_FOOD" / "HOT" / "COLD" / "COMBO"
  final String label;  // "Offline" / "ShopeeFood" / "GrabFood" / "Nóng" / "Lạnh" / "Combo"
  final int    count;
  final double amount;

  const PosPieItemModel({
    required this.key,
    required this.label,
    this.count  = 0,
    this.amount = 0,
  });

  factory PosPieItemModel.fromJson(Map<String, dynamic> j) => PosPieItemModel(
    key:    j['key']    ?? '',
    label:  j['label']  ?? '',
    count:  j['count']  ?? 0,
    amount: _d(j['amount']),
  );
}

class PosPaymentBreakdownModel {
  final List<PosPaymentMethodItem> methods;
  // Pie mode 1: đơn hàng theo nguồn (orderSource)
  final List<PosPieItemModel> sourcePieItems;
  // Pie mode 2: đơn hàng theo loại (Nóng / Lạnh / Combo từ categoryName)
  final List<PosPieItemModel> categoryPieItems;

  const PosPaymentBreakdownModel({
    this.methods          = const [],
    this.sourcePieItems   = const [],
    this.categoryPieItems = const [],
  });

  double get totalAmount => methods.fold(0, (s, m) => s + m.amount);
  int    get totalCount  => methods.fold(0, (s, m) => s + m.count);

  factory PosPaymentBreakdownModel.fromJson(Map<String, dynamic> j) {
    final raw    = j['methods'];
    final srcRaw = j['sourcePieItems'];
    final catRaw = j['categoryPieItems'];
    return PosPaymentBreakdownModel(
      methods: raw is List
          ? raw.whereType<Map<String, dynamic>>()
          .map(PosPaymentMethodItem.fromJson)
          .toList()
          : [],
      sourcePieItems: srcRaw is List
          ? srcRaw.whereType<Map<String, dynamic>>()
          .map(PosPieItemModel.fromJson)
          .toList()
          : [],
      categoryPieItems: catRaw is List
          ? catRaw.whereType<Map<String, dynamic>>()
          .map(PosPieItemModel.fromJson)
          .toList()
          : [],
    );
  }
}

class PosTopProductModel {
  final int     productId;
  final String  productName;
  final String? productImageUrl;
  final double  totalQuantity;
  final double  totalRevenue;
  final int     orderCount;

  const PosTopProductModel({
    required this.productId,
    required this.productName,
    this.productImageUrl,
    this.totalQuantity = 0,
    this.totalRevenue  = 0,
    this.orderCount    = 0,
  });

  factory PosTopProductModel.fromJson(Map<String, dynamic> j) => PosTopProductModel(
    productId:       j['productId']      ?? 0,
    productName:     j['productName']    ?? '',
    productImageUrl: j['productImageUrl'],
    totalQuantity:   _d(j['totalQuantity']),
    totalRevenue:    _d(j['totalRevenue']),
    orderCount:      j['orderCount']     ?? 0,
  );
}

class PosOrderByTimeModel {
  final String timeBucket;
  final int    orderCount;
  final double revenue;

  const PosOrderByTimeModel({
    required this.timeBucket,
    this.orderCount = 0,
    this.revenue    = 0,
  });

  factory PosOrderByTimeModel.fromJson(Map<String, dynamic> j) => PosOrderByTimeModel(
    timeBucket: j['timeBucket'] ?? '',
    orderCount: j['orderCount'] ?? 0,
    revenue:    _d(j['revenue']),
  );
}

class PosRecentOrderModel {
  final int     orderId;
  final String  orderCode;
  final String  orderSource; // OFFLINE / SHOPEE_FOOD / GRAB_FOOD
  final int?    createdAt;
  final double  totalAmount;
  final double  finalAmount;
  final String  status;
  final String? paymentMethod;
  final String  paymentStatus;

  const PosRecentOrderModel({
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

  factory PosRecentOrderModel.fromJson(Map<String, dynamic> j) => PosRecentOrderModel(
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

// ── Top-level POS Dashboard Model ────────────────────────────────

class PosDashboardModel {
  final PosOrderSummaryModel     orderSummary;
  final PosRevenueSummaryModel   revenueSummary;
  final PosPaymentBreakdownModel paymentBreakdown;
  final List<PosTopProductModel>  topProducts;
  final List<PosOrderByTimeModel> ordersByTime;
  final List<PosRecentOrderModel> recentOrders;

  const PosDashboardModel({
    required this.orderSummary,
    required this.revenueSummary,
    required this.paymentBreakdown,
    required this.topProducts,
    required this.ordersByTime,
    required this.recentOrders,
  });

  factory PosDashboardModel.fromJson(Map<String, dynamic> j) => PosDashboardModel(
    orderSummary:     PosOrderSummaryModel.fromJson(_m(j['orderSummary'])),
    revenueSummary:   PosRevenueSummaryModel.fromJson(_m(j['revenueSummary'])),
    paymentBreakdown: PosPaymentBreakdownModel.fromJson(_m(j['paymentBreakdown'])),
    topProducts:  _list(j['topProducts'],  PosTopProductModel.fromJson),
    ordersByTime: _list(j['ordersByTime'], PosOrderByTimeModel.fromJson),
    recentOrders: _list(j['recentOrders'], PosRecentOrderModel.fromJson),
  );
}

// ══════════════════════════════════════════════════════════════════
// POS DASHBOARD SERVICE
// ══════════════════════════════════════════════════════════════════

class PosDashboardService {
  static Future<ApiResult<PosDashboardModel>> getPosDashboard({
    DashboardPeriod period = DashboardPeriod.days30,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final params = <String, String>{'period': period.apiValue};

    if (period == DashboardPeriod.custom) {
      if (fromDate != null) params['fromTs'] = fromDate.millisecondsSinceEpoch.toString();
      if (toDate   != null) params['toTs']   = toDate.millisecondsSinceEpoch.toString();
    }

    return ApiHelper.get<PosDashboardModel>(
      '$_dashboardBase/pos',
      queryParams: params,
      fromData: (d) => d != null
          ? PosDashboardModel.fromJson(d as Map<String, dynamic>)
          : null,
    );
  }
}