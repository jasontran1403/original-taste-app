import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:original_taste/helper/services/seller_services.dart';

// ── Selected Customer ─────────────────────────────────────────────
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

// ── Cart Item ─────────────────────────────────────────────────────
class CartItem {
  final ProductModel product;
  final ProductPriceModel price;
  final TextEditingController qtyController;
  double quantity;

  CartItem({
    required this.product,
    required this.price,
    required this.quantity,
  }) : qtyController = TextEditingController(text: quantity.toStringAsFixed(2));

  double get subtotal => price.price * quantity;

  void dispose() => qtyController.dispose();
}

// ── Quantity formatter (chỉ số, tối đa 2 thập phân, không âm) ────
class _QtyFormatter extends TextInputFormatter {
  static final _instance = _QtyFormatter._();
  _QtyFormatter._();
  static TextInputFormatter get instance => _instance;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue next) {
    final text = next.text;
    if (text.isEmpty) return next;
    if (!RegExp(r'^\d*\.?\d{0,2}$').hasMatch(text)) return old;
    return next;
  }
}

// ── Controller ────────────────────────────────────────────────────
class OrderCartController extends GetxController {
  // ── Products / Categories ─────────────────────────────────────
  List<ProductModel> allProducts = [];
  List<ProductModel> filteredProducts = [];
  List<CategoryModel> categories = [];
  bool isLoadingProducts = false;

  // ── Filter ────────────────────────────────────────────────────
  String searchQuery = '';
  CategoryModel? selectedCategory;
  String sortMode = 'name_asc';

  // ── Cart ──────────────────────────────────────────────────────
  final List<CartItem> cartItems = [];

  // ── Customer ──────────────────────────────────────────────────
  SelectedCustomer? selectedCustomer;

  // ── Order options ─────────────────────────────────────────────
  String vatRate = 'ZERO';
  String paymentMethod = 'CASH';
  String orderNotes = '';

  // ── State ─────────────────────────────────────────────────────
  bool isSubmitting = false;

  static TextInputFormatter get qtyFormatter => _QtyFormatter.instance;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  @override
  void onClose() {
    for (final item in cartItems) {
      item.dispose();
    }
    super.onClose();
  }

  // ── Load ──────────────────────────────────────────────────────
  Future<void> _loadData() async {
    isLoadingProducts = true;
    update();

    final catResult = await SellerService.getCategories();
    if (catResult.isSuccess && catResult.data != null) {
      categories = catResult.data!;
    }

    // Lấy tất cả products để hiển thị trong grid
    final prodResult = await SellerService.getProducts(page: 0, size: 200);
    if (prodResult.isSuccess && prodResult.data != null) {
      allProducts = prodResult.data!;
    }

    isLoadingProducts = false;
    _applyFilter();
  }

  Future<void> refreshProducts() => _loadData();

  // ── Filter / Sort ─────────────────────────────────────────────
  void onSearch(String q) {
    searchQuery = q.trim().toLowerCase();
    _applyFilter();
  }

  void onSelectCategory(CategoryModel? cat) {
    selectedCategory = cat;
    _applyFilter();
  }

  void onSortMode(String mode) {
    sortMode = mode;
    _applyFilter();
  }

  void _applyFilter() {
    List<ProductModel> list = List.from(allProducts);

    if (selectedCategory != null) {
      list = list.where((p) => p.categoryId == selectedCategory!.id).toList();
    }

    if (searchQuery.isNotEmpty) {
      list =
          list.where((p) => p.name.toLowerCase().contains(searchQuery)).toList();
    }

    switch (sortMode) {
      case 'name_asc':
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'name_desc':
        list.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'price_asc':
        list.sort((a, b) =>
            (a.defaultPrice ?? 0).compareTo(b.defaultPrice ?? 0));
        break;
      case 'price_desc':
        list.sort((a, b) =>
            (b.defaultPrice ?? 0).compareTo(a.defaultPrice ?? 0));
        break;
    }

    filteredProducts = list;
    update();
  }

  // ── Cart ops ──────────────────────────────────────────────────
  void addToCart(ProductModel product, ProductPriceModel price) {
    final existing = cartItems.firstWhereOrNull(
            (c) => c.product.id == product.id && c.price.id == price.id);

    if (existing != null) {
      existing.quantity =
          double.parse((existing.quantity + 1.0).toStringAsFixed(2));
      existing.qtyController.text = existing.quantity.toStringAsFixed(2);
    } else {
      cartItems.add(CartItem(product: product, price: price, quantity: 1.0));
    }
    update();
  }

  void removeFromCart(int index) {
    cartItems[index].dispose();
    cartItems.removeAt(index);
    update();
  }

  void clearCart() {
    for (final item in cartItems) {
      item.dispose();
    }
    cartItems.clear();
    update();
  }

  // ── Qty ───────────────────────────────────────────────────────
  void onQtyTap(CartItem item) {
    item.qtyController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: item.qtyController.text.length,
    );
  }

  void onQtyChanged(CartItem item, String value) {
    final parsed = double.tryParse(value);
    if (parsed != null && parsed >= 0.01) {
      item.quantity = parsed;
      update();
    }
  }

  void onQtySubmitted(CartItem item) {
    final parsed = double.tryParse(item.qtyController.text);
    item.quantity = (parsed != null && parsed >= 0.01) ? parsed : 0.01;
    item.qtyController.text = item.quantity.toStringAsFixed(2);
    update();
  }

  void incrementQty(CartItem item) {
    item.quantity = double.parse((item.quantity + 1.0).toStringAsFixed(2));
    item.qtyController.text = item.quantity.toStringAsFixed(2);
    update();
  }

  void decrementQty(CartItem item) {
    item.quantity = double.parse(
        (item.quantity - 1.0).clamp(0.01, 99999.0).toStringAsFixed(2));
    item.qtyController.text = item.quantity.toStringAsFixed(2);
    update();
  }

  // ── Totals ────────────────────────────────────────────────────
  double get subtotal =>
      cartItems.fold(0.0, (sum, c) => sum + c.subtotal);

  double get discountAmount {
    final rate = selectedCustomer?.discountRate ?? 0;
    return subtotal * rate / 100;
  }

  double get afterDiscount => subtotal - discountAmount;

  double get vatAmount => afterDiscount * _vatRateValue / 100;

  double get grandTotal => afterDiscount + vatAmount;

  int get _vatRateValue {
    switch (vatRate) {
      case 'FIVE':
        return 5;
      case 'EIGHT':
        return 8;
      case 'TEN':
        return 10;
      default:
        return 0;
    }
  }

  // ── Customer ──────────────────────────────────────────────────
  void setCustomer(SelectedCustomer customer) {
    selectedCustomer = customer;
    update();
  }

  void clearCustomer() {
    selectedCustomer = null;
    update();
  }

  bool get canCreateOrder =>
      selectedCustomer != null && cartItems.isNotEmpty && !isSubmitting;

  // ── Submit ────────────────────────────────────────────────────
  Future<void> submitOrder() async {
    if (!canCreateOrder) return;

    isSubmitting = true;
    update();

    // Dùng CreateOrderRequest model từ seller_services.dart
    final request = CreateOrderRequest(
      customerName: selectedCustomer!.name,
      customerPhone: selectedCustomer!.phone,
      customerEmail: selectedCustomer!.email.isEmpty
          ? null
          : selectedCustomer!.email,
      shippingAddress: selectedCustomer!.address.isEmpty
          ? null
          : selectedCustomer!.address,
      paymentMethod: paymentMethod,
      notes: orderNotes.isEmpty ? null : orderNotes,
      items: cartItems
          .map((c) => CreateOrderItemRequest(
        productId: c.product.id,
        variantId: null,
        priceId: c.price.id,
        quantity: c.quantity,
        notes: null,
      ))
          .toList(),
    );

    // Gọi SellerService.createOrder theo đúng pattern trong seller_services.dart
    // → trả về ApiResult<OrderModel>
    final result = await SellerService.createOrder(request);

    isSubmitting = false;
    update();

    if (result.isSuccess && result.data != null) {
      final order = result.data!;
      Get.snackbar(
        'Thành công',
        'Đã tạo đơn hàng ${order.orderCode}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      clearCart();
      clearCustomer();
    } else {
      Get.snackbar(
        'Lỗi tạo đơn',
        result.message ?? 'Không thể tạo đơn hàng',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ── Format ────────────────────────────────────────────────────
  String formatCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M đ';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K đ';
    }
    return '${value.toStringAsFixed(0)} đ';
  }
}