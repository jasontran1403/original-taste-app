import 'dart:io';
import 'package:http/http.dart' as http;

import 'api_helper.dart';

// ══════════════════════════════════════════════════════════════════
// MODELS
// ══════════════════════════════════════════════════════════════════
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
  final double quantity; // luôn dương từ backend
  final String status;
  final String? unit; // thêm field này

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
      unit: json['unit'], // backend cần trả thêm field unit nếu có
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

class ProductPriceModel {
  final int id;
  final String priceName;
  final double price;
  final bool isDefault;

  ProductPriceModel({
    required this.id,
    required this.priceName,
    required this.price,
    required this.isDefault,
  });

  factory ProductPriceModel.fromJson(Map<String, dynamic> json) =>
      ProductPriceModel(
        id: json['id'] ?? 0,
        priceName: json['priceName'] ?? '',
        price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
        isDefault: json['isDefault'] ?? false,
      );
}

class ProductModel {
  final int id;
  final String name;
  final String? description;
  final String? unit;
  final String? imageUrl;
  final int? categoryId;
  final String? categoryName;
  final double? defaultPrice;
  final String? defaultPriceName;
  final List<ProductVariantModel> variants;
  final List<ProductPriceModel> prices;
  final int? createdAt;
  final int? updatedAt;
  final int vatRate; // ← THÊM FIELD NÀY (0,5,8,10)

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    this.unit,
    this.imageUrl,
    this.categoryId,
    this.categoryName,
    this.defaultPrice,
    this.defaultPriceName,
    required this.variants,
    required this.prices,
    this.createdAt,
    this.updatedAt,
    this.vatRate = 0, // mặc định 0
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    description: json['description'],
    unit: json['unit'],
    imageUrl: json['imageUrl'],
    categoryId: json['categoryId'],
    categoryName: json['categoryName'],
    defaultPrice: double.tryParse(json['defaultPrice']?.toString() ?? ''),
    defaultPriceName: json['defaultPriceName'],
    variants:
        (json['variants'] as List<dynamic>? ?? [])
            .map((e) => ProductVariantModel.fromJson(e))
            .toList(),
    prices:
        (json['prices'] as List<dynamic>? ?? [])
            .map((e) => ProductPriceModel.fromJson(e))
            .toList(),
    createdAt: json['createdAt'],
    updatedAt: json['updatedAt'],
    vatRate: json['vatRate'] ?? 0, // ← map từ JSON
  );
}

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

  Map<String, dynamic> toJson() => {'address': address, 'isDefault': isDefault};
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
    addresses:
        (json['addresses'] as List<dynamic>? ?? [])
            .map((e) => CustomerAddressModel.fromJson(e))
            .toList(),
    createdAt: json['createdAt'],
    updatedAt: json['updatedAt'],
  );

  CustomerAddressModel? get defaultAddress =>
      addresses.where((a) => a.isDefault).firstOrNull ?? addresses.firstOrNull;
}

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

class OrderItemModel {
  final int id;
  final int productId;
  final String productName;
  final String? productImageUrl;
  final int? variantId;
  final String? variantName;
  final String priceName;
  final double unitPrice;
  final double defaultPrice;
  final double quantity;
  final double subtotal;
  final String? unit;
  final String? notes;
  final List<OrderItemIngredientModel> ingredientsUsed;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImageUrl,
    this.variantId,
    this.variantName,
    required this.priceName,
    required this.unitPrice,
    required this.defaultPrice,
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
    priceName: json['priceName'] ?? '',
    unitPrice: double.tryParse(json['unitPrice']?.toString() ?? '0') ?? 0,
    defaultPrice: double.tryParse(json['defaultPrice']?.toString() ?? '0') ?? 0,
    quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
    subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
    unit: json['unit'],
    notes: json['notes'],
    ingredientsUsed:
        (json['ingredientsUsed'] as List<dynamic>? ?? [])
            .map((e) => OrderItemIngredientModel.fromJson(e))
            .toList(),
  );
}

class OrderModel {
  final int id;
  final String orderCode;
  final String? customerName;
  final String? customerPhone;
  final String? shippingAddress;
  final double totalAmount;
  final double discountAmount;
  final double finalAmount;
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
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id'] ?? 0,
    orderCode: json['orderCode'] ?? '',
    customerName: json['customerName'],
    customerPhone: json['customerPhone'],
    shippingAddress: json['shippingAddress'],
    totalAmount: double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0,
    discountAmount:
        double.tryParse(json['discountAmount']?.toString() ?? '0') ?? 0,
    finalAmount: double.tryParse(json['finalAmount']?.toString() ?? '0') ?? 0,
    status: json['status'] ?? '',
    paymentStatus: json['paymentStatus'] ?? '',
    paymentMethod: json['paymentMethod'],
    notes: json['notes'],
    createdAt: json['createdAt'],
    items:
        (json['items'] as List<dynamic>? ?? [])
            .map((e) => OrderItemModel.fromJson(e))
            .toList(),
  );
}

// ══════════════════════════════════════════════════════════════════
// REQUEST MODELS
// ══════════════════════════════════════════════════════════════════

class CreateOrderItemRequest {
  final int productId;
  final int? variantId;
  final int priceId;
  final double quantity;
  final String? notes;

  CreateOrderItemRequest({
    required this.productId,
    this.variantId,
    required this.priceId,
    required this.quantity,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'productId': productId,
    if (variantId != null) 'variantId': variantId,
    'priceId': priceId,
    'quantity': quantity,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };
}

class CreateOrderRequest {
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String? shippingAddress;
  final String paymentMethod; // CASH | BANK_TRANSFER
  final String? notes;
  final List<CreateOrderItemRequest> items;

  CreateOrderRequest({
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.shippingAddress,
    required this.paymentMethod,
    this.notes,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    if (customerName != null) 'customerName': customerName,
    if (customerPhone != null) 'customerPhone': customerPhone,
    if (customerEmail != null) 'customerEmail': customerEmail,
    if (shippingAddress != null) 'shippingAddress': shippingAddress,
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
        // Server trả về JSON kiểu { "code": 900, "message": "...", ... }
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

  /// Lấy lịch sử xuất/nhập kho với phân trang
  static Future<ApiResult<PaginatedResponse<InventoryLogModel>>>
  getInventoryLogs({required int page, required int size}) async {
    return ApiHelper.get<PaginatedResponse<InventoryLogModel>>(
      '/api/seller/inventory/logs',
      queryParams: {'page': page.toString(), 'size': size.toString()},
      fromData: (data) {
        if (data is Map<String, dynamic>) {
          final content =
              (data['content'] as List<dynamic>? ?? [])
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
      '/api/upload/product-image', // ← đúng endpoint
      filePath: filePath,
      fieldName: 'image', // ← đúng field name (không phải 'file')
      fromData: (data) {
        // Response là Map {"imageUrl": "...", "filename": "..."}
        // ApiHelper.uploadFile trả về data là Map, cần lấy 'imageUrl'
        if (data is Map) {
          return data['imageUrl']?.toString();
        }
        return data?.toString();
      },
    );
  }

  static Future<ApiResult<ProductModel>> createProduct({
    required String name,
    String? description,
    String? unit,
    String? imageUrl,
    int? categoryId,
    String? categoryName,
    required List<Map<String, dynamic>> prices,
    List<Map<String, dynamic>>? variants,
    List<Map<String, dynamic>>? ingredients,
    required int vatRate, // ← THÊM PARAM NÀY
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
        'prices': prices,
        if (variants != null && variants.isNotEmpty) 'variants': variants,
        if (ingredients != null && ingredients.isNotEmpty)
          'ingredients': ingredients,
        'vatRate': vatRate, // ← THÊM FIELD NÀY VÀO BODY
      },
      fromData: (data) => data != null ? ProductModel.fromJson(data) : null,
    );
  }

  static Future<ApiResult<dynamic>> deleteProduct(int id) async {
    return ApiHelper.delete<dynamic>('/api/seller/products/$id');
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
    CreateOrderRequest request,
  ) async {
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
    String phone,
  ) async {
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

  // helper/services/seller_services.dart
  static Future<ApiResult<ProductModel>> updateProduct({
    required int id,
    required String name,
    String? description,
    String? unit,
    String? imageUrl,
    int? categoryId,
    String? categoryName,
    required List<Map<String, dynamic>> prices,
    List<Map<String, dynamic>>? variants,
    required int vatRate, // ← ĐÃ CÓ, nhưng cần dùng trong body
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
        'prices': prices,
        if (variants != null && variants.isNotEmpty) 'variants': variants,
        'vatRate': vatRate, // ← THÊM DÒNG NÀY (quan trọng nhất!)
      },
      fromData: (data) => data != null ? ProductModel.fromJson(data) : null,
    );
  }

  static Future<ApiResult<ProductModel>> setDefaultPrice({
    required int productId,
    required int priceId,
  }) async {
    return ApiHelper.put<ProductModel>(
      '/api/seller/products/$productId/prices/$priceId/set-default',
      body: {}, // Empty body for PUT request
      fromData: (data) => data != null ? ProductModel.fromJson(data) : null,
    );
  }

  static Future<ApiResult<ProductModel>> removePrice({
    required int productId,
    required int priceId,
  }) async {
    return ApiHelper.delete<ProductModel>(
      '/api/seller/products/$productId/prices/$priceId',
      fromData: (data) => data != null ? ProductModel.fromJson(data) : null,
    );
  }
}
