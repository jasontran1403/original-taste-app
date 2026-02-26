// lib/helper/services/pos_service.dart

import 'package:original_taste/helper/services/api_helper.dart';

// ════════════════════════════════════════
// MODELS
// ════════════════════════════════════════

class PosCategoryModel {
  final int id;
  final String name;
  final String? imageUrl;
  final int displayOrder;
  final bool isActive;
  final bool singlePrice;
  final int productCount;

  const PosCategoryModel({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.displayOrder,
    required this.isActive,
    required this.singlePrice,
    required this.productCount,
  });

  factory PosCategoryModel.fromJson(Map<String, dynamic> json) =>
      PosCategoryModel(
        id: json['id'],
        name: json['name'],
        imageUrl: json['imageUrl'],
        displayOrder: json['displayOrder'] ?? 0,
        isActive: json['isActive'] ?? true,
        singlePrice: json['singlePrice'] ?? false,
        productCount: json['productCount'] ?? 0,
      );
}

class PriceOption {
  final int discountPercent;
  final double price;
  final String label;

  const PriceOption({
    required this.discountPercent,
    required this.price,
    required this.label,
  });

  factory PriceOption.fromJson(Map<String, dynamic> json) => PriceOption(
    discountPercent: json['discountPercent'],
    price: (json['price'] as num).toDouble(),
    label: json['label'],
  );
}

class PosVariantIngredientModel {
  final int id;
  final int ingredientId;
  final String ingredientName;
  final String? ingredientImageUrl;
  final double stockDeductPerUnit;
  final int? maxSelectableCount;
  final String? subGroupTag;
  final int? subGroupMaxSelect;
  final int displayOrder;
  final double addonPrice;

  const PosVariantIngredientModel({
    required this.id,
    required this.ingredientId,
    required this.ingredientName,
    this.ingredientImageUrl,
    required this.stockDeductPerUnit,
    this.maxSelectableCount,
    this.subGroupTag,
    this.subGroupMaxSelect,
    required this.displayOrder,
    this.addonPrice = 0,
  });

  factory PosVariantIngredientModel.fromJson(Map<String, dynamic> json) =>
      PosVariantIngredientModel(
        id:                 json['id'] as int,
        ingredientId:       json['ingredientId'] as int,
        ingredientName:     json['ingredientName'] as String,
        ingredientImageUrl: json['ingredientImageUrl'] as String?,
        stockDeductPerUnit: (json['stockDeductPerUnit'] as num?)?.toDouble() ?? 1.0,
        maxSelectableCount: json['maxSelectableCount'] as int?,
        subGroupTag:        json['subGroupTag'] as String?,
        subGroupMaxSelect:  json['subGroupMaxSelect'] as int?,
        displayOrder:       json['displayOrder'] as int? ?? 0,
        addonPrice:         (json['addonPrice'] as num?)?.toDouble() ?? 0.0,
      );
}

class PosVariantModel {
  final int id;
  final String groupName;
  final int minSelect;
  final int maxSelect;
  final bool allowRepeat;
  final int displayOrder;
  final bool isActive;
  final bool isAddonGroup;
  final bool isDefault;
  final List<PosVariantIngredientModel> ingredients;

  const PosVariantModel({
    required this.id,
    required this.groupName,
    required this.minSelect,
    required this.maxSelect,
    required this.allowRepeat,
    required this.displayOrder,
    required this.isActive,
    this.isAddonGroup = false,
    this.isDefault = false,
    required this.ingredients,
  });

  factory PosVariantModel.fromJson(Map<String, dynamic> json) => PosVariantModel(
    id:           json['id'] as int,
    groupName:    json['groupName'] as String,
    minSelect:    json['minSelect'] as int,
    maxSelect:    json['maxSelect'] as int,
    allowRepeat:  json['allowRepeat'] as bool? ?? true,
    displayOrder: json['displayOrder'] as int? ?? 0,
    isActive:     json['isActive'] as bool? ?? true,
    isAddonGroup: json['isAddonGroup'] as bool? ?? false,
    isDefault:    json['isDefault'] as bool? ?? false,
    ingredients:  (json['ingredients'] as List<dynamic>? ?? [])
        .map((e) => PosVariantIngredientModel.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class PosAppMenuModel {
  final int id;
  final String platform; // SHOPEE_FOOD | GRAB_FOOD
  final double price;
  final bool isActive;

  const PosAppMenuModel({
    required this.id,
    required this.platform,
    required this.price,
    required this.isActive,
  });

  factory PosAppMenuModel.fromJson(Map<String, dynamic> json) =>
      PosAppMenuModel(
        id:       json['id'],
        platform: json['platform'],
        price:    (json['price'] as num).toDouble(),
        isActive: json['isActive'] ?? true,
      );
}

class PosProductModel {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final bool isActive;
  final int categoryId;
  final String categoryName;
  final bool singlePrice;
  final double basePrice;
  final int displayOrder;
  final List<PriceOption> priceOptions;
  final List<PosVariantModel> variants;
  final bool hasVariants;
  final List<PosAppMenuModel> appMenus;
  final int vatPercent;
  final bool isShopeeFood;
  final bool isGrabFood;

  const PosProductModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.isActive,
    required this.categoryId,
    required this.categoryName,
    required this.singlePrice,
    required this.basePrice,
    this.displayOrder = 0,
    required this.priceOptions,
    required this.variants,
    required this.hasVariants,
    required this.appMenus,
    this.vatPercent = 0,
    this.isShopeeFood = false,
    this.isGrabFood = false,
  });

  factory PosProductModel.fromJson(Map<String, dynamic> json) =>
      PosProductModel(
        id:           json['id'],
        name:         json['name'],
        description:  json['description'],
        imageUrl:     json['imageUrl'],
        isActive:     json['isActive'] ?? true,
        categoryId:   json['categoryId'],
        categoryName: json['categoryName'],
        singlePrice:  json['singlePrice'] ?? false,
        basePrice:    (json['basePrice'] as num).toDouble(),
        displayOrder: json['displayOrder'] ?? 0,
        priceOptions: (json['priceOptions'] as List<dynamic>? ?? [])
            .map((e) => PriceOption.fromJson(e))
            .toList(),
        variants: (json['variants'] as List<dynamic>? ?? [])
            .map((e) => PosVariantModel.fromJson(e))
            .toList(),
        hasVariants:  json['hasVariants'] ?? false,
        appMenus: (json['appMenus'] as List<dynamic>? ?? [])
            .map((e) => PosAppMenuModel.fromJson(e))
            .toList(),
        vatPercent:   json['vatPercent'] as int? ?? 0,
        isShopeeFood: json['isShopeeFood'] as bool? ?? false,
        isGrabFood:   json['isGrabFood'] as bool? ?? false,
      );

  PosProductModel copyWithOrder(int order) => PosProductModel(
    id: id, name: name, description: description, imageUrl: imageUrl,
    isActive: isActive, categoryId: categoryId, categoryName: categoryName,
    singlePrice: singlePrice, basePrice: basePrice, displayOrder: order,
    priceOptions: priceOptions, variants: variants, hasVariants: hasVariants,
    appMenus: appMenus, vatPercent: vatPercent,
    isShopeeFood: isShopeeFood, isGrabFood: isGrabFood,
  );
}

// ════════════════════════════════════════
// ADDON ITEM — snapshot giá khi đặt hàng
// ════════════════════════════════════════

/// Lưu thông tin addon tại thời điểm đặt hàng (snapshot).
/// discountedAddonPrice = baseAddonPrice × (1 - discountPercent/100)
class AddonItem {
  final int ingredientId;
  final String ingredientName;
  final double baseAddonPrice;        // giá gốc trước discount
  final double discountedAddonPrice;  // giá sau áp discount của priceOption
  final int quantity;

  const AddonItem({
    required this.ingredientId,
    required this.ingredientName,
    required this.baseAddonPrice,
    required this.discountedAddonPrice,
    required this.quantity,
  });

  /// Tổng tiền addon item này (đã discount × số lượng)
  double get subtotal => discountedAddonPrice * quantity;
}

// ════════════════════════════════════════
// CART MODELS
// ════════════════════════════════════════

class VariantGroupSelection {
  final int variantId;
  final String groupName;
  final bool isAddonGroup;               // true = addon group, false = regular variant
  final Map<int, int> selectedIngredients; // ingredientId → count
  final List<AddonItem>? addonItems;     // populated khi isAddonGroup=true, chứa snapshot giá

  const VariantGroupSelection({
    required this.variantId,
    required this.groupName,
    this.isAddonGroup = false,
    required this.selectedIngredients,
    this.addonItems,
  });
}

class CartItem {
  final PosProductModel product;
  final PriceOption selectedPrice;
  final List<VariantGroupSelection> variantSelections;
  final int quantity;
  final String? note;

  const CartItem({
    required this.product,
    required this.selectedPrice,
    this.variantSelections = const [],
    required this.quantity,
    this.note,
  });

  /// Tổng addon cho 1 đơn vị sản phẩm (đã áp discount, dùng AddonItem.subtotal)
  double get addonPerUnit {
    double total = 0;
    for (final sel in variantSelections) {
      if (!sel.isAddonGroup || sel.addonItems == null) continue;
      for (final item in sel.addonItems!) {
        total += item.subtotal; // discountedAddonPrice × item.quantity
      }
    }
    return total;
  }

  /// Tổng addon toàn bộ CartItem (addonPerUnit × CartItem.quantity)
  double get addonTotal => addonPerUnit * quantity;

  /// Subtotal = (giá sản phẩm + addon/unit) × quantity
  double get subtotal => (selectedPrice.price + addonPerUnit) * quantity;

  CartItem copyWith({int? quantity, String? note}) => CartItem(
    product:           product,
    selectedPrice:     selectedPrice,
    variantSelections: variantSelections,
    quantity:          quantity ?? this.quantity,
    note:              note ?? this.note,
  );
}

// ════════════════════════════════════════
// SHIFT MODELS
// ════════════════════════════════════════

class PosShiftDenominationModel {
  final int denomination;
  final int quantity;
  final int total;

  const PosShiftDenominationModel({
    required this.denomination,
    required this.quantity,
    required this.total,
  });

  factory PosShiftDenominationModel.fromJson(Map<String, dynamic> json) =>
      PosShiftDenominationModel(
        denomination: json['denomination'],
        quantity:     json['quantity'],
        total:        json['total'] ?? 0,
      );

  Map<String, dynamic> toJson() =>
      {'denomination': denomination, 'quantity': quantity};
}

class PosShiftInventoryModel {
  final int ingredientId;
  final String ingredientName;
  final String? ingredientImageUrl;
  final int unitPerPack;
  final int packQuantity;
  final int unitQuantity;
  final int totalUnits;

  const PosShiftInventoryModel({
    required this.ingredientId,
    required this.ingredientName,
    this.ingredientImageUrl,
    required this.unitPerPack,
    required this.packQuantity,
    required this.unitQuantity,
    required this.totalUnits,
  });

  factory PosShiftInventoryModel.fromJson(Map<String, dynamic> json) =>
      PosShiftInventoryModel(
        ingredientId:       json['ingredientId'],
        ingredientName:     json['ingredientName'],
        ingredientImageUrl: json['ingredientImageUrl'],
        unitPerPack:        json['unitPerPack'] ?? 1,
        packQuantity:       json['packQuantity'] ?? 0,
        unitQuantity:       json['unitQuantity'] ?? 0,
        totalUnits:         json['totalUnits'] ?? 0,
      );
}

class PosShiftModel {
  final int id;
  final String staffName;
  final String status; // OPEN | CLOSED
  final String shiftDate;
  final bool isFirstShiftOfDay;
  final int openTime;
  final int? closeTime;
  final double? openingCash;
  final double? closingCash;
  final double? transferAmount;
  final String? note;
  final List<PosShiftDenominationModel> openDenominations;
  final List<PosShiftDenominationModel> closeDenominations;
  final List<PosShiftInventoryModel> openInventory;
  final List<PosShiftInventoryModel> closeInventory;
  final int totalOrders;
  final double totalRevenue;

  const PosShiftModel({
    required this.id,
    required this.staffName,
    required this.status,
    required this.shiftDate,
    required this.isFirstShiftOfDay,
    required this.openTime,
    this.closeTime,
    this.openingCash,
    this.closingCash,
    this.transferAmount,
    this.note,
    required this.openDenominations,
    required this.closeDenominations,
    required this.openInventory,
    required this.closeInventory,
    required this.totalOrders,
    required this.totalRevenue,
  });

  bool get isOpen => status == 'OPEN';

  factory PosShiftModel.fromJson(Map<String, dynamic> json) => PosShiftModel(
    id:                 json['id'],
    staffName:          json['staffName'],
    status:             json['status'],
    shiftDate:          json['shiftDate'],
    isFirstShiftOfDay:  json['isFirstShiftOfDay'] ?? false,
    openTime:           json['openTime'] ?? 0,
    closeTime:          json['closeTime'],
    openingCash:        (json['openingCash'] as num?)?.toDouble(),
    closingCash:        (json['closingCash'] as num?)?.toDouble(),
    transferAmount:     (json['transferAmount'] as num?)?.toDouble(),
    note:               json['note'],
    openDenominations:  (json['openDenominations'] as List<dynamic>? ?? [])
        .map((e) => PosShiftDenominationModel.fromJson(e))
        .toList(),
    closeDenominations: (json['closeDenominations'] as List<dynamic>? ?? [])
        .map((e) => PosShiftDenominationModel.fromJson(e))
        .toList(),
    openInventory:  (json['openInventory'] as List<dynamic>? ?? [])
        .map((e) => PosShiftInventoryModel.fromJson(e))
        .toList(),
    closeInventory: (json['closeInventory'] as List<dynamic>? ?? [])
        .map((e) => PosShiftInventoryModel.fromJson(e))
        .toList(),
    totalOrders:  json['totalOrders'] ?? 0,
    totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
  );
}

// ════════════════════════════════════════
// ORDER MODELS
// ════════════════════════════════════════

class PosOrderItemIngredientModel {
  final int ingredientId;
  final String ingredientName;
  final String? ingredientImageUrl;
  final int selectedCount;
  final double quantityUsed;

  const PosOrderItemIngredientModel({
    required this.ingredientId,
    required this.ingredientName,
    this.ingredientImageUrl,
    required this.selectedCount,
    required this.quantityUsed,
  });

  factory PosOrderItemIngredientModel.fromJson(Map<String, dynamic> json) =>
      PosOrderItemIngredientModel(
        ingredientId:       json['ingredientId'],
        ingredientName:     json['ingredientName'],
        ingredientImageUrl: json['ingredientImageUrl'],
        selectedCount:      json['selectedCount'] ?? 1,
        quantityUsed:       (json['quantityUsed'] as num).toDouble(),
      );
}

class PosOrderItemModel {
  final int id;
  final int productId;
  final String productName;
  final String? productImageUrl;
  final double basePrice;
  final int discountPercent;
  final double finalUnitPrice;
  final int quantity;
  final double subtotal;
  final int vatPercent;
  final double vatAmount;
  final double addonAmount;
  final String? note;
  final List<PosOrderItemIngredientModel> selectedIngredients;

  const PosOrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImageUrl,
    required this.basePrice,
    required this.discountPercent,
    required this.finalUnitPrice,
    required this.quantity,
    required this.subtotal,
    this.vatPercent = 0,
    this.vatAmount = 0,
    this.addonAmount = 0,
    this.note,
    required this.selectedIngredients,
  });

  factory PosOrderItemModel.fromJson(Map<String, dynamic> json) =>
      PosOrderItemModel(
        id:                 json['id'],
        productId:          json['productId'],
        productName:        json['productName'],
        productImageUrl:    json['productImageUrl'],
        basePrice:          (json['basePrice'] as num).toDouble(),
        discountPercent:    json['discountPercent'] ?? 0,
        finalUnitPrice:     (json['finalUnitPrice'] as num).toDouble(),
        quantity:           json['quantity'],
        subtotal:           (json['subtotal'] as num).toDouble(),
        vatPercent:         json['vatPercent'] as int? ?? 0,
        vatAmount:          (json['vatAmount'] as num?)?.toDouble() ?? 0.0,
        addonAmount:        (json['addonAmount'] as num?)?.toDouble() ?? 0.0,
        note:               json['note'],
        selectedIngredients: (json['selectedIngredients'] as List<dynamic>? ?? [])
            .map((e) => PosOrderItemIngredientModel.fromJson(e))
            .toList(),
      );
}

class PosOrderModel {
  final int id;
  final String orderCode;
  final int shiftId;
  final String staffName;
  final String orderSource;
  final String status;
  final double totalAmount;
  final double finalAmount;
  final double totalVat;
  final String paymentMethod;
  final String? note;
  final int createdAt;
  final int updatedAt;
  final List<PosOrderItemModel> items;

  const PosOrderModel({
    required this.id,
    required this.orderCode,
    required this.shiftId,
    required this.staffName,
    required this.orderSource,
    required this.status,
    required this.totalAmount,
    required this.finalAmount,
    this.totalVat = 0,
    this.paymentMethod = 'CASH',
    this.note,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  factory PosOrderModel.fromJson(Map<String, dynamic> json) => PosOrderModel(
    id:            json['id'],
    orderCode:     json['orderCode'],
    shiftId:       json['shiftId'],
    staffName:     json['staffName'],
    orderSource:   json['orderSource'],
    status:        json['status'],
    totalAmount:   (json['totalAmount'] as num).toDouble(),
    finalAmount:   (json['finalAmount'] as num).toDouble(),
    totalVat:      (json['totalVat'] as num?)?.toDouble() ?? 0.0,
    paymentMethod: json['paymentMethod'] as String? ?? 'CASH',
    note:          json['note'],
    createdAt:     json['createdAt'] ?? 0,
    updatedAt:     json['updatedAt'] ?? 0,
    items: (json['items'] as List<dynamic>? ?? [])
        .map((e) => PosOrderItemModel.fromJson(e))
        .toList(),
  );
}

// ════════════════════════════════════════
// STOCK IMPORT MODELS
// ════════════════════════════════════════

class StockImportItem {
  final int ingredientId;
  final int packQty;
  const StockImportItem({required this.ingredientId, required this.packQty});
}

class StockImportModel {
  final int id;
  final int ingredientId;
  final String ingredientName;
  final int packQty;
  final int importedAt;

  const StockImportModel({
    required this.id,
    required this.ingredientId,
    required this.ingredientName,
    required this.packQty,
    required this.importedAt,
  });

  factory StockImportModel.fromJson(Map<String, dynamic> json) => StockImportModel(
    id:             json['id'] as int,
    ingredientId:   json['ingredientId'] as int,
    ingredientName: json['ingredientName'] as String,
    packQty:        json['packQty'] as int,
    importedAt:     json['importedAt'] as int,
  );
}

// ════════════════════════════════════════
// POS SERVICE
// ════════════════════════════════════════

class PosService {
  static const String _baseUrl = '/api/pos';

  // ════════════════════════════════════════
  // IMAGE HELPERS
  // ════════════════════════════════════════

  static String buildImageUrl(String? dbPath) {
    if (dbPath == null || dbPath.isEmpty) return '';
    final parts = dbPath.split('/');
    if (parts.length < 4) return '';
    final type     = parts[2];
    final filename = parts[3];
    return '${ApiHelper.baseUrl}/api/auth/images/$type/$filename';
  }


  static Future<String> uploadCategoryImage(String filePath) async {
    final res = await ApiHelper.uploadFile<Map<String, dynamic>>(
      '/api/upload/category-image',
      filePath: filePath,
      fieldName: 'image',
      fromData: (data) => data as Map<String, dynamic>,
    );
    if (res.isSuccess && res.data != null) {
      return res.data!['imageUrl'] as String;
    }
    throw Exception(res.message.isNotEmpty ? res.message : 'Failed to upload category image');
  }

  static Future<String> uploadPosProductImage(String filePath) async {
    final res = await ApiHelper.uploadFile<Map<String, dynamic>>(
      '/api/upload/pos-product-image',
      filePath: filePath,
      fieldName: 'image',
      fromData: (data) => data as Map<String, dynamic>,
    );
    if (res.isSuccess && res.data != null) {
      return res.data!['imageUrl'] as String;
    }
    throw Exception(res.message.isNotEmpty ? res.message : 'Failed to upload product image');
  }

  static Future<String> uploadImage({
    required String filePath,
    required String type,
  }) async {
    String endpoint;
    switch (type.toLowerCase()) {
      case 'category':    endpoint = '/api/upload/category-image'; break;
      case 'product':     endpoint = '/api/upload/product-image'; break;
      case 'pos-product': endpoint = '/api/upload/pos-product-image'; break;
      case 'variant':     endpoint = '/api/upload/variant-image'; break;
      case 'ingredient':  endpoint = '/api/upload/ingredient-image'; break;
      default: throw Exception('Loại ảnh không hỗ trợ: $type');
    }
    final res = await ApiHelper.uploadFile<dynamic>(
      endpoint,
      filePath: filePath,
      fieldName: 'image',
      fromData: (data) => data,
    );
    if (res.data != null && res.data is Map<String, dynamic>) {
      final imageUrl = (res.data as Map<String, dynamic>)['imageUrl'] as String?;
      if (imageUrl != null && imageUrl.isNotEmpty) return imageUrl;
    }
    throw Exception(res.message.isNotEmpty ? res.message : 'Upload ảnh thất bại (code: ${res.code})');
  }

  // ════════════════════════════════════════
  // CATEGORY
  // ════════════════════════════════════════

  static Future<List<PosCategoryModel>> getCategories() async {
    final res = await ApiHelper.get('$_baseUrl/categories', fromData: (data) => data);
    if (res.isSuccess && res.data != null) {
      return (res.data as List<dynamic>)
          .map((e) => PosCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(res.message.isNotEmpty ? res.message : 'Failed to load categories');
  }

  static Future<PosCategoryModel> createCategory({
    required String name,
    bool singlePrice = false,
    int displayOrder = 0,
    String? imageUrl,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'singlePrice': singlePrice,
      'displayOrder': displayOrder,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
    final res = await ApiHelper.post('$_baseUrl/categories', body: body, fromData: (data) => data);
    if (res.isSuccess && res.data != null) {
      return PosCategoryModel.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception(res.message.isNotEmpty ? res.message : 'Failed to create category');
  }

  static Future<PosCategoryModel> updateCategory(
      int id, {
        String? name,
        bool? singlePrice,
        int? displayOrder,
        bool? isActive,
        String? imageUrl,
      }) async {
    final body = <String, dynamic>{};
    if (name != null)         body['name']         = name;
    if (singlePrice != null)  body['singlePrice']  = singlePrice;
    if (displayOrder != null) body['displayOrder'] = displayOrder;
    if (isActive != null)     body['isActive']     = isActive;
    if (imageUrl != null)     body['imageUrl']     = imageUrl;
    final res = await ApiHelper.put('$_baseUrl/categories/$id', body: body, fromData: (data) => data);
    if (res.isSuccess && res.data != null) {
      return PosCategoryModel.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception(res.message.isNotEmpty ? res.message : 'Failed to update category');
  }

  static Future<void> deleteCategory(int id) async {
    final res = await ApiHelper.delete('$_baseUrl/categories/$id', fromData: (data) => data);
    if (!res.isSuccess) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Failed to delete category');
    }
  }

  // ════════════════════════════════════════
  // PRODUCT
  // ════════════════════════════════════════

  static Future<List<PosProductModel>> getProducts({int? categoryId}) async {
    final query = categoryId != null ? '?categoryId=$categoryId' : '';
    final res = await ApiHelper.get('$_baseUrl/products$query', fromData: (data) => data);
    if (res.isSuccess && res.data != null) {
      return (res.data as List<dynamic>)
          .map((e) => PosProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(res.message.isNotEmpty ? res.message : 'Failed to load products');
  }

  static Future<PosProductModel> getProductById(int id) async {
    final res = await ApiHelper.get('$_baseUrl/products/$id', fromData: (data) => data);
    if (res.isSuccess && res.data != null) {
      return PosProductModel.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception(res.message.isNotEmpty ? res.message : 'Failed to load product');
  }

  static Future<PosProductModel> createProduct({
    required String name,
    required int categoryId,
    required double basePrice,
    String? description,
    String? imageUrl,
    int displayOrder = 0,
    int vatPercent = 0,
    bool isShopeeFood = false,
    bool isGrabFood = false,
    double? shopeePrice,
    double? grabPrice,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'categoryId': categoryId,
      'basePrice': basePrice,
      'displayOrder': displayOrder,
      'vatPercent': vatPercent,
      'isShopeeFood': isShopeeFood,
      'isGrabFood': isGrabFood,
      if (description != null && description.isNotEmpty) 'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (isShopeeFood && shopeePrice != null) 'shopeePrice': shopeePrice,
      if (isGrabFood && grabPrice != null) 'grabPrice': grabPrice,
    };
    final res = await ApiHelper.post('$_baseUrl/products', body: body, fromData: (data) => data);
    if (res.isSuccess && res.data != null) {
      return PosProductModel.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception(res.message.isNotEmpty ? res.message : 'Failed to create product');
  }

  static Future<PosProductModel> updateProduct(
      int id, {
        String? name,
        int? categoryId,
        double? basePrice,
        String? description,
        bool? isActive,
        String? imageUrl,
        int? vatPercent,
        bool? isShopeeFood,
        bool? isGrabFood,
        double? shopeePrice,
        double? grabPrice,
      }) async {
    final body = <String, dynamic>{};
    if (name != null)        body['name']        = name;
    if (categoryId != null)  body['categoryId']  = categoryId;
    if (basePrice != null)   body['basePrice']   = basePrice;
    if (description != null) body['description'] = description;
    if (isActive != null)    body['isActive']    = isActive;
    if (imageUrl != null)    body['imageUrl']    = imageUrl;
    if (vatPercent != null)  body['vatPercent']  = vatPercent;
    if (isShopeeFood != null) {
      body['isShopeeFood'] = isShopeeFood;
      if (shopeePrice != null) body['shopeePrice'] = shopeePrice;
    }
    if (isGrabFood != null) {
      body['isGrabFood'] = isGrabFood;
      if (grabPrice != null) body['grabPrice'] = grabPrice;
    }
    final res = await ApiHelper.put('$_baseUrl/products/$id', body: body, fromData: (data) => data);
    if (res.isSuccess && res.data != null) {
      return PosProductModel.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception(res.message.isNotEmpty ? res.message : 'Failed to update product');
  }

  static Future<void> updateProductOrder(int id, {required int displayOrder}) async {
    final res = await ApiHelper.put(
      '$_baseUrl/products/$id',
      body: {'displayOrder': displayOrder},
      fromData: (data) => data,
    );
    if (!res.isSuccess) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Failed to update product order');
    }
  }

  static Future<void> deleteProduct(int id) async {
    final res = await ApiHelper.delete('$_baseUrl/products/$id', fromData: (data) => data);
    if (!res.isSuccess) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Failed to delete product');
    }
  }

  // ════════════════════════════════════════
  // INGREDIENT
  // ════════════════════════════════════════

  static Future<List<Map<String, dynamic>>> getIngredients() async {
    final res = await ApiHelper.get('$_baseUrl/ingredients', fromData: (data) => data);
    if (res.isSuccess && res.data != null) {
      return (res.data as List<dynamic>).cast<Map<String, dynamic>>();
    }
    throw Exception(res.message.isNotEmpty ? res.message : 'Failed to load ingredients');
  }

  static Future<Map<String, dynamic>> createIngredient({
    required String name,
    required int unitPerPack,
    int displayOrder = 0,
    String ingredientType = 'MAIN',
    double addonPrice = 0,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'unitPerPack': unitPerPack,
      'displayOrder': displayOrder,
      'ingredientType': ingredientType,
      'addonPrice': addonPrice,
    };
    final res = await ApiHelper.post('$_baseUrl/ingredients', body: body, fromData: (data) => data);
    if (res.isSuccess && res.data != null) return res.data as Map<String, dynamic>;
    throw Exception(res.message.isNotEmpty ? res.message : 'Failed to create ingredient');
  }

  static Future<Map<String, dynamic>> updateIngredient(
      int id, {
        String? name,
        int? unitPerPack,
        int? displayOrder,
        String? ingredientType,
        double? addonPrice,
      }) async {
    final body = <String, dynamic>{};
    if (name != null)           body['name']           = name;
    if (unitPerPack != null)    body['unitPerPack']    = unitPerPack;
    if (displayOrder != null)   body['displayOrder']   = displayOrder;
    if (ingredientType != null) body['ingredientType'] = ingredientType;
    if (addonPrice != null)     body['addonPrice']     = addonPrice;
    final res = await ApiHelper.put('$_baseUrl/ingredients/$id', body: body, fromData: (data) => data);
    if (res.isSuccess && res.data != null) return res.data as Map<String, dynamic>;
    throw Exception(res.message.isNotEmpty ? res.message : 'Failed to update ingredient');
  }

  static Future<void> deleteIngredient(int id) async {
    final res = await ApiHelper.delete('$_baseUrl/ingredients/$id', fromData: (data) => data);
    if (!res.isSuccess) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Failed to delete ingredient');
    }
  }

  // ════════════════════════════════════════
  // VARIANT
  // ════════════════════════════════════════

  static Future<void> createVariant(Map<String, dynamic> body) async {
    final res = await ApiHelper.post('$_baseUrl/variants', body: body, fromData: (data) => data);
    if (!res.isSuccess) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Failed to create variant');
    }
  }

  static Future<void> updateVariant(int id, Map<String, dynamic> body) async {
    final res = await ApiHelper.put('$_baseUrl/variants/$id', body: body, fromData: (data) => data);
    if (!res.isSuccess) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Failed to update variant');
    }
  }

  static Future<void> deleteVariant(int id) async {
    final res = await ApiHelper.delete('$_baseUrl/variants/$id', fromData: (data) => data);
    if (!res.isSuccess) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Failed to delete variant');
    }
  }

  // ════════════════════════════════════════
  // SHIFT
  // ════════════════════════════════════════

  static Future<PosShiftModel?> getCurrentShift() async {
    try {
      final res = await ApiHelper.get('$_baseUrl/shifts/current', fromData: (data) => data);
      if (res.isSuccess && res.data != null) {
        return PosShiftModel.fromJson(res.data as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<PosShiftModel> openShift({
    required String staffName,
    required List<Map<String, dynamic>> openDenominations,
    List<Map<String, dynamic>>? openInventory,
  }) async {
    final body = <String, dynamic>{
      'staffName': staffName,
      'openDenominations': openDenominations,
      if (openInventory != null) 'openInventory': openInventory,
    };
    final res = await ApiHelper.post('$_baseUrl/shifts/open', body: body, fromData: (data) => data);
    if (res.isSuccess && res.data != null) {
      return PosShiftModel.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception(res.message.isNotEmpty ? res.message : 'Failed to open shift');
  }

  static Future<PosShiftModel> closeShift({
    required List<Map<String, dynamic>> closeDenominations,
    required List<Map<String, dynamic>> closeInventory,
    double? transferAmount,
    String? note,
  }) async {
    final body = <String, dynamic>{
      'closeDenominations': closeDenominations,
      'closeInventory': closeInventory,
      if (transferAmount != null) 'transferAmount': transferAmount,
      if (note != null && note.isNotEmpty) 'note': note,
    };
    final res = await ApiHelper.post('$_baseUrl/shifts/close', body: body, fromData: (data) => data);
    if (res.isSuccess && res.data != null) {
      return PosShiftModel.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception(res.message.isNotEmpty ? res.message : 'Failed to close shift');
  }

  static Future<List<PosShiftModel>> getShiftsByDate(String date) async {
    final res = await ApiHelper.get('$_baseUrl/shifts?date=$date', fromData: (data) => data);
    if (res.isSuccess && res.data != null) {
      return (res.data as List<dynamic>)
          .map((e) => PosShiftModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(res.message.isNotEmpty ? res.message : 'Failed to load shifts');
  }

  static Future<Map<String, dynamic>> getShiftReport(int shiftId) async {
    final res = await ApiHelper.get('$_baseUrl/shifts/$shiftId/report', fromData: (data) => data);
    if (res.isSuccess && res.data != null) return res.data as Map<String, dynamic>;
    throw Exception(res.message.isNotEmpty ? res.message : 'Failed to load report');
  }

  // ════════════════════════════════════════
  // ORDER
  // ════════════════════════════════════════

  static Future<PosOrderModel> createOrder({
    required String orderSource,
    required List<CartItem> cartItems,
    String paymentMethod = 'CASH',
    String? note,
  }) async {
    final items = cartItems.map((c) {
      return <String, dynamic>{
        'productId':       c.product.id,
        'quantity':        c.quantity,
        'discountPercent': c.selectedPrice.discountPercent,
        'vatPercent':      c.product.vatPercent,
        if (c.note != null && c.note!.isNotEmpty) 'note': c.note,
        'variantSelections': c.variantSelections
            .where((sel) => sel.selectedIngredients.isNotEmpty)
            .map((sel) => <String, dynamic>{
          'variantId':    sel.variantId,
          'isAddonGroup': sel.isAddonGroup,
          'selectedIngredients': sel.selectedIngredients.entries.map((e) {
            // Tìm AddonItem snapshot nếu là addon group
            final addonItem = sel.addonItems
                ?.where((a) => a.ingredientId == e.key)
                .firstOrNull;
            return <String, dynamic>{
              'ingredientId':  e.key,
              'selectedCount': e.value,
              // Snapshot giá addon tại thời điểm đặt hàng
              if (addonItem != null) ...{
                'isAddonIngredient':  true,
                'addonPriceSnapshot': addonItem.discountedAddonPrice,
                'addonBasePrice':     addonItem.baseAddonPrice,
                'addonName':          addonItem.ingredientName,
              },
            };
          }).toList(),
        })
            .toList(),
      };
    }).toList();

    final body = <String, dynamic>{
      'orderSource':   orderSource,
      'paymentMethod': paymentMethod,
      'items':         items,
      if (note != null && note.isNotEmpty) 'note': note,
    };

    final res = await ApiHelper.post('$_baseUrl/orders', body: body, fromData: (data) => data);
    if (res.isSuccess && res.data != null) {
      return PosOrderModel.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception(res.message.isNotEmpty ? res.message : 'Failed to create order');
  }

  static Future<PosOrderModel> getOrderById(int id) async {
    final res = await ApiHelper.get('$_baseUrl/orders/$id', fromData: (data) => data);
    if (res.isSuccess && res.data != null) {
      return PosOrderModel.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception(res.message.isNotEmpty ? res.message : 'Failed to load order');
  }

  static Future<List<PosOrderModel>> getOrdersByShift(int shiftId) async {
    final res = await ApiHelper.get('$_baseUrl/shifts/$shiftId/orders', fromData: (data) => data);
    if (res.isSuccess && res.data != null) {
      return (res.data as List<dynamic>)
          .map((e) => PosOrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(res.message.isNotEmpty ? res.message : 'Failed to load orders');
  }

  static Future<PosOrderModel> cancelOrder(int orderId, String password) async {
    final res = await ApiHelper.post(
      '$_baseUrl/orders/$orderId/cancel',
      body: {'password': password},
      fromData: (data) => data,
    );
    if (res.isSuccess && res.data != null) {
      return PosOrderModel.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception(res.message.isNotEmpty ? res.message : 'Không thể hủy đơn hàng');
  }

  // ════════════════════════════════════════
  // STOCK IMPORT
  // ════════════════════════════════════════

  static Future<List<StockImportModel>> importStock(List<StockImportItem> items) async {
    final body = {
      'items': items.map((i) => {'ingredientId': i.ingredientId, 'packQty': i.packQty}).toList(),
    };
    final res = await ApiHelper.post(
      '$_baseUrl/shifts/stock-import',
      body: body,
      fromData: (data) => data,
    );
    if (res.isSuccess && res.data != null) {
      return (res.data as List<dynamic>)
          .map((e) => StockImportModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(res.message.isNotEmpty ? res.message : 'Nhập kho thất bại');
  }

  static Future<List<StockImportModel>> getStockImports(int shiftId) async {
    final res = await ApiHelper.get(
      '$_baseUrl/shifts/$shiftId/stock-imports',
      fromData: (data) => data,
    );
    if (res.isSuccess && res.data != null) {
      return (res.data as List<dynamic>)
          .map((e) => StockImportModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static Future<PosOrderModel> updateOrderPaymentMethod(int orderId, String newMethod) async {
    final body = {'paymentMethod': newMethod}; // CASH hoặc TRANSFER
    final res = await ApiHelper.put(
      '$_baseUrl/orders/$orderId/payment-method',
      body: body,
      fromData: (data) => PosOrderModel.fromJson(data as Map<String, dynamic>),
    );
    if (res.isSuccess && res.data != null) {
      return res.data!;
    }
    throw Exception(res.message.isNotEmpty ? res.message : 'Cập nhật phương thức thanh toán thất bại');
  }
}