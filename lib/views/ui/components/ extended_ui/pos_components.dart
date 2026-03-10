import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:original_taste/helper/services/pos_service.dart';
import 'package:original_taste/views/ui/components/%20extended_ui/pos/import_stock_screen.dart';
import 'package:original_taste/views/ui/components/%20extended_ui/pos/shift_screen.dart';

class PosComponents extends StatefulWidget {
  const PosComponents({super.key});

  @override
  State<PosComponents> createState() => _PosComponentsState();
}

class _PosComponentsState extends State<PosComponents> {
  PosCategoryModel? _selectedCategory;
  String _orderMode = 'OFFLINE';
  String _paymentMethod = 'CASH'; // CASH | TRANSFER
  bool _isLoadingProducts = false;
  bool _isLoadingCategories = true;
  bool _isCreatingOrder = false;
  final ScrollController _cartScrollController = ScrollController();

  List<PosCategoryModel> _categories = [];
  List<PosProductModel> _products = [];
  PosShiftModel? _currentShift;

  final List<CartItem> _cart = [];

  bool get _canOrderShopee => _cart.every((item) => item.product.isShopeeFood);
  bool get _canOrderGrab => _cart.every((item) => item.product.isGrabFood);

  double get _subTotal => _cart.fold(0, (sum, item) => sum + item.subtotal);

  Map<int, double> get _vatBreakdown {
    final map = <int, double>{};
    for (final item in _cart) {
      final pct = item.product.vatPercent;
      if (pct > 0) {
        map[pct] = (map[pct] ?? 0) + item.subtotal * pct / 100;
      }
    }
    return map;
  }

  double get _totalVat => _vatBreakdown.values.fold(0, (s, v) => s + v);
  double get _grandTotal => _subTotal + _totalVat;
  int get _cartItemCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _cartScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([_loadCategories(), _loadCurrentShift()]);
  }

  Future<void> _loadCurrentShift() async {
    final shift = await PosService.getCurrentShift();
    if (mounted) setState(() => _currentShift = shift);
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await PosService.getCategories();
      if (mounted) {
        setState(() {
          _categories = cats;
          _isLoadingCategories = false;
          if (cats.isNotEmpty) {
            _selectedCategory = cats.first;
            _loadProducts(cats.first.id);
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _loadProducts(int categoryId) async {
    setState(() => _isLoadingProducts = true);
    try {
      final products = await PosService.getProducts(categoryId: categoryId);
      if (mounted) {
        setState(() {
          _products = [...products]..sort((a, b) {
            final aOrder = a.displayOrder == 0 ? 999999 : a.displayOrder;
            final bOrder = b.displayOrder == 0 ? 999999 : b.displayOrder;
            final cmp = aOrder.compareTo(bOrder);
            return cmp != 0 ? cmp : a.name.compareTo(b.name);
          });
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoadingProducts = false);
    }
  }

  Future<void> _changeCategory(PosCategoryModel cat) async {
    if (_selectedCategory?.id == cat.id) return;
    setState(() => _selectedCategory = cat);
    await _loadProducts(cat.id);
  }

  void _onShiftChanged(PosShiftModel? shift) {
    setState(() {
      _currentShift = shift;
      if (shift == null) _cart.clear();
    });
  }

  void _openShiftScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShiftScreen(
          currentShift: _currentShift,
          onShiftChanged: _onShiftChanged,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // QUICK ADD LOGIC
  // ══════════════════════════════════════════════════════════════

  /// Full-auto variant: tất cả NL có maxSelectableCount > 0
  /// VÀ SUM(maxSelectableCount) == minSelect == maxSelect
  bool _isFullAutoVariant(PosVariantModel v) {
    if (v.isAddonGroup) return false;
    if (v.ingredients.isEmpty) return false;
    if (v.ingredients.any((i) => (i.maxSelectableCount ?? 0) <= 0)) return false;
    final totalRequired = v.ingredients.fold(0, (s, i) => s + (i.maxSelectableCount ?? 0));
    return v.minSelect > 0 &&
        v.minSelect == v.maxSelect &&
        v.minSelect == totalRequired;
  }

  /// Lấy "default variant" để quick-add:
  /// - Nếu chỉ có 1 regular variant → đó là default
  /// - Nếu có nhiều → dùng variant có isDefault = true (khi field đó tồn tại)
  ///   hoặc variant đầu tiên là full-auto
  /// Trả về null nếu không thể xác định default (cần user chọn thủ công)
  PosVariantModel? _getDefaultRegularVariant(PosProductModel product) {
    final regularGroups = product.variants.where((v) => !v.isAddonGroup).toList();
    if (regularGroups.isEmpty) return null;

    // Chỉ 1 variant → đó là default
    if (regularGroups.length == 1) return regularGroups.first;

    // Nhiều variant: tìm cái có isDefault == true (field sẽ thêm sau)
    // Tạm thời: dùng cái đầu tiên là full-auto (nếu có)
    // TODO: thay bằng: regularGroups.where((v) => v.isDefault).firstOrNull
    final firstFullAuto = regularGroups.where(_isFullAutoVariant).firstOrNull;
    return firstFullAuto; // null nếu không có full-auto nào
  }

  /// Kiểm tra có thể quick-add không:
  /// - Không có regular variant → luôn được
  /// - Có regular variant và xác định được default → được
  /// - Nhiều variant, không có default → không được
  bool _canQuickAdd(PosProductModel product) {
    final regularGroups = product.variants.where((v) => !v.isAddonGroup).toList();
    if (regularGroups.isEmpty) return true;
    return _getDefaultRegularVariant(product) != null;
  }


  List<VariantGroupSelection> _buildQuickAddSelections(PosProductModel product) {
    final regularGroups = product.variants.where((v) => !v.isAddonGroup).toList();
    final List<VariantGroupSelection> selections = [];

    // Tự động chọn tất cả group bắt buộc (minSelect > 0)
    for (final v in regularGroups.where((v) => v.minSelect > 0)) {
      // Ưu tiên dùng _autoDistributeIngredients nếu full-auto, fallback _autoFillIngredients
      final ingredients = _isFullAutoVariant(v)
          ? _autoDistributeIngredients(v)
          : _autoFillIngredients(v);

      selections.add(VariantGroupSelection(
        variantId: v.id,
        groupName: v.groupName,
        isAddonGroup: false,
        selectedIngredients: ingredients,
        addonItems: null,
      ));
    }

    // Nếu không có group bắt buộc → fallback group đầu tiên (nếu có)
    if (selections.isEmpty && regularGroups.isNotEmpty) {
      final first = regularGroups.first;
      selections.add(VariantGroupSelection(
        variantId: first.id,
        groupName: first.groupName,
        isAddonGroup: false,
        selectedIngredients: _autoFillIngredients(first),
        addonItems: null,
      ));
    }

    print('Quick Add selections for ${product.name}: ${selections.length} groups');
    for (var sel in selections) {
      print('  - ${sel.groupName} (id: ${sel.variantId}) → ${sel.selectedIngredients}');
    }

    return selections;
  }

  /// Trả về VariantGroupSelection rỗng (variantId=0) để modal tự auto-check
  /// theo logic minSelect > 0 trong initState
  VariantGroupSelection _autoSelectRegularVariant(PosProductModel product) {
    return VariantGroupSelection(
      variantId: 0,
      groupName: '',
      isAddonGroup: false,
      selectedIngredients: {},
      addonItems: null,
    );
  }

  // ══════════════════════════════════════════════════════════════
  // NAVIGATION / MODAL FLOW
  // ══════════════════════════════════════════════════════════════

  void _onTapProduct(PosProductModel product) {
    if (_currentShift == null || !_currentShift!.isOpen) {
      _showNoShiftToast();
      return;
    }
    // Mode app: dùng giá Shopee/Grab trực tiếp
    if (_orderMode != 'OFFLINE') {
      final menu = product.appMenus
          .where((m) => m.platform == _orderMode && m.isActive)
          .firstOrNull;
      if (menu != null) {
        final price = PriceOption(
          discountPercent: 0,
          price: menu.price,
          label: _orderMode == 'SHOPEE_FOOD' ? 'Giá Shopee' : 'Giá Grab',
        );
        _showQuickAddPopup(product, fixedPrice: price);
        return;
      }
    }
    _showQuickAddPopup(product);
  }

  /// Popup 3 nút: Chọn giá | Biến thể/Addon | Thêm nhanh
  void _showQuickAddPopup(PosProductModel product, {PriceOption? fixedPrice}) {
    final hasVariantOrAddon = product.variants.isNotEmpty;
    final canQuickAdd = _canQuickAdd(product);
    final defaultPrice = fixedPrice ?? product.priceOptions.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QuickAddSheet(
        product: product,
        initialPrice: defaultPrice,
        fixedPrice: fixedPrice,
        hasVariantOrAddon: hasVariantOrAddon,
        canQuickAdd: canQuickAdd,
        onOpenPriceModal: fixedPrice != null
            ? null // app mode: giá cố định, không cho đổi
            : (currentPrice) async {
          PriceOption? chosen;
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => _PriceSelectionModal(
              product: product,
              onPriceSelected: (p) {
                chosen = p;
                Navigator.pop(context);
              },
            ),
          );
          return chosen;
        },
        onOpenVariantModal: (price) {
          Navigator.pop(context);
          _showVariantModal(product, price);
        },
        onQuickAdd: (price) {
          Navigator.pop(context);
          final selections = _buildQuickAddSelections(product);
          _addToCart(CartItem(
            product: product,
            selectedPrice: price,
            variantSelections: selections,
            quantity: 1,
            note: null,
          ));
        },
      ),
    );
  }

  void _showVariantModal(PosProductModel product, PriceOption price) {
    final initialSelection = _autoSelectRegularVariant(product);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MultiVariantSelectionModal(
        product: product,
        selectedPrice: price,
        initialSelection: initialSelection,
        onConfirm: (selections, note) {
          Navigator.pop(context);
          _addToCart(CartItem(
            product: product,
            selectedPrice: price,
            variantSelections: selections,
            quantity: 1,
            note: note,
          ));
        },
      ),
    );
  }

  void _addToCart(CartItem newItem) {
    setState(() {
      final idx = _cart.indexWhere(
            (c) =>
        c.product.id == newItem.product.id &&
            c.selectedPrice.discountPercent ==
                newItem.selectedPrice.discountPercent &&
            _selectionsEqual(c.variantSelections, newItem.variantSelections),
      );
      if (idx >= 0) {
        _cart[idx] = _cart[idx].copyWith(quantity: _cart[idx].quantity + 1);
      } else {
        _cart.add(newItem);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_cartScrollController.hasClients) {
        _cartScrollController.animateTo(
          _cartScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool _selectionsEqual(List<VariantGroupSelection> a, List<VariantGroupSelection> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].variantId != b[i].variantId) return false;
      if (!_mapEquals(a[i].selectedIngredients, b[i].selectedIngredients)) return false;
    }
    return true;
  }

  bool _mapEquals(Map<int, int> a, Map<int, int> b) {
    if (a.length != b.length) return false;
    for (final k in a.keys) {
      if (a[k] != b[k]) return false;
    }
    return true;
  }

  void _updateQty(int index, int change) {
    setState(() {
      final newQty = _cart[index].quantity + change;
      if (newQty <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index] = _cart[index].copyWith(quantity: newQty);
      }
    });
  }

  void _removeFromCart(int index) => setState(() => _cart.removeAt(index));

  Future<void> _createOrder({required String orderSource}) async {
    if (_cart.isEmpty) return;
    if (_currentShift == null || !_currentShift!.isOpen) {
      _showNoShiftToast();
      return;
    }
    setState(() => _isCreatingOrder = true);
    try {
      final order = await PosService.createOrder(
        orderSource: orderSource,
        paymentMethod: _paymentMethod,
        cartItems: _cart,
      );
      setState(() => _cart.clear());
      _showOrderSuccessDialog(order);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tạo đơn: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isCreatingOrder = false);
    }
  }

  void _showOrderSuccessDialog(PosOrderModel order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Tạo đơn thành công', style: TextStyle(color: Colors.green)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mã đơn: ${order.orderCode}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Tổng tiền: ${_formatMoney(order.finalAmount)}đ'),
            Text('Số món: ${order.items.length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Đóng', style: TextStyle(color: Colors.deepOrange)),
          ),
        ],
      ),
    );
  }

  void _showNoShiftToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chưa mở ca làm việc. Vui lòng mở ca để bán hàng.'),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openImportStockScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ImportStockScreen(),
      ),
    );
  }

  String _formatMoney(double amount) => amount
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  // ══════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 800;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── LEFT: Menu ──
        Expanded(
          flex: isTablet ? 12 : 10,
          child: Column(
            children: [
              Container(
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: _buildTopMenuContent()),
                          const SizedBox(width: 12),
                          if (_currentShift?.isOpen == true) ...[
                            // Nút Nhập kho (chỉ khi ca mở)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.inventory_2_outlined, size: 20),
                                label: const Text('Nhập kho',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: _openImportStockScreen,
                              ),
                            ),
                            // Nút Đóng ca
                            ElevatedButton.icon(
                              icon: const Icon(Icons.power_settings_new, size: 20),
                              label: const Text('Đóng ca',
                                  style: TextStyle(fontSize: 15)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _openShiftScreen,
                            ),
                          ] else
                          // Nút Mở ca
                            ElevatedButton.icon(
                              icon: const Icon(Icons.play_arrow, size: 20),
                              label: const Text('Mở ca',
                                  style: TextStyle(fontSize: 15)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _openShiftScreen,
                            ),
                        ],
                      ),
                    ),
                    if (_isLoadingCategories)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: SizedBox(
                          height: 110,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: SizedBox(
                          height: 110,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: _categories.map((cat) => _buildCategoryTab(cat)).toList(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoadingProducts
                    ? const Center(child: CircularProgressIndicator())
                    : _products.isEmpty
                    ? const Center(
                  child: Text('Không có sản phẩm',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                )
                    : SingleChildScrollView(
                  padding: EdgeInsets.all(isTablet ? 8 : 4),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 4 : 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      mainAxisExtent: 260,
                    ),
                    itemCount: _products.length,
                    itemBuilder: (_, i) {
                      final product = _products[i];
                      final cartQty = _cart
                          .where((c) => c.product.id == product.id)
                          .fold(0, (sum, c) => sum + c.quantity);
                      final bool productEnabled = _orderMode == 'OFFLINE' ||
                          (_orderMode == 'SHOPEE_FOOD' && product.isShopeeFood) ||
                          (_orderMode == 'GRAB_FOOD' && product.isGrabFood);
                      return GestureDetector(
                        onTap: productEnabled ? () => _onTapProduct(product) : null,
                        child: Stack(
                          children: [
                            _buildProductCard(product),
                            if (!productEnabled)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.55),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(6)),
                                      child: Text(
                                        _orderMode == 'SHOPEE_FOOD'
                                            ? 'Không bán\nShopee'
                                            : 'Không bán\nGrab',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (cartQty > 0)
                              Positioned(
                                right: 4,
                                top: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                      color: Colors.blueAccent,
                                      shape: BoxShape.circle),
                                  child: Text('$cartQty',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── RIGHT: Cart ── (giữ nguyên phần cart)
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: Colors.grey[300]!, width: 1)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Giỏ hàng ($_cartItemCount)',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      if (_cart.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                          onPressed: () => setState(() => _cart.clear()),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        controller: _cartScrollController,
                        padding: const EdgeInsets.fromLTRB(4, 0, 4, 260),
                        child: _cart.isEmpty
                            ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 80),
                          child: Center(
                              child: Text('Chưa có món nào',
                                  style: TextStyle(fontSize: 16, color: Colors.grey))),
                        )
                            : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _cart.length,
                          separatorBuilder: (_, __) =>
                              Divider(height: 1, color: Colors.grey[300]),
                          itemBuilder: (_, i) => _buildCartItem(i),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: _buildCartSummary(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopMenuContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _currentShift?.isOpen == true ? _currentShift!.staffName : 'Original Taste POS',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        const _ClockWidget(),
      ],
    );
  }

  Widget _buildCategoryTab(PosCategoryModel cat) {
    final isActive = _selectedCategory?.id == cat.id;
    String? versionedUrl;
    if (cat.imageUrl != null && cat.imageUrl!.isNotEmpty) {
      versionedUrl = "${PosService.buildImageUrl(cat.imageUrl)}?v=${cat.imageUrl.hashCode}";
    }
    return GestureDetector(
      onTap: () => _changeCategory(cat),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isActive
              ? Border.all(color: Colors.deepOrange, width: 2)
              : Border.all(color: Colors.grey[300]!),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 4)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (versionedUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: versionedUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) =>
                      Icon(Icons.category, size: 40, color: Colors.grey[400]),
                ),
              )
            else
              Icon(Icons.category, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 6),
            Text(
              cat.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.deepOrange : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(PosProductModel product) {
    String? versionedUrl;
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      versionedUrl = "${PosService.buildImageUrl(product.imageUrl)}?v=${product.imageUrl.hashCode}";
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: versionedUrl != null
                ? CachedNetworkImage(
              imageUrl: versionedUrl,
              height: 150,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 150,
                color: Colors.grey[100],
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (_, __, ___) => Container(
                height: 150,
                color: Colors.grey[100],
                child: Icon(Icons.fastfood, size: 60, color: Colors.grey[400]),
              ),
            )
                : Container(
              height: 150,
              color: Colors.grey[100],
              child: Icon(Icons.fastfood, size: 60, color: Colors.grey[400]),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Builder(builder: (_) {
                    final appMenu = _orderMode != 'OFFLINE'
                        ? product.appMenus
                        .where((m) => m.platform == _orderMode && m.isActive)
                        .firstOrNull
                        : null;
                    final displayPrice = appMenu?.price ?? product.basePrice;
                    return Text(
                      '${_formatMoney(displayPrice)}đ',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                    );
                  }),
                  Builder(builder: (_) {
                    final hasRegular = product.variants.any((v) => !v.isAddonGroup);
                    final hasAddon = product.variants.any((v) => v.isAddonGroup);
                    if (hasRegular && hasAddon)
                      return const Text('Biến thể + Addon',
                          style: TextStyle(fontSize: 11, color: Colors.deepOrange));
                    if (hasRegular)
                      return const Text('Chọn biến thể',
                          style: TextStyle(fontSize: 11, color: Colors.blue));
                    if (hasAddon)
                      return const Text('Có món thêm addon',
                          style: TextStyle(fontSize: 11, color: Colors.deepOrange));
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(int index) {
    final item = _cart[index];
    String? versionedUrl;
    if (item.product.imageUrl != null && item.product.imageUrl!.isNotEmpty) {
      versionedUrl =
      "${PosService.buildImageUrl(item.product.imageUrl)}?v=${item.product.imageUrl.hashCode}";
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: versionedUrl != null
                ? CachedNetworkImage(
              imageUrl: versionedUrl,
              width: 54,
              height: 54,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 54,
                height: 54,
                color: Colors.grey[200],
                child: const Icon(Icons.fastfood, color: Colors.grey),
              ),
            )
                : Container(
              width: 54,
              height: 54,
              color: Colors.grey[200],
              child: const Icon(Icons.fastfood, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      onPressed: () => _removeFromCart(index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                if (item.selectedPrice.discountPercent > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(item.selectedPrice.label,
                        style: const TextStyle(fontSize: 11, color: Colors.green)),
                  ),
                if (item.variantSelections.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  ..._buildIngredientLines(item),
                ],
                if (item.addonTotal > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text('+${_formatMoney(item.addonTotal)}đ addon',
                        style: const TextStyle(fontSize: 11, color: Colors.deepOrange)),
                  ),
                if (item.note != null && item.note!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.notes, size: 12, color: Colors.blueGrey),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(item.note!,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.blueGrey,
                                  fontStyle: FontStyle.italic)),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_formatMoney(item.selectedPrice.price)}đ',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                    ),
                    Row(
                      children: [
                        _qtyButton(Icons.remove, () => _updateQty(index, -1)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(6)),
                          child: Text('${item.quantity}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        _qtyButton(Icons.add, () => _updateQty(index, 1)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildIngredientLines(CartItem item) {
    final Map<int, int> allSelected = {};
    for (final sel in item.variantSelections) {
      for (final entry in sel.selectedIngredients.entries) {
        allSelected[entry.key] = (allSelected[entry.key] ?? 0) + entry.value;
      }
    }
    final Map<int, String> ingNames = {};
    for (final v in item.product.variants) {
      for (final vi in v.ingredients) {
        ingNames[vi.ingredientId] = vi.ingredientName;
      }
    }
    return allSelected.entries.where((e) => e.value > 0).map((e) {
      final name = ingNames[e.key] ?? '#${e.key}';
      return Padding(
        padding: const EdgeInsets.only(top: 1),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.only(right: 5, top: 1),
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.deepOrange),
            ),
            Text('$name x${e.value}',
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      );
    }).toList();
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 22, color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildCartSummary() {
    final vatBreakdown = _vatBreakdown;
    final sortedVat = vatBreakdown.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1)),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _OrderModeSelector(
            currentMode: _orderMode,
            canShopee: _canOrderShopee,
            canGrab: _canOrderGrab,
            onChanged: (mode) => setState(() => _orderMode = mode),
          ),
          const SizedBox(height: 8),
          _summaryRow('Tạm tính', _subTotal),
          if (sortedVat.isNotEmpty) ...[
            const SizedBox(height: 3),
            ...sortedVat.map((e) => Padding(
              padding: const EdgeInsets.only(top: 2),
              child: _summaryRow('Thuế VAT ${e.key}%', e.value, isVat: true),
            )),
          ],
          const Divider(height: 12),
          _summaryRow('Tổng cộng', _grandTotal, isTotal: true),
          const SizedBox(height: 10),
          _PaymentMethodSelector(
            current: _paymentMethod,
            onChanged: (v) => setState(() => _paymentMethod = v),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: _orderButton(
              label: _orderMode == 'OFFLINE'
                  ? 'Tạo đơn Offline'
                  : _orderMode == 'SHOPEE_FOOD'
                  ? 'Tạo đơn ShopeeFood'
                  : 'Tạo đơn GrabFood',
              icon: _orderMode == 'OFFLINE'
                  ? Icons.storefront_outlined
                  : _orderMode == 'SHOPEE_FOOD'
                  ? Icons.shopping_bag_outlined
                  : Icons.delivery_dining,
              color: _orderMode == 'OFFLINE'
                  ? Colors.lightBlue
                  : _orderMode == 'SHOPEE_FOOD'
                  ? const Color(0xFFEE4D2D)
                  : const Color(0xFF00B14F),
              source: _orderMode,
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderButton({
    required String label,
    required IconData icon,
    required Color color,
    required String source,
  }) {
    final disabled = _cart.isEmpty || _isCreatingOrder;
    return SizedBox(
      height: 46,
      child: ElevatedButton.icon(
        icon: _isCreatingOrder
            ? const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
            : Icon(icon, size: 17),
        label: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: disabled ? Colors.grey[300] : color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: disabled ? 0 : 2,
        ),
        onPressed: disabled ? null : () => _createOrder(orderSource: source),
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool isTotal = false, bool isVat = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            fontSize: isTotal ? 16 : 14,
            color: isVat ? Colors.grey[600] : Colors.black87,
          ),
        ),
        Text(
          '+${_formatMoney(value)}đ',
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            fontSize: isTotal ? 16 : 14,
            color: isTotal ? Colors.black : Colors.black87,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
// QUICK ADD SHEET — popup 3 nút khi tap sản phẩm
// ════════════════════════════════════════════════════════════════

class _QuickAddSheet extends StatefulWidget {
  final PosProductModel product;
  final PriceOption initialPrice;
  final PriceOption? fixedPrice; // non-null = không cho đổi giá (app mode)
  final bool hasVariantOrAddon;
  final bool canQuickAdd;
  final Future<PriceOption?> Function(PriceOption)? onOpenPriceModal;
  final void Function(PriceOption) onOpenVariantModal;
  final void Function(PriceOption) onQuickAdd;

  const _QuickAddSheet({
    required this.product,
    required this.initialPrice,
    this.fixedPrice,
    required this.hasVariantOrAddon,
    required this.canQuickAdd,
    required this.onOpenPriceModal,
    required this.onOpenVariantModal,
    required this.onQuickAdd,
  });

  @override
  State<_QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<_QuickAddSheet> {
  late PriceOption _selectedPrice;

  @override
  void initState() {
    super.initState();
    _selectedPrice = widget.initialPrice;
  }

  String _fmt(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    final bool priceChangeable =
        widget.fixedPrice == null && widget.product.priceOptions.length > 1;
    final bool isFree = _selectedPrice.discountPercent == 100;
    final bool hasDiscount = _selectedPrice.discountPercent > 0 && !isFree;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).padding.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ──
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),

          // ── Product info row ──
          Row(
            children: [
              if (widget.product.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: PosService.buildImageUrl(widget.product.imageUrl),
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 52,
                      height: 52,
                      color: Colors.grey[200],
                      child: const Icon(Icons.fastfood, color: Colors.grey),
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.product.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          isFree ? 'Miễn phí' : '${_fmt(_selectedPrice.price)}đ',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isFree ? Colors.red : Colors.deepOrange,
                          ),
                        ),
                        if (hasDiscount) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '-${_selectedPrice.discountPercent}%',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        if (isFree) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('FREE',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // ══════════════════════════════════════
          // 3 NÚT CHÍNH
          // ══════════════════════════════════════
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── NÚT 1: Chọn giá ──
                Expanded(
                  child: _ActionButton(
                    icon: Icons.local_offer_outlined,
                    label: 'Chọn giá',
                    sublabel: _selectedPrice.label,
                    color: Colors.indigo,
                    enabled: priceChangeable,
                    onTap: priceChangeable
                        ? () async {
                      final chosen =
                      await widget.onOpenPriceModal!(_selectedPrice);
                      if (chosen != null && mounted) {
                        setState(() => _selectedPrice = chosen);
                      }
                    }
                        : null,
                  ),
                ),
                const SizedBox(width: 10),

                // ── NÚT 2: Biến thể / Addon ──
                Expanded(
                  child: _ActionButton(
                    icon: Icons.tune_outlined,
                    label: 'Tùy chỉnh',
                    sublabel: widget.hasVariantOrAddon
                        ? 'Biến thể & Addon'
                        : 'Không có',
                    color: Colors.teal,
                    enabled: widget.hasVariantOrAddon,
                    onTap: widget.hasVariantOrAddon
                        ? () => widget.onOpenVariantModal(_selectedPrice)
                        : null,
                  ),
                ),
                const SizedBox(width: 10),

                // ── NÚT 3: Thêm nhanh ──
                Expanded(
                  child: _ActionButton(
                    icon: Icons.add_shopping_cart,
                    label: 'Thêm nhanh',
                    sublabel: widget.canQuickAdd ? 'Giá gốc' : 'Cần chọn\nbiến thể',
                    color: Colors.deepOrange,
                    enabled: widget.canQuickAdd,
                    isPrimary: true,
                    onTap: widget.canQuickAdd
                        ? () => widget.onQuickAdd(_selectedPrice)
                        : null,
                  ),
                ),
              ],
            ),
          ),

          // ── Hint khi không thể quick-add ──
          if (!widget.canQuickAdd) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Món này có nhiều biến thể — vui lòng nhấn "Tùy chỉnh" để chọn',
                      style: TextStyle(fontSize: 11, color: Colors.orange.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Action button dùng trong _QuickAddSheet
// ─────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final bool enabled;
  final bool isPrimary;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.enabled,
    this.isPrimary = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = enabled ? color : Colors.grey;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: enabled
              ? (isPrimary ? color : color.withOpacity(0.08))
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: enabled ? color.withOpacity(isPrimary ? 0 : 0.3) : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: enabled && isPrimary
              ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 24,
                color: enabled
                    ? (isPrimary ? Colors.white : effectiveColor)
                    : Colors.grey[400]),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: enabled
                    ? (isPrimary ? Colors.white : effectiveColor)
                    : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: enabled
                    ? (isPrimary ? Colors.white.withOpacity(0.8) : effectiveColor.withOpacity(0.7))
                    : Colors.grey[350],
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════
// ORDER MODE SELECTOR
// ════════════════════════════════════════

class _OrderModeSelector extends StatelessWidget {
  final String currentMode;
  final bool canShopee;
  final bool canGrab;
  final void Function(String) onChanged;

  const _OrderModeSelector({
    required this.currentMode,
    required this.canShopee,
    required this.canGrab,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _modeBtn('OFFLINE', 'Offline', Icons.storefront_outlined, Colors.lightBlue, true),
          const SizedBox(width: 4),
          _modeBtn('SHOPEE_FOOD', 'Shopee', Icons.shopping_bag_outlined,
              const Color(0xFFEE4D2D), canShopee),
          const SizedBox(width: 4),
          _modeBtn('GRAB_FOOD', 'Grab', Icons.delivery_dining,
              const Color(0xFF00B14F), canGrab),
        ],
      ),
    );
  }

  Widget _modeBtn(String mode, String label, IconData icon, Color color, bool canSelect) {
    final isSel = currentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: canSelect ? () => onChanged(mode) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSel ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 18,
                  color: isSel ? Colors.white : canSelect ? color : Colors.grey[400]),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSel ? Colors.white : canSelect ? color : Colors.grey[400],
                  )),
              if (!canSelect && mode != 'OFFLINE')
                Text('Có món\nkhông bán',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 8, color: Colors.grey[400], height: 1.2)),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════
// MODAL: Chọn giá
// ════════════════════════════════════════

class _PriceSelectionModal extends StatelessWidget {
  final PosProductModel product;
  final void Function(PriceOption) onPriceSelected;

  const _PriceSelectionModal({required this.product, required this.onPriceSelected});

  String _fmt(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (product.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: PosService.buildImageUrl(product.imageUrl),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: const Icon(Icons.fastfood, color: Colors.grey),
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Giá gốc: ${_fmt(product.basePrice)}đ',
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Chọn mức giá:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...product.priceOptions.map((opt) => _buildOption(context, opt)),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, PriceOption opt) {
    final isFree = opt.discountPercent == 100;
    return GestureDetector(
      onTap: () => onPriceSelected(opt),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isFree ? Colors.red.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: opt.discountPercent > 0
                ? (isFree ? Colors.red : Colors.green).withOpacity(0.5)
                : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (opt.discountPercent > 0)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: isFree ? Colors.red : Colors.green,
                        borderRadius: BorderRadius.circular(4)),
                    child: Text(isFree ? 'FREE' : '-${opt.discountPercent}%',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                Text(opt.label,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
            Text(
              isFree ? '0đ' : '${_fmt(opt.price)}đ',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isFree ? Colors.red : Colors.deepOrange),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper: phân phối số lượng chọn (minSelect) vào các NL theo thứ tự ──
// VD: minSelect=1, [Hamburger max=1, Chickenburger max=1] → {Hamburger: 1}
// VD: minSelect=3, [Garlic max=2, Cheddar max=2] → {Garlic: 2, Cheddar: 1}
Map<int, int> _autoDistributeIngredients(PosVariantModel v) {
  final result = <int, int>{};
  int remaining = v.minSelect;
  for (final ing in v.ingredients) {
    if (remaining <= 0) break;
    final maxPer = ing.maxSelectableCount ?? 1;
    final assign = remaining.clamp(0, maxPer);
    if (assign > 0) result[ing.ingredientId] = assign;
    remaining -= assign;
  }
  return result;
}

Map<int, int> _autoFillIngredients(PosVariantModel variant) {
  if (variant.ingredients.isEmpty) return {};
  final result = <int, int>{};
  int remaining = variant.maxSelect;
  for (final ing in variant.ingredients) {
    if (remaining <= 0) break;
    final cap = ing.maxSelectableCount ?? 1;
    final give = remaining < cap ? remaining : cap;
    if (give > 0) result[ing.ingredientId] = give;
    remaining -= give;
  }
  return result;
}

// ════════════════════════════════════════
// MODAL: Multi-group variant selection
// ════════════════════════════════════════

class _MultiVariantSelectionModal extends StatefulWidget {
  final PosProductModel product;
  final PriceOption selectedPrice;
  final VariantGroupSelection? initialSelection;
  final void Function(List<VariantGroupSelection>, String?) onConfirm;

  const _MultiVariantSelectionModal({
    required this.product,
    required this.selectedPrice,
    this.initialSelection,
    required this.onConfirm,
  });

  @override
  State<_MultiVariantSelectionModal> createState() =>
      _MultiVariantSelectionModalState();
}

class _MultiVariantSelectionModalState extends State<_MultiVariantSelectionModal> {
  // Checkbox style: Set các variantId đang checked (thay cho radio _activeVariantId)
  late final Set<int> _checkedVariantIds;
  late final Map<int, Map<int, int>> _selections;
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selections = {};
    _checkedVariantIds = {};

    for (final v in widget.product.variants) {
      _selections[v.id] = {};
    }

    final regular = widget.product.variants.where((v) => !v.isAddonGroup).toList();

    if (widget.initialSelection != null && widget.initialSelection!.variantId != 0) {
      final init = widget.initialSelection!;
      _checkedVariantIds.add(init.variantId);
      _selections[init.variantId] = Map.from(init.selectedIngredients);
    } else {
      // Auto-check tất cả variant BẮT BUỘC (minSelect > 0)
      // Variant TÙY CHỌN (minSelect == 0) → để unchecked mặc định
      for (final v in regular.where((v) => v.minSelect > 0)) {
        _checkedVariantIds.add(v.id);
        _selections[v.id]!.addAll(_autoFillIngredients(v));
      }
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  bool _isFullAuto(PosVariantModel v) {
    if (v.isAddonGroup) return false;
    if (v.ingredients.isEmpty) return false;
    if (v.ingredients.any((i) => (i.maxSelectableCount ?? 0) <= 0)) return false;
    final totalRequired = v.ingredients.fold(0, (s, i) => s + (i.maxSelectableCount ?? 0));
    return v.minSelect > 0 &&
        v.minSelect == v.maxSelect &&
        v.minSelect == totalRequired;
  }

  /// Tự động phân bổ số lượng nguyên liệu khi auto-check variant:
  /// Duyệt từ đầu đến cuối, mỗi NL lấy min(maxSelectableCount, remaining)
  /// cho đến khi hết maxSelect của variant.
  Map<int, int> _autoFillIngredients(PosVariantModel variant) {
    if (variant.ingredients.isEmpty) return {};
    final result = <int, int>{};
    int remaining = variant.maxSelect;
    for (final ing in variant.ingredients) {
      if (remaining <= 0) break;
      final cap = ing.maxSelectableCount ?? 1;
      final give = remaining < cap ? remaining : cap;
      if (give > 0) result[ing.ingredientId] = give;
      remaining -= give;
    }
    return result;
  }

  /// Label hiển thị: "Lựa chọn 1", "Lựa chọn 2", ...
  /// Không render tên variant thực
  String _variantLabel(PosVariantModel variant) {
    final regularGroups = widget.product.variants.where((v) => !v.isAddonGroup).toList();
    final idx = regularGroups.indexWhere((v) => v.id == variant.id);
    return 'Lựa chọn ${idx + 1}';
  }

  Widget _buildFullAutoCard(PosVariantModel variant) {
    final isChecked = _checkedVariantIds.contains(variant.id);
    final isRequired = variant.minSelect > 0;
    final label = _variantLabel(variant);
    final ingSummary = variant.ingredients
        .map((i) => '${i.ingredientName} ×${i.maxSelectableCount ?? 1}')
        .join(' + ');
    final totalNl = variant.ingredients.fold(0, (s, i) => s + (i.maxSelectableCount ?? 1));

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isChecked) {
            _checkedVariantIds.remove(variant.id);
            _selections[variant.id]!.clear();
          } else {
            _checkedVariantIds.add(variant.id);
            _selections[variant.id]!.addAll(_autoFillIngredients(variant));
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isChecked ? Colors.teal.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isChecked ? Colors.teal.shade400 : Colors.grey.shade300,
            width: isChecked ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: isChecked ? Colors.teal : Colors.transparent,
                border: Border.all(
                  color: isChecked ? Colors.teal : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isChecked
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isChecked ? Colors.teal.shade700 : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Badge Bắt buộc / Tùy chọn
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isRequired ? Colors.red.shade50 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isRequired ? Colors.red.shade300 : Colors.grey.shade400,
                        ),
                      ),
                      child: Text(
                        isRequired ? 'Bắt buộc' : 'Tùy chọn',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isRequired ? Colors.red.shade600 : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 2),
                  Text(
                    ingSummary,
                    style: TextStyle(
                      fontSize: 11,
                      color: isChecked ? Colors.teal.shade600 : Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Tổng: $totalNl nguyên liệu · Tự động chọn',
                    style: TextStyle(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: isChecked ? Colors.teal.shade300 : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            if (isChecked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '✓ Đã chọn',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectableCard(PosVariantModel variant) {
    final isChecked = _checkedVariantIds.contains(variant.id);
    final isRequired = variant.minSelect > 0;
    final label = _variantLabel(variant);
    final map = _selections[variant.id] ?? {};
    final total = map.values.fold(0, (s, c) => s + c);
    final isGroupValid = total >= variant.minSelect && total <= variant.maxSelect;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              if (isChecked) {
                _checkedVariantIds.remove(variant.id);
                _selections[variant.id]!.clear();
              } else {
                _checkedVariantIds.add(variant.id);
                _selections[variant.id]!.addAll(_autoFillIngredients(variant));
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isChecked ? Colors.blue.shade50 : Colors.grey.shade50,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: Radius.circular(isChecked ? 0 : 12),
                bottomRight: Radius.circular(isChecked ? 0 : 12),
              ),
              border: Border.all(
                color: isChecked ? Colors.blue.shade400 : Colors.grey.shade300,
                width: isChecked ? 2 : 1,
              ),
            ),
            child: Row(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: isChecked ? Colors.blue : Colors.transparent,
                  border: Border.all(
                      color: isChecked ? Colors.blue : Colors.grey.shade400, width: 2),
                ),
                child: isChecked
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(label,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isChecked ? Colors.blue.shade700 : Colors.black87)),
                      const SizedBox(width: 6),
                      // Badge Bắt buộc / Tùy chọn
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: isRequired ? Colors.red.shade50 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isRequired ? Colors.red.shade300 : Colors.grey.shade400,
                          ),
                        ),
                        child: Text(
                          isRequired ? 'Bắt buộc' : 'Tùy chọn',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isRequired ? Colors.red.shade600 : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ]),
                    Text(
                      isRequired
                          ? (variant.minSelect == variant.maxSelect
                          ? 'Chọn đúng ${variant.minSelect} nguyên liệu'
                          : 'Chọn từ ${variant.minSelect} đến ${variant.maxSelect}')
                          : (variant.maxSelect > 0
                          ? 'Chọn tối đa ${variant.maxSelect} nguyên liệu'
                          : 'Không giới hạn'),
                      style: TextStyle(
                          fontSize: 11,
                          color: isChecked ? Colors.blue.shade300 : Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (isChecked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isGroupValid ? Colors.green.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isGroupValid ? Colors.green.shade300 : Colors.orange.shade300,
                    ),
                  ),
                  child: Text(
                    isRequired ? '$total / ${variant.minSelect}' : '$total chọn',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isGroupValid ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
            ]),
          ),
        ),
        if (isChecked)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue.shade200, width: 1.5),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              children: variant.ingredients.map((vi) {
                final count = map[vi.ingredientId] ?? 0;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: count > 0 ? Colors.deepOrange.shade50 : Colors.white,
                    border: Border(top: BorderSide(color: Colors.blue.shade100, width: 0.5)),
                  ),
                  child: Row(children: [
                    if (vi.ingredientImageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl: PosService.buildImageUrl(vi.ingredientImageUrl),
                          width: 34,
                          height: 34,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              Icon(Icons.set_meal, color: Colors.grey[400], size: 26),
                        ),
                      )
                    else
                      Icon(Icons.set_meal, color: Colors.grey[400], size: 26),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(vi.ingredientName,
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                    ),
                    Row(children: [
                      _ingBtn(
                          Icons.remove,
                          count > 0
                              ? () => _changeCount(variant.id, vi.ingredientId, -1, variant)
                              : null),
                      SizedBox(
                        width: 30,
                        child: Text('$count',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: count > 0 ? Colors.deepOrange : Colors.grey)),
                      ),
                      _ingBtn(
                          Icons.add,
                          total < variant.maxSelect
                              ? () => _changeCount(variant.id, vi.ingredientId, 1, variant)
                              : null),
                    ]),
                  ]),
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildGroup(PosVariantModel variant) {
    if (variant.isAddonGroup) return _buildAddonGroup(variant);
    if (_isFullAuto(variant)) return _buildFullAutoCard(variant);
    return _buildSelectableCard(variant);
  }

  // Validation: chỉ variant BẮT BUỘC (minSelect > 0) mới cần checked + đủ số lượng
  // Variant TÙY CHỌN (minSelect == 0): nếu checked thì không cần validate số lượng
  bool get _isValid {
    final regularGroups =
    widget.product.variants.where((v) => !v.isAddonGroup).toList();
    if (regularGroups.isEmpty) return true;
    for (final v in regularGroups) {
      final isChecked = _checkedVariantIds.contains(v.id);
      if (v.minSelect > 0) {
        // Bắt buộc: phải checked VÀ đủ số lượng
        if (!isChecked) return false;
        final map = _selections[v.id] ?? {};
        final total = map.values.fold(0, (s, c) => s + c);
        if (_isFullAuto(v)) {
          if (total != v.minSelect) return false;
        } else {
          if (total < v.minSelect || total > v.maxSelect) return false;
        }
      }
      // minSelect == 0: tùy chọn, không cần validate
    }
    return true;
  }

  // Hint chỉ liệt kê các nhóm BẮT BUỘC còn thiếu
  String get _validationHint {
    final regularGroups =
    widget.product.variants.where((v) => !v.isAddonGroup && v.minSelect > 0).toList();
    final hints = <String>[];
    for (final v in regularGroups) {
      final isChecked = _checkedVariantIds.contains(v.id);
      final label = _variantLabel(v);
      if (!isChecked) {
        hints.add('$label: chưa chọn');
        continue;
      }
      final map = _selections[v.id] ?? {};
      final total = map.values.fold(0, (s, c) => s + c);
      if (total < v.minSelect) {
        hints.add('$label: cần thêm ${v.minSelect - total}');
      }
    }
    return hints.join(' · ');
  }

  double get _currentAddonTotal {
    final discountFactor = 1.0 - (widget.selectedPrice.discountPercent / 100.0);
    double total = 0;
    for (final v in widget.product.variants) {
      if (!v.isAddonGroup) continue;
      final map = _selections[v.id] ?? {};
      for (final entry in map.entries) {
        final ing = v.ingredients.where((i) => i.ingredientId == entry.key).firstOrNull;
        if (ing != null) total += ing.addonPrice * discountFactor * entry.value;
      }
    }
    return total;
  }

  void _changeCount(int variantId, int ingredientId, int delta, PosVariantModel variant) {
    setState(() {
      final map = _selections[variantId]!;
      final current = map[ingredientId] ?? 0;
      final newVal = current + delta;
      final total = map.values.fold(0, (s, c) => s + c);
      if (newVal <= 0) {
        map.remove(ingredientId);
        return;
      }
      if (!variant.isAddonGroup && total - current + newVal > variant.maxSelect) return;
      map[ingredientId] = newVal;
    });
  }

  Widget _buildAddonGroup(PosVariantModel variant) {
    final map = _selections[variant.id] ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(variant.groupName,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: Colors.deepOrange)),
        ),
        ...variant.ingredients.map((vi) {
          final count = map[vi.ingredientId] ?? 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: count > 0 ? Colors.deepOrange.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: count > 0 ? Colors.deepOrange.shade300 : Colors.orange.shade200),
            ),
            child: Row(
              children: [
                if (vi.ingredientImageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: CachedNetworkImage(
                      imageUrl: PosService.buildImageUrl(vi.ingredientImageUrl),
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          Icon(Icons.add_box_outlined, color: Colors.orange[400], size: 28),
                    ),
                  )
                else
                  Icon(Icons.add_box_outlined, color: Colors.orange[400], size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(vi.ingredientName,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text(
                        vi.addonPrice > 0 ? '+${_fmt(vi.addonPrice)}đ / cái' : 'Miễn phí',
                        style: TextStyle(
                          fontSize: 11,
                          color: vi.addonPrice > 0 ? Colors.deepOrange : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(children: [
                  _ingBtn(
                      Icons.remove_circle_outline,
                      count > 0
                          ? () => _changeCount(variant.id, vi.ingredientId, -1, variant)
                          : null),
                  SizedBox(
                    width: 32,
                    child: Text('$count',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: count > 0 ? Colors.deepOrange : Colors.grey[400])),
                  ),
                  _ingBtn(Icons.add_circle_outline,
                          () => _changeCount(variant.id, vi.ingredientId, 1, variant)),
                ]),
              ],
            ),
          );
        }),
        const SizedBox(height: 4),
        const Divider(height: 1),
        const SizedBox(height: 12),
      ],
    );
  }

  void _confirm() {
    final discountFactor = 1.0 - (widget.selectedPrice.discountPercent / 100.0);
    final List<VariantGroupSelection> selections = [];

    // Gom tất cả regular variant đang được checked
    for (final v in widget.product.variants.where((v) => !v.isAddonGroup)) {
      if (!_checkedVariantIds.contains(v.id)) continue;
      final ingMap = _selections[v.id] ?? {};
      selections.add(VariantGroupSelection(
        variantId: v.id,
        groupName: v.groupName,
        isAddonGroup: false,
        selectedIngredients: Map.from(ingMap),
        addonItems: null,
      ));
    }

    for (final v in widget.product.variants.where((v) => v.isAddonGroup)) {
      final ingMap = _selections[v.id] ?? {};
      if (ingMap.isEmpty) continue;
      selections.add(VariantGroupSelection(
        variantId: v.id,
        groupName: v.groupName,
        isAddonGroup: true,
        selectedIngredients: Map.from(ingMap),
        addonItems: ingMap.entries
            .where((e) => e.value > 0)
            .map((e) {
          final ing = v.ingredients.firstWhere((i) => i.ingredientId == e.key);
          final basePrice = ing.addonPrice;
          return AddonItem(
            ingredientId: e.key,
            ingredientName: ing.ingredientName,
            baseAddonPrice: basePrice,
            discountedAddonPrice: basePrice * discountFactor,
            quantity: e.value,
          );
        }).toList(),
      ));
    }

    widget.onConfirm(
        selections, _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim());
  }

  String _fmt(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    final addonTotal = _currentAddonTotal;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.product.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                          '${widget.selectedPrice.label} · ${_fmt(widget.selectedPrice.price)}đ',
                          style: const TextStyle(color: Colors.deepOrange)),
                    ],
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          const Divider(height: 16),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Regular variant groups ──
                  ...() {
                    final regularGroups =
                    widget.product.variants.where((v) => !v.isAddonGroup).toList();
                    if (regularGroups.isEmpty) return <Widget>[];
                    return regularGroups.map(_buildGroup).toList();
                  }(),

                  // ── Addon groups ──
                  ...() {
                    final addonGroups =
                    widget.product.variants.where((v) => v.isAddonGroup).toList();
                    if (addonGroups.isEmpty) return <Widget>[];
                    return [
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.deepOrange.shade200),
                        ),
                        child: Row(children: [
                          const Icon(Icons.add_circle_outline, size: 16, color: Colors.deepOrange),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Món thêm (Addon)',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Colors.deepOrange)),
                                Text('Tùy chọn — mỗi món chọn sẽ cộng thêm vào giá',
                                    style: TextStyle(fontSize: 10, color: Colors.deepOrange)),
                              ],
                            ),
                          ),
                        ]),
                      ),
                      ...addonGroups.map(_buildAddonGroup).toList(),
                    ];
                  }(),

                  // ── Ghi chú ──
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Ghi chú cho món',
                      hintText: 'VD: ít cay, không hành...',
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      prefixIcon: const Icon(Icons.notes, size: 18),
                    ),
                  ),

                  // ── Addon total preview ──
                  if (addonTotal > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.deepOrange.shade50,
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(children: [
                        const Icon(Icons.add_circle_outline, size: 14, color: Colors.deepOrange),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Phí thêm món: +${_fmt(addonTotal)}đ',
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.deepOrange,
                                    fontWeight: FontWeight.bold)),
                            if (widget.selectedPrice.discountPercent > 0)
                              Text(
                                  '(đã giảm ${widget.selectedPrice.discountPercent}% từ discount)',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.deepOrange.withOpacity(0.7))),
                          ],
                        ),
                      ]),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).padding.bottom + 16),
            child: ElevatedButton(
              onPressed: _isValid ? _confirm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                disabledBackgroundColor: Colors.grey[300],
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                _isValid ? 'Thêm vào giỏ' : _validationHint,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ingBtn(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 20, color: onTap != null ? Colors.deepOrange : Colors.grey[300]),
      ),
    );
  }
}

// ════════════════════════════════════════
// PAYMENT METHOD SELECTOR
// ════════════════════════════════════════

class _PaymentMethodSelector extends StatelessWidget {
  final String current;
  final void Function(String) onChanged;

  const _PaymentMethodSelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              _pmBtn('CASH', 'Tiền mặt', Icons.payments_outlined, Colors.green),
              const SizedBox(width: 6),
              _pmBtn('TRANSFER', 'Chuyển khoản', Icons.account_balance_outlined, Colors.blue),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pmBtn(String value, String label, IconData icon, Color color) {
    final sel = current == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            color: sel ? color.withOpacity(0.12) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: sel ? color : Colors.grey.shade300, width: sel ? 1.5 : 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: sel ? color : Colors.grey),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                  color: sel ? color : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════
// CANCEL ORDER DIALOG
// ════════════════════════════════════════

Future<void> showCancelOrderDialog(
    BuildContext context,
    PosOrderModel order, {
      required void Function() onCancelled,
    }) async {
  final pwCtrl = TextEditingController();
  bool loading = false;

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.cancel_outlined, color: Colors.red),
            SizedBox(width: 8),
            Text('Hủy đơn hàng', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Đơn: ${order.orderCode}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: pwCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mật khẩu xác nhận',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                isDense: true,
                prefixIcon: const Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: loading
                ? null
                : () async {
              if (pwCtrl.text.isEmpty) return;
              setS(() => loading = true);
              try {
                await PosService.cancelOrder(order.id, pwCtrl.text);
                if (ctx.mounted) Navigator.pop(ctx);
                onCancelled();
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('$e'), backgroundColor: Colors.red));
                }
              } finally {
                setS(() => loading = false);
              }
            },
            child: loading
                ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Xác nhận hủy'),
          ),
        ],
      ),
    ),
  );
  pwCtrl.dispose();
}

// ════════════════════════════════════════
// Clock widget
// ════════════════════════════════════════

class _ClockWidget extends StatefulWidget {
  const _ClockWidget();

  @override
  State<_ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<_ClockWidget> {
  late DateTime _now;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    final msUntilNextSecond = 1000 - _now.millisecond;
    Future.delayed(Duration(milliseconds: msUntilNextSecond), () {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _now = DateTime.now());
      });
    });
    _timer = Timer(Duration.zero, () {});
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${_now.hour.toString().padLeft(2, '0')}:'
          '${_now.minute.toString().padLeft(2, '0')}:'
          '${_now.second.toString().padLeft(2, '0')} '
          '${_now.day.toString().padLeft(2, '0')}/'
          '${_now.month.toString().padLeft(2, '0')}/'
          '${_now.year}',
      style: const TextStyle(fontSize: 14, color: Colors.grey),
    );
  }
}