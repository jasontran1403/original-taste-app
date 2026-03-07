// order_cart_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:original_taste/helper/services/seller_services.dart';

class _QtyFormatter extends TextInputFormatter {
  static final _instance = _QtyFormatter._();
  _QtyFormatter._();
  static TextInputFormatter get instance => _instance;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue next) {
    if (next.text.isEmpty) return next;
    if (!RegExp(r'^\d*\.?\d{0,2}$').hasMatch(next.text)) return old;
    return next;
  }
}

class OrderCartController extends GetxController
    with GetTickerProviderStateMixin {
  // ── Data ───────────────────────────────────────────────────────
  List<ProductModel> allProducts = [];
  List<ProductModel> filteredProducts = [];
  List<CategoryModel> categories = [];
  bool isLoadingProducts = false;

  // ── Filter ─────────────────────────────────────────────────────
  String searchQuery = '';
  CategoryModel? selectedCategory;
  String sortMode = 'name_asc';

  // ── Cart ───────────────────────────────────────────────────────
  final List<CartItem> cartItems = [];

  // ── Customer ───────────────────────────────────────────────────
  SelectedCustomer? selectedCustomer;

  // ── Chế độ đơn (Lẻ / Sỉ) ─────────────────────────────────────
  OrderMode orderMode = OrderMode.wholesale;

  // ── Options ────────────────────────────────────────────────────
  String paymentMethod = 'CASH';
  String orderNotes = '';
  bool isSubmitting = false;

  // ── Animated summary values ────────────────────────────────────
  late AnimationController _animCtrl;
  double _fromSubtotal = 0, _fromDiscount = 0, _fromVat = 0, _fromGrand = 0;

  // Công khai để GetBuilder['summary'] đọc
  double animSubtotal = 0;
  double animDiscount = 0;
  double animVat = 0;
  double animGrand = 0;

  static TextInputFormatter get qtyFormatter => _QtyFormatter.instance;

  // ── Lifecycle ──────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..addListener(() {
      final t = Curves.easeOutCubic.transform(_animCtrl.value);
      animSubtotal = _lerp(_fromSubtotal, subtotal, t);
      animDiscount = _lerp(_fromDiscount, discountAmount, t);
      animVat      = _lerp(_fromVat, vatAmount, t);
      animGrand    = _lerp(_fromGrand, grandTotal, t);
      update(['summary']);
    });
    _snapAnimValues();
    _loadData();
  }

  @override
  void onClose() {
    _animCtrl.dispose();
    for (final item in cartItems) item.dispose();
    super.onClose();
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  void _snapAnimValues() {
    animSubtotal = subtotal;
    animDiscount = discountAmount;
    animVat      = vatAmount;
    animGrand    = grandTotal;
  }

  void _kick() {
    update(); // Luôn rebuild UI ngay lập tức
    if (_animCtrl.isAnimating) return; // Không restart animation nếu đang chạy
    _fromSubtotal = animSubtotal;
    _fromDiscount = animDiscount;
    _fromVat      = animVat;
    _fromGrand    = animGrand;
    // Guard: tránh crash nếu controller đã dispose (submitOrder → clearCart)
    try { _animCtrl.forward(from: 0); } catch (_) {}
  }

  // ── Load ───────────────────────────────────────────────────────
  Future<void> _loadData() async {
    isLoadingProducts = true;
    update();
    final catR = await SellerService.getCategories();
    if (catR.isSuccess && catR.data != null) categories = catR.data!;
    final prodR = await SellerService.getProducts(page: 0, size: 200);
    if (prodR.isSuccess && prodR.data != null) allProducts = prodR.data!;
    isLoadingProducts = false;
    _applyFilter();
  }

  Future<void> refreshProducts() => _loadData();

  // ── Order mode ─────────────────────────────────────────────────
  // Gọi sau khi user đã xác nhận (dialog xử lý ở UI layer)
  void setOrderModeConfirmed(OrderMode mode) {
    if (orderMode == mode) return;
    orderMode = mode;
    // Clear giỏ hàng khi đổi chế độ
    for (final item in cartItems) item.dispose();
    cartItems.clear();
    _applyFilter();
    _kick();
  }

  // ── Cart ops ───────────────────────────────────────────────────
  void addToCart(ProductModel product, {ProductVariantModel? variant}) {
    final existing = cartItems.firstWhereOrNull(
            (c) => c.product.id == product.id && c.variant?.id == variant?.id);

    if (existing != null) {
      existing.quantity =
          double.parse((existing.quantity + 1.0).toStringAsFixed(2));
      existing.qtyController.text = _fmtQ(existing.quantity);
    } else {
      final item = CartItem(
        product: product,
        variant: variant,
        quantity: 1.0,
        orderMode: orderMode,
      );
      // Lẻ: luôn dùng basePrice (priceMode.base), không dùng tier
      if (orderMode == OrderMode.retail) {
        item.priceMode = ItemPriceMode.base;
        item.selectedTier = null;
      }
      cartItems.add(item);
    }
    _kick();
  }

  void removeFromCart(int index) {
    cartItems[index].dispose();
    cartItems.removeAt(index);
    _kick();
  }

  void clearCart() {
    for (final item in cartItems) item.dispose();
    cartItems.clear();
    _kick();
  }

  // ── Qty ────────────────────────────────────────────────────────
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
      _kick();
    }
  }

  void onQtySubmitted(CartItem item) {
    final parsed = double.tryParse(item.qtyController.text);
    item.quantity = (parsed != null && parsed >= 0.01) ? parsed : 0.01;
    item.qtyController.text = _fmtQ(item.quantity);
    _kick();
  }

  void incrementQty(CartItem item) {
    item.quantity = double.parse((item.quantity + 1.0).toStringAsFixed(2));
    item.qtyController.text = _fmtQ(item.quantity);
    _kick();
  }

  void decrementQty(CartItem item) {
    item.quantity = double.parse(
        (item.quantity - 1.0).clamp(0.01, 99999.0).toStringAsFixed(2));
    item.qtyController.text = _fmtQ(item.quantity);
    _kick();
  }

  // ── Price mode ops ─────────────────────────────────────────────

  void selectTierForItem(CartItem item, ProductPriceTierModel tier) {
    item.priceMode = ItemPriceMode.tier;
    item.selectedTier = tier;
    item.discountPercent = null;
    _kick();
  }

  void selectBasePriceForItem(CartItem item) {
    item.priceMode = ItemPriceMode.base;
    item.selectedTier = null;
    item.discountPercent = null;
    _kick();
  }

  /// percent: 1–100
  void setDiscountPercentForItem(CartItem item, int percent) {
    item.priceMode = ItemPriceMode.discountPercent;
    item.selectedTier = null;
    item.discountPercent = percent.clamp(1, 100);
    _kick();
  }

  void resetToAutoTier(CartItem item) {
    item.priceMode = ItemPriceMode.tier;
    item.selectedTier = null;
    item.discountPercent = null;
    _kick();
  }

  // ── Totals ─────────────────────────────────────────────────────
  /// Đơn giá hiệu lực của item, override CartItem.subtotal khi ở chế độ Lẻ
  double effectiveUnitPrice(CartItem item) {
    if (orderMode == OrderMode.retail) {
      // Chế độ Lẻ: luôn dùng basePrice, bỏ qua tier
      if (item.priceMode == ItemPriceMode.discountPercent) {
        final pct = item.discountPercent ?? 0;
        return item.product.basePrice * (100 - pct) / 100;
      }
      return item.product.basePrice;
    }
    // Chế độ Sỉ: dùng CartItem.subtotal / quantity (giữ nguyên logic cũ)
    return item.quantity > 0 ? item.subtotal / item.quantity : item.product.basePrice;
  }

  double effectiveSubtotal(CartItem item) =>
      effectiveUnitPrice(item) * item.quantity;

  double get subtotal => cartItems.fold(0.0, (s, c) => s + effectiveSubtotal(c));

  double get discountAmount {
    final rate = selectedCustomer?.discountRate ?? 0;
    return subtotal * rate / 100;
  }

  double get afterDiscount => subtotal - discountAmount;

  /// VAT tổng = tính trên afterDiscount, phân bổ theo tỷ lệ subtotal từng item
  double get vatAmount {
    if (cartItems.isEmpty || subtotal == 0) return 0.0;
    double total = 0.0;
    for (final item in cartItems) {
      final vatRate = item.product.vatRate;
      if (vatRate <= 0) continue;
      final proportion = item.subtotal / subtotal;
      final itemAfterDisc = afterDiscount * proportion;
      total += itemAfterDisc * vatRate / 100;
    }
    return total;
  }

  /// VAT breakdown theo từng mức (5%, 8%, 10%)
  Map<int, double> get vatBreakdown {
    if (cartItems.isEmpty || subtotal == 0) return {};
    final map = <int, double>{};
    for (final item in cartItems) {
      final vatRate = item.product.vatRate;
      if (vatRate <= 0) continue;
      final proportion = item.subtotal / subtotal;
      final itemAfterDisc = afterDiscount * proportion;
      final vat = itemAfterDisc * vatRate / 100;
      map[vatRate] = (map[vatRate] ?? 0) + vat;
    }
    return map;
  }

  double get grandTotal => afterDiscount + vatAmount;

  // ── Customer ───────────────────────────────────────────────────
  void setCustomer(SelectedCustomer c) {
    selectedCustomer = c;
    _kick();
  }

  void clearCustomer() {
    selectedCustomer = null;
    _kick();
  }

  bool get canCreateOrder {
    if (cartItems.isEmpty || isSubmitting) return false;
    if (selectedCustomer == null) return false; // bắt buộc cả lẻ lẫn sỉ
    return true;
  }

  // ── Filter / Sort ──────────────────────────────────────────────
  void onSearch(String q) { searchQuery = q.trim().toLowerCase(); _applyFilter(); }
  void onSelectCategory(CategoryModel? c) { selectedCategory = c; _applyFilter(); }
  void onSortMode(String m) { sortMode = m; _applyFilter(); }

  void _applyFilter() {
    var list = List<ProductModel>.from(allProducts);
    if (selectedCategory != null) {
      list = list.where((p) => p.categoryId == selectedCategory!.id).toList();
    }
    if (searchQuery.isNotEmpty) {
      list = list.where((p) => p.name.toLowerCase().contains(searchQuery)).toList();
    }
    switch (sortMode) {
      case 'name_asc':  list.sort((a, b) => a.name.compareTo(b.name));
      case 'name_desc': list.sort((a, b) => b.name.compareTo(a.name));
      case 'price_asc': list.sort((a, b) => a.basePrice.compareTo(b.basePrice));
      case 'price_desc':list.sort((a, b) => b.basePrice.compareTo(a.basePrice));
    }
    filteredProducts = list;
    update();
  }

  // ── Submit ─────────────────────────────────────────────────────
  Future<void> submitOrder() async {
    if (!canCreateOrder) return;
    isSubmitting = true;
    update();

    final request = CreateOrderRequest(
      customerName: selectedCustomer?.name,
      customerPhone: selectedCustomer?.phone,
      customerEmail: selectedCustomer?.email.isEmpty == true
          ? null : selectedCustomer?.email,
      shippingAddress: selectedCustomer?.address.isEmpty == true
          ? null : selectedCustomer?.address,
      paymentMethod: paymentMethod,
      type: orderMode == OrderMode.wholesale ? 'WHOLESALE' : 'RETAIL',
      notes: orderNotes.isEmpty ? null : orderNotes,
      items: cartItems.map((c) => CreateOrderItemRequest(
        productId: c.product.id,
        variantId: c.variant?.id,
        quantity: c.quantity,
        priceMode: c.priceMode.apiValue,
        tierId: c.priceMode == ItemPriceMode.tier ? c.selectedTier?.id : null,
        discountPercent: c.priceMode == ItemPriceMode.discountPercent
            ? c.discountPercent : null,
        notes: null,
      )).toList(),
    );

    final result = await SellerService.createOrder(request);
    isSubmitting = false;
    update();

    if (result.isSuccess && result.data != null) {
      Get.snackbar('Thành công', 'Đã tạo đơn ${result.data!.orderCode}',
          backgroundColor: Colors.green, colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          forwardAnimationCurve: Curves.easeOutBack,
          duration: const Duration(seconds: 3));
      clearCart();
      clearCustomer();
    } else {
      Get.snackbar('Lỗi', result.message ?? 'Không thể tạo đơn hàng',
          backgroundColor: Colors.red, colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          forwardAnimationCurve: Curves.easeOutBack);
    }
  }

  // ── Helpers ────────────────────────────────────────────────────
  String formatCurrency(double v) => NumberFormat('#,###', 'vi_VN').format(v);

  static String _fmtQ(double q) =>
      q == q.truncateToDouble() ? q.toInt().toString() : q.toStringAsFixed(2);
}