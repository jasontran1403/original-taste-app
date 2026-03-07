import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'api_helper.dart';

// ══════════════════════════════════════════════════════════════════
// MODELS
// ══════════════════════════════════════════════════════════════════
class ManualImportItem {
  final int ingredientId;
  final double quantity;
  final int? expiryDate; // epoch-millis

  ManualImportItem({
    required this.ingredientId,
    required this.quantity,
    this.expiryDate,
  });

  Map<String, dynamic> toJson() => {
    'ingredientId': ingredientId,
    'quantity': quantity,
    if (expiryDate != null) 'expiryDate': expiryDate,
  };
}

class ManualImportResult {
  final String batchCode;
  final int totalItems;
  final List<ManualImportItemResult> items;

  ManualImportResult({
    required this.batchCode,
    required this.totalItems,
    required this.items,
  });

  factory ManualImportResult.fromJson(Map<String, dynamic> json) =>
      ManualImportResult(
        batchCode: json['batchCode'] ?? '',
        totalItems: json['totalItems'] ?? 0,
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => ManualImportItemResult.fromJson(e))
            .toList(),
      );
}

class ManualImportItemResult {
  final int ingredientId;
  final String ingredientName;
  final String unit;
  final double quantityAdded;
  final double quantityBefore;
  final double quantityAfter;
  final int? effectiveExpiryDate;
  final String logReason;

  ManualImportItemResult({
    required this.ingredientId,
    required this.ingredientName,
    required this.unit,
    required this.quantityAdded,
    required this.quantityBefore,
    required this.quantityAfter,
    this.effectiveExpiryDate,
    required this.logReason,
  });

  factory ManualImportItemResult.fromJson(Map<String, dynamic> json) =>
      ManualImportItemResult(
        ingredientId: json['ingredientId'] ?? 0,
        ingredientName: json['ingredientName'] ?? '',
        unit: json['unit'] ?? '',
        quantityAdded: double.tryParse(json['quantityAdded']?.toString() ?? '0') ?? 0,
        quantityBefore: double.tryParse(json['quantityBefore']?.toString() ?? '0') ?? 0,
        quantityAfter: double.tryParse(json['quantityAfter']?.toString() ?? '0') ?? 0,
        effectiveExpiryDate: json['effectiveExpiryDate'],
        logReason: json['logReason'] ?? '',
      );
}

class PaginatedResponse<T> {
  final List<T> content;
  final int totalPages;
  final int totalElements;
  final int number;
  final int size;

  PaginatedResponse({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.number,
    required this.size,
  });

  factory PaginatedResponse.empty() => PaginatedResponse(
    content: [],
    totalPages: 0,
    totalElements: 0,
    number: 0,
    size: 20,
  );

  bool get hasMore => number + 1 < totalPages;
}

class InventoryLogModel {
  final int? id;
  final String ingredientName;
  final int createdAt;
  final String purpose;
  final double quantity;
  final String status;
  final String? unit;

  InventoryLogModel({
    this.id,
    required this.ingredientName,
    required this.createdAt,
    required this.purpose,
    required this.quantity,
    required this.status,
    this.unit,
  });

  factory InventoryLogModel.fromJson(Map<String, dynamic> json) {
    return InventoryLogModel(
      id: json['id'],
      ingredientName: json['ingredientName'] ?? 'Không xác định',
      createdAt: json['createdAt'] ?? 0,
      purpose: json['purpose'] ?? 'Không rõ',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'Completed',
      unit: json['unit'],
    );
  }
}

class CategoryModel {
  final int id;
  final String name;
  final String? imageUrl;
  final bool isActive;
  final int? createdAt;
  final int? updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    imageUrl: json['imageUrl'],
    isActive: json['isActive'] ?? true,
    createdAt: json['createdAt'],
    updatedAt: json['updatedAt'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    if (imageUrl != null) 'imageUrl': imageUrl,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CategoryModel &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class IngredientModel {
  final int id;
  final String name;
  final String? imageUrl;
  final String unit;
  final double stockQuantity;
  final int? importDate;
  final int? expiryDate;
  final int nearExpiryCount;
  final int? createdAt;
  final int? updatedAt;

  IngredientModel({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.unit,
    required this.stockQuantity,
    this.importDate,
    this.expiryDate,
    this.nearExpiryCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) =>
      IngredientModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        imageUrl: json['imageUrl'],
        unit: json['unit'] ?? '',
        stockQuantity:
        double.tryParse(json['stockQuantity']?.toString() ?? '0') ?? 0,
        importDate: json['importDate'],
        expiryDate: json['expiryDate'],
        nearExpiryCount: json['nearExpiryCount'] ?? 0,
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
      );
}

class ProductVariantModel {
  final int id;
  final String variantName;
  final bool isDefault;
  final List<VariantIngredientItem> ingredients;

  ProductVariantModel({
    required this.id,
    required this.variantName,
    required this.isDefault,
    required this.ingredients,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) =>
      ProductVariantModel(
        id: json['id'] ?? 0,
        variantName: json['variantName'] ?? '',
        isDefault: json['isDefault'] ?? false,
        ingredients:
        (json['ingredients'] as List<dynamic>? ?? [])
            .map((e) => VariantIngredientItem.fromJson(e))
            .toList(),
      );
}

class VariantIngredientItem {
  final int ingredientId;
  final String ingredientName;
  final String? ingredientImageUrl;
  final double quantity;
  final String unit;

  VariantIngredientItem({
    required this.ingredientId,
    required this.ingredientName,
    this.ingredientImageUrl,
    required this.quantity,
    required this.unit,
  });

  factory VariantIngredientItem.fromJson(Map<String, dynamic> json) =>
      VariantIngredientItem(
        ingredientId: json['ingredientId'] ?? 0,
        ingredientName: json['ingredientName'] ?? '',
        ingredientImageUrl: json['ingredientImageUrl'],
        quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
        unit: json['unit'] ?? '',
      );
}

// ─────────────────────────────────────────────────────────────────
// ProductPriceTierModel
// ─────────────────────────────────────────────────────────────────
class ProductPriceTierModel {
  final int id;
  final String tierName;
  final double minQuantity;
  final double? maxQuantity; // null = unlimited
  final double price;
  final int sortOrder;
  final bool isActive;

  const ProductPriceTierModel({
    required this.id,
    required this.tierName,
    required this.minQuantity,
    this.maxQuantity,
    required this.price,
    required this.sortOrder,
    required this.isActive,
  });

  factory ProductPriceTierModel.fromJson(Map<String, dynamic> json) =>
      ProductPriceTierModel(
        id: json['id'] ?? 0,
        tierName: json['tierName'] ?? '',
        minQuantity:
        double.tryParse(json['minQuantity']?.toString() ?? '0') ?? 0,
        maxQuantity: json['maxQuantity'] != null
            ? double.tryParse(json['maxQuantity'].toString())
            : null,
        price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
        sortOrder: json['sortOrder'] ?? 0,
        isActive: json['isActive'] ?? true,
      );

  Map<String, dynamic> toJson() => {
    'tierName': tierName,
    'minQuantity': minQuantity,
    if (maxQuantity != null) 'maxQuantity': maxQuantity,
    'price': price,
    'sortOrder': sortOrder,
  };

  /// "0 – <10" hoặc "≥ 20"
  String get rangeLabel {
    final mn = _fq(minQuantity);
    if (maxQuantity == null) return '≥ $mn';
    return '$mn – <${_fq(maxQuantity!)}';
  }

  String _fq(double q) =>
      q == q.truncateToDouble() ? q.toInt().toString() : q.toString();
}

// ─────────────────────────────────────────────────────────────────
// ProductModel  (basePrice + priceTiers, không còn prices)
// ─────────────────────────────────────────────────────────────────
class ProductModel {
  final int id;
  final String name;
  final String? description;
  final String? unit;
  final String? imageUrl;
  final int? categoryId;
  final String? categoryName;
  final double basePrice;
  final List<ProductPriceTierModel> priceTiers;
  final List<ProductVariantModel> variants;
  final int vatRate;
  final int? createdAt;
  final int? updatedAt;

  const ProductModel({
    required this.id,
    required this.name,
    this.description,
    this.unit,
    this.imageUrl,
    this.categoryId,
    this.categoryName,
    required this.basePrice,
    required this.priceTiers,
    required this.variants,
    this.vatRate = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    description: json['description'],
    unit: json['unit'],
    imageUrl: json['imageUrl'],
    categoryId: json['categoryId'],
    categoryName: json['categoryName'] ?? json['category'],
    basePrice:
    double.tryParse(json['basePrice']?.toString() ?? '0') ?? 0,
    priceTiers: (() {
      // Backend có thể trả 'priceTiers' hoặc 'tiers' tùy version
      final raw = (json['priceTiers'] as List<dynamic>?)
          ?? (json['tiers'] as List<dynamic>?)
          ?? [];
      return raw
          .map((e) => ProductPriceTierModel.fromJson(e))
          .where((t) => t.isActive)
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    })(),
    variants: (json['variants'] as List<dynamic>? ?? [])
        .map((e) => ProductVariantModel.fromJson(e))
        .toList(),
    vatRate: json['vatRate'] ?? 0,
    createdAt: json['createdAt'],
    updatedAt: json['updatedAt'],
  );

  /// Tier phù hợp với qty (auto-detect)
  ProductPriceTierModel? tierForQty(double qty) {
    ProductPriceTierModel? best;
    for (final t in priceTiers) {
      if (qty >= t.minQuantity) {
        final max = t.maxQuantity;
        if (max == null || qty < max) best = t;
      }
    }
    return best;
  }

  /// Tier đầu tiên (default khi chế độ Sỉ)
  ProductPriceTierModel? get firstTier =>
      priceTiers.isNotEmpty ? priceTiers.first : null;
}

// ─────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────
enum OrderMode {
  retail,
  wholesale;

  String get label => this == retail ? 'Khách lẻ' : 'Khách sỉ';
}

enum ItemPriceMode {
  base,
  tier,
  discountPercent;

  String get apiValue => switch (this) {
    base            => 'BASE',
    tier            => 'TIER',
    discountPercent => 'DISCOUNT_PERCENT',
  };

  static ItemPriceMode fromApi(String? v) => switch (v?.toUpperCase()) {
    'TIER'             => tier,
    'DISCOUNT_PERCENT' => discountPercent,
    _                  => base,
  };
}

// ─────────────────────────────────────────────────────────────────
// SelectedCustomer
// ─────────────────────────────────────────────────────────────────
class SelectedCustomer {
  final int? id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final int discountRate;

  SelectedCustomer({
    this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.address = '',
    this.discountRate = 0,
  });
}

// ─────────────────────────────────────────────────────────────────
// CartItem
// ─────────────────────────────────────────────────────────────────
class CartItem {
  final ProductModel product;
  final ProductVariantModel? variant;
  final TextEditingController qtyController;
  double quantity;

  ItemPriceMode priceMode;
  ProductPriceTierModel? selectedTier;
  int? discountPercent;

  CartItem({
    required this.product,
    this.variant,
    required this.quantity,
    required OrderMode orderMode,
  })  : qtyController = TextEditingController(text: _fmtQ(quantity)),
        priceMode = ItemPriceMode.tier,
        selectedTier = null,
        discountPercent = null;

  void resetToMode(OrderMode mode) {
    priceMode = ItemPriceMode.tier;
    selectedTier = null;
    discountPercent = null;
  }

  double baseForDiscount(OrderMode orderMode) {
    if (orderMode == OrderMode.retail) return product.basePrice;
    return product.firstTier?.price ?? product.basePrice;
  }

  double get unitPrice {
    switch (priceMode) {
      case ItemPriceMode.base:
        return product.basePrice;
      case ItemPriceMode.discountPercent:
        final pct = discountPercent ?? 0;
        return product.basePrice * (100 - pct) / 100;
      case ItemPriceMode.tier:
        final tier = selectedTier ?? product.tierForQty(quantity);
        return tier?.price ?? product.basePrice;
    }
  }

  ProductPriceTierModel? get activeTier {
    if (priceMode != ItemPriceMode.tier) return null;
    return selectedTier ?? product.tierForQty(quantity);
  }

  double get subtotal => unitPrice * quantity;

  double get vatAmount => subtotal * product.vatRate / 100;

  static String _fmtQ(double q) =>
      q == q.truncateToDouble() ? q.toInt().toString() : q.toStringAsFixed(2);

  void dispose() => qtyController.dispose();
}

// ─────────────────────────────────────────────────────────────────
// Customer models
// ─────────────────────────────────────────────────────────────────
class CustomerAddressModel {
  final int? id;
  final String address;
  final bool isDefault;

  CustomerAddressModel({
    this.id,
    required this.address,
    required this.isDefault,
  });

  factory CustomerAddressModel.fromJson(Map<String, dynamic> json) =>
      CustomerAddressModel(
        id: json['id'],
        address: json['address'] ?? '',
        isDefault: json['isDefault'] ?? false,
      );

  Map<String, dynamic> toJson() =>
      {'address': address, 'isDefault': isDefault};
}

class CustomerModel {
  final int id;
  final String phone;
  final String? name;
  final String? email;
  final int discountRate;
  final bool isActive;
  final List<CustomerAddressModel> addresses;
  final int? createdAt;
  final int? updatedAt;

  CustomerModel({
    required this.id,
    required this.phone,
    this.name,
    this.email,
    required this.discountRate,
    required this.isActive,
    required this.addresses,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
    id: json['id'] ?? 0,
    phone: json['phone'] ?? '',
    name: json['name'],
    email: json['email'],
    discountRate: json['discountRate'] ?? 0,
    isActive: json['isActive'] ?? true,
    addresses: (json['addresses'] as List<dynamic>? ?? [])
        .map((e) => CustomerAddressModel.fromJson(e))
        .toList(),
    createdAt: json['createdAt'],
    updatedAt: json['updatedAt'],
  );

  CustomerAddressModel? get defaultAddress =>
      addresses.where((a) => a.isDefault).firstOrNull ?? addresses.firstOrNull;
}

// ─────────────────────────────────────────────────────────────────
// Order item ingredient
// ─────────────────────────────────────────────────────────────────
class OrderItemIngredientModel {
  final int ingredientId;
  final String ingredientName;
  final String? ingredientImageUrl;
  final double quantityUsed;
  final String unit;

  OrderItemIngredientModel({
    required this.ingredientId,
    required this.ingredientName,
    this.ingredientImageUrl,
    required this.quantityUsed,
    required this.unit,
  });

  factory OrderItemIngredientModel.fromJson(Map<String, dynamic> json) =>
      OrderItemIngredientModel(
        ingredientId: json['ingredientId'] ?? 0,
        ingredientName: json['ingredientName'] ?? '',
        ingredientImageUrl: json['ingredientImageUrl'],
        quantityUsed:
        double.tryParse(json['quantityUsed']?.toString() ?? '0') ?? 0,
        unit: json['unit'] ?? '',
      );
}

// ─────────────────────────────────────────────────────────────────
// OrderItemModel  (basePrice/priceMode/tier thay priceName/defaultPrice)
// ─────────────────────────────────────────────────────────────────
class OrderItemModel {
  final int id;
  final int productId;
  final String productName;
  final String? productImageUrl;
  final int? variantId;
  final String? variantName;
  final double basePrice;
  final double unitPrice;
  final String priceMode;       // BASE | TIER | DISCOUNT_PERCENT
  final int? tierId;
  final String? tierName;
  final int? discountPercent;
  final int vatRate;
  final double vatAmount;
  final double quantity;
  final double subtotal;
  final String? unit;
  final String? notes;
  final List<OrderItemIngredientModel> ingredientsUsed;

  const OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImageUrl,
    this.variantId,
    this.variantName,
    required this.basePrice,
    required this.unitPrice,
    required this.priceMode,
    this.tierId,
    this.tierName,
    this.discountPercent,
    this.vatRate = 0,
    this.vatAmount = 0,
    required this.quantity,
    required this.subtotal,
    this.unit,
    this.notes,
    required this.ingredientsUsed,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
    id: json['id'] ?? 0,
    productId: json['productId'] ?? 0,
    productName: json['productName'] ?? '',
    productImageUrl: json['productImageUrl'],
    variantId: json['variantId'],
    variantName: json['variantName'],
    basePrice:
    double.tryParse(json['basePrice']?.toString() ?? '0') ?? 0,
    unitPrice:
    double.tryParse(json['unitPrice']?.toString() ?? '0') ?? 0,
    priceMode: json['priceMode'] ?? 'BASE',
    tierId: json['tierId'],
    tierName: json['tierName'],
    discountPercent: json['discountPercent'],
    vatRate: json['vatRate'] ?? 0,
    vatAmount:
    double.tryParse(json['vatAmount']?.toString() ?? '0') ?? 0,
    quantity:
    double.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
    subtotal:
    double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
    unit: json['unit'],
    notes: json['notes'],
    ingredientsUsed: (json['ingredientsUsed'] as List<dynamic>? ?? [])
        .map((e) => OrderItemIngredientModel.fromJson(e))
        .toList(),
  );

  /// Label hiển thị chế độ giá (dùng ở order_detail_screen)
  String get priceModeLabel => switch (priceMode) {
    'TIER'             => tierName != null ? 'Khung: $tierName' : 'Giá khung',
    'DISCOUNT_PERCENT' =>
    discountPercent != null ? 'Giảm $discountPercent%' : 'Giảm giá',
    _                  => 'Giá gốc',
  };

  /// Alias backward-compat — order_detail_screen dùng item.priceName
  String get priceName => priceModeLabel;
}

// ─────────────────────────────────────────────────────────────────
// OrderModel
// ─────────────────────────────────────────────────────────────────
class OrderModel {
  final int id;
  final String orderCode;
  final String? customerName;
  final String? customerPhone;
  final String? shippingAddress;
  final double totalAmount;
  final double discountAmount;
  final double finalAmount;
  final double vatAmount;
  final String status;
  final String paymentStatus;
  final String? paymentMethod;
  final String? notes;
  final int? createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.orderCode,
    this.customerName,
    this.customerPhone,
    this.shippingAddress,
    required this.totalAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod,
    this.notes,
    this.createdAt,
    required this.items,
    this.vatAmount = 0,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id'] ?? 0,
    orderCode: json['orderCode'] ?? '',
    customerName: json['customerName'],
    customerPhone: json['customerPhone'],
    shippingAddress: json['shippingAddress'],
    totalAmount:
    double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0,
    discountAmount:
    double.tryParse(json['discountAmount']?.toString() ?? '0') ?? 0,
    finalAmount:
    double.tryParse(json['finalAmount']?.toString() ?? '0') ?? 0,
    status: json['status'] ?? '',
    paymentStatus: json['paymentStatus'] ?? '',
    paymentMethod: json['paymentMethod'],
    notes: json['notes'],
    createdAt: json['createdAt'],
    vatAmount:
    double.tryParse(json['vatAmount']?.toString() ?? '0') ?? 0,
    items: (json['items'] as List<dynamic>? ?? [])
        .map((e) => OrderItemModel.fromJson(e))
        .toList(),
  );
}

// ─────────────────────────────────────────────────────────────────
// Request models
// ─────────────────────────────────────────────────────────────────
class CreateOrderItemRequest {
  final int productId;
  final int? variantId;
  final double quantity;
  final String priceMode;
  final int? tierId;
  final int? discountPercent;
  final String? notes;

  CreateOrderItemRequest({
    required this.productId,
    this.variantId,
    required this.quantity,
    required this.priceMode,
    this.tierId,
    this.discountPercent,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'productId': productId,
    if (variantId != null) 'variantId': variantId,
    'quantity': quantity,
    'priceMode': priceMode,
    if (tierId != null) 'tierId': tierId,
    if (discountPercent != null) 'discountPercent': discountPercent,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };
}

class CreateOrderRequest {
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String? shippingAddress;
  final String paymentMethod;
  final String? notes;
  final String? type;
  final List<CreateOrderItemRequest> items;

  CreateOrderRequest({
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.shippingAddress,
    this.type,
    required this.paymentMethod,
    this.notes,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    if (customerName != null) 'customerName': customerName,
    if (customerPhone != null) 'customerPhone': customerPhone,
    if (customerEmail != null) 'customerEmail': customerEmail,
    if (shippingAddress != null) 'shippingAddress': shippingAddress,
    'type': type,
    'paymentMethod': paymentMethod,
    if (notes != null) 'notes': notes,
    'items': items.map((e) => e.toJson()).toList(),
  };
}

// ══════════════════════════════════════════════════════════════════
// SELLER SERVICE
// ══════════════════════════════════════════════════════════════════
class SellerService {
  // ── BASE URL image helper ──────────────────────────────────────
  static String buildImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '${ApiHelper.baseUrl}/api/auth$path';
  }

  static Future<ApiResult<String>> generateAndSendInvoice(int orderId) async {
    return ApiHelper.get<String>(
      '/api/seller/orders/$orderId/invoice',
      requireAuth: true,
      fromData: (data) {
        if (data is Map<String, dynamic>) {
          return data['message']?.toString() ??
              'Đã tạo và gửi hóa đơn thành công qua Telegram';
        }
        return data?.toString() ?? 'Thành công';
      },
    );
  }

  // ════════════════════════════════════════
  // CATEGORY
  // ════════════════════════════════════════

  static Future<ApiResult<List<CategoryModel>>> getCategories() async {
    return ApiHelper.get<List<CategoryModel>>(
      '/api/seller/categories',
      fromData: (data) {
        if (data is List) {
          return data.map((e) => CategoryModel.fromJson(e)).toList();
        }
        return [];
      },
    );
  }

  static Future<ApiResult<PaginatedResponse<InventoryLogModel>>>
  getInventoryLogs({
    required int page,
    required int size,
    int? ingredientId,
  }) async {
    final params = {
      'page': page.toString(),
      'size': size.toString(),
      if (ingredientId != null) 'ingredientId': ingredientId.toString(),
    };

    return ApiHelper.get<PaginatedResponse<InventoryLogModel>>(
      '/api/seller/inventory/logs',
      queryParams: params,
      fromData: (data) {
        if (data is Map<String, dynamic>) {
          final content = (data['content'] as List<dynamic>? ?? [])
              .map((e) => InventoryLogModel.fromJson(e))
              .toList();
          return PaginatedResponse<InventoryLogModel>(
            content: content,
            totalPages: data['totalPages'] ?? 1,
            totalElements: data['totalElements'] ?? 0,
            number: data['number'] ?? 0,
            size: data['size'] ?? 20,
          );
        }
        return PaginatedResponse<InventoryLogModel>.empty();
      },
    );
  }

  static Future<ApiResult<CategoryModel>> getCategoryById(int id) async {
    return ApiHelper.get<CategoryModel>(
      '/api/seller/categories/$id',
      fromData: (data) => data != null ? CategoryModel.fromJson(data) : null,
    );
  }

  static Future<ApiResult<String>> uploadCategoryImage(String filePath) async {
    return ApiHelper.uploadFile<String>(
      '/api/seller/categories/upload-image',
      filePath: filePath,
      fieldName: 'file',
      fromData: (data) => data?.toString(),
    );
  }

  static Future<ApiResult<CategoryModel>> createCategory({
    required String name,
    String? imageUrl,
  }) async {
    return ApiHelper.post<CategoryModel>(
      '/api/seller/categories',
      body: {'name': name, if (imageUrl != null) 'imageUrl': imageUrl},
      fromData: (data) => data != null ? CategoryModel.fromJson(data) : null,
    );
  }

  static Future<ApiResult<CategoryModel>> updateCategory({
    required int id,
    required String name,
    String? imageUrl,
  }) async {
    return ApiHelper.put<CategoryModel>(
      '/api/seller/categories/$id',
      body: {'name': name, if (imageUrl != null) 'imageUrl': imageUrl},
      fromData: (data) => data != null ? CategoryModel.fromJson(data) : null,
    );
  }

  static Future<ApiResult<dynamic>> deleteCategory(int id) async {
    return ApiHelper.delete<dynamic>('/api/seller/categories/$id');
  }

  // ════════════════════════════════════════
  // INGREDIENT
  // ════════════════════════════════════════

  static Future<ApiResult<List<IngredientModel>>> getIngredients({
    int page = 0,
    int size = 10,
  }) async {
    return ApiHelper.get<List<IngredientModel>>(
      '/api/seller/ingredients',
      queryParams: {'page': page.toString(), 'size': size.toString()},
      fromData: (data) {
        if (data is List) {
          return data.map((e) => IngredientModel.fromJson(e)).toList();
        }
        if (data is Map && data['content'] is List) {
          return (data['content'] as List)
              .map((e) => IngredientModel.fromJson(e))
              .toList();
        }
        return [];
      },
    );
  }

  static Future<ApiResult<IngredientModel>> getIngredientById(int id) async {
    return ApiHelper.get<IngredientModel>(
      '/api/seller/ingredients/$id',
      fromData: (data) => data != null ? IngredientModel.fromJson(data) : null,
    );
  }

  static Future<ApiResult<IngredientModel>> createIngredient({
    required String name,
    required String unit,
    required double stockQuantity,
    String? imageUrl,
    int? importDate,
    int? expiryDate,
  }) async {
    return ApiHelper.post<IngredientModel>(
      '/api/seller/ingredients',
      body: {
        'name': name,
        'unit': unit,
        'stockQuantity': stockQuantity,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (importDate != null) 'importDate': importDate,
        if (expiryDate != null) 'expiryDate': expiryDate,
      },
      fromData: (data) => data != null ? IngredientModel.fromJson(data) : null,
    );
  }

  static Future<ApiResult<IngredientModel>> updateIngredient({
    required int id,
    required String name,
    required String unit,
    required double stockQuantity,
    String? imageUrl,
    int? importDate,
    int? expiryDate,
  }) async {
    return ApiHelper.put<IngredientModel>(
      '/api/seller/ingredients/$id',
      body: {
        'name': name,
        'unit': unit,
        'stockQuantity': stockQuantity,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (importDate != null) 'importDate': importDate,
        if (expiryDate != null) 'expiryDate': expiryDate,
      },
      fromData: (data) => data != null ? IngredientModel.fromJson(data) : null,
    );
  }

  static Future<ApiResult<dynamic>> deleteIngredient(int id) async {
    return ApiHelper.delete<dynamic>('/api/seller/ingredients/$id');
  }

  // ════════════════════════════════════════
  // PRODUCT
  // ════════════════════════════════════════

  static Future<ApiResult<List<ProductModel>>> getProducts({
    int page = 0,
    int size = 50,
    int? categoryId,
  }) async {
    return ApiHelper.get<List<ProductModel>>(
      '/api/seller/products',
      queryParams: {
        'page': page.toString(),
        'size': size.toString(),
        if (categoryId != null) 'categoryId': categoryId.toString(),
      },
      fromData: (data) {
        if (data is Map && data['content'] is List) {
          return (data['content'] as List)
              .map((e) => ProductModel.fromJson(e))
              .toList();
        }
        if (data is List) {
          return data.map((e) => ProductModel.fromJson(e)).toList();
        }
        return [];
      },
    );
  }

  static Future<ApiResult<ProductModel>> getProductById(int id) async {
    return ApiHelper.get<ProductModel>(
      '/api/seller/products/$id',
      fromData: (data) => data != null ? ProductModel.fromJson(data) : null,
    );
  }

  static Future<ApiResult<String>> uploadProductImage(String filePath) async {
    return ApiHelper.uploadFile<String>(
      '/api/upload/product-image',
      filePath: filePath,
      fieldName: 'image',
      fromData: (data) {
        if (data is Map) return data['imageUrl']?.toString();
        return data?.toString();
      },
    );
  }

  /// Tạo sản phẩm mới với basePrice + tiers (thay thế prices cũ)
  static Future<ApiResult<ProductModel>> createProduct({
    required String name,
    String? description,
    String? unit,
    String? imageUrl,
    int? categoryId,
    String? categoryName,
    required double basePrice,
    required int vatRate,
    List<Map<String, dynamic>>? tiers,
    List<Map<String, dynamic>>? ingredients,
  }) async {
    return ApiHelper.post<ProductModel>(
      '/api/seller/products',
      body: {
        'name': name,
        if (description != null) 'description': description,
        if (unit != null) 'unit': unit,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (categoryId != null) 'categoryId': categoryId,
        if (categoryName != null) 'category': categoryName,
        'basePrice': basePrice,
        'vatRate': vatRate,
        if (tiers != null && tiers.isNotEmpty) 'tiers': tiers,
        if (ingredients != null && ingredients.isNotEmpty)
          'ingredients': ingredients,
      },
      fromData: (data) => data != null ? ProductModel.fromJson(data) : null,
    );
  }

  /// Cập nhật sản phẩm với basePrice + tiers
  static Future<ApiResult<ProductModel>> updateProduct({
    required int id,
    required String name,
    String? description,
    String? unit,
    String? imageUrl,
    int? categoryId,
    String? categoryName,
    required double basePrice,
    required int vatRate,
    List<Map<String, dynamic>>? tiers,
    List<Map<String, dynamic>>? ingredients,
  }) async {
    return ApiHelper.put<ProductModel>(
      '/api/seller/products/$id',
      body: {
        'name': name,
        if (description != null) 'description': description,
        if (unit != null) 'unit': unit,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (categoryId != null) 'categoryId': categoryId,
        if (categoryName != null) 'category': categoryName,
        'basePrice': basePrice,
        'vatRate': vatRate,
        if (tiers != null) 'tiers': tiers,
        if (ingredients != null && ingredients.isNotEmpty)
          'ingredients': ingredients,
      },
      fromData: (data) => data != null ? ProductModel.fromJson(data) : null,
    );
  }

  static Future<ApiResult<dynamic>> deleteProduct(int id) async {
    return ApiHelper.delete<dynamic>('/api/seller/products/$id');
  }

  // ── Tier CRUD ─────────────────────────────────────────────────
  static Future<ApiResult<ProductModel>> addProductTier(
      int productId, Map<String, dynamic> tierData) async {
    return ApiHelper.post<ProductModel>(
      '/api/seller/products/$productId/tiers',
      body: tierData,
      fromData: (data) => data != null ? ProductModel.fromJson(data) : null,
    );
  }

  static Future<ApiResult<ProductModel>> updateProductTier(
      int productId, int tierId, Map<String, dynamic> tierData) async {
    return ApiHelper.put<ProductModel>(
      '/api/seller/products/$productId/tiers/$tierId',
      body: tierData,
      fromData: (data) => data != null ? ProductModel.fromJson(data) : null,
    );
  }

  static Future<ApiResult<ProductModel>> deleteProductTier(
      int productId, int tierId) async {
    return ApiHelper.delete<ProductModel>(
      '/api/seller/products/$productId/tiers/$tierId',
      fromData: (data) => data != null ? ProductModel.fromJson(data) : null,
    );
  }

  // ════════════════════════════════════════
  // ORDER
  // ════════════════════════════════════════

  static Future<ApiResult<List<OrderModel>>> getMyOrders() async {
    return ApiHelper.get<List<OrderModel>>(
      '/api/seller/orders',
      fromData: (data) {
        if (data is List) {
          return data.map((e) => OrderModel.fromJson(e)).toList();
        }
        return [];
      },
    );
  }

  static Future<ApiResult<OrderModel>> getOrderById(int id) async {
    return ApiHelper.get<OrderModel>(
      '/api/seller/orders/$id',
      fromData: (data) => data != null ? OrderModel.fromJson(data) : null,
    );
  }

  static Future<ApiResult<OrderModel>> createOrder(
      CreateOrderRequest request) async {
    return ApiHelper.post<OrderModel>(
      '/api/seller/orders',
      body: request.toJson(),
      fromData: (data) => data != null ? OrderModel.fromJson(data) : null,
    );
  }

  static Future<ApiResult<OrderModel>> cancelOrder(int orderId) async {
    return ApiHelper.post<OrderModel>(
      '/api/seller/orders/$orderId/cancel',
      body: {},
      fromData: (data) => data != null ? OrderModel.fromJson(data) : null,
    );
  }

  // ════════════════════════════════════════
  // CUSTOMER
  // ════════════════════════════════════════

  static Future<ApiResult<List<CustomerModel>>> getCustomers() async {
    return ApiHelper.get<List<CustomerModel>>(
      '/api/seller/customers',
      fromData: (data) {
        if (data is List) {
          return data.map((e) => CustomerModel.fromJson(e)).toList();
        }
        return [];
      },
    );
  }

  static Future<ApiResult<CustomerModel?>> getCustomerByPhone(
      String phone) async {
    return ApiHelper.get<CustomerModel?>(
      '/api/seller/customers/phone/$phone',
      fromData: (data) => data != null ? CustomerModel.fromJson(data) : null,
    );
  }

  static Future<ApiResult<CustomerModel>> createCustomer({
    required String phone,
    String? name,
    String? email,
    int discountRate = 0,
    List<Map<String, dynamic>>? addresses,
  }) async {
    return ApiHelper.post<CustomerModel>(
      '/api/seller/customers',
      body: {
        'phone': phone,
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        'discountRate': discountRate,
        if (addresses != null) 'addresses': addresses,
      },
      fromData: (data) => data != null ? CustomerModel.fromJson(data) : null,
    );
  }

  static Future<ApiResult<CustomerModel>> updateCustomer({
    required int id,
    required String phone,
    String? name,
    String? email,
    int discountRate = 0,
    List<Map<String, dynamic>>? addresses,
  }) async {
    return ApiHelper.put<CustomerModel>(
      '/api/seller/customers/$id',
      body: {
        'phone': phone,
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        'discountRate': discountRate,
        if (addresses != null) 'addresses': addresses,
      },
      fromData: (data) => data != null ? CustomerModel.fromJson(data) : null,
    );
  }

  static Future<ApiResult<dynamic>> deleteCustomer(int id) async {
    return ApiHelper.delete<dynamic>('/api/seller/customers/$id');
  }

  static Future<ApiResult<ManualImportResult>> manualImportIngredients(
      List<ManualImportItem> items) async {
    return ApiHelper.post<ManualImportResult>(
      '/api/seller/ingredients/import',
      body: {'items': items.map((e) => e.toJson()).toList()},
      fromData: (data) =>
      data != null ? ManualImportResult.fromJson(data) : null,
    );
  }
}