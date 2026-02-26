import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:original_taste/helper/services/pos_service.dart';

// ══════════════════════════════════════════════════════
// ADDON GROUPS SECTION
// ══════════════════════════════════════════════════════

class _AddonGroupsSection extends StatefulWidget {
  final List<_AddonGroupDraft> addonGroups;
  final List<Map<String, dynamic>> allIngredients;
  final VoidCallback onChanged;
  final Future<void> Function(int variantId)? onDeleteSaved;

  const _AddonGroupsSection({
    required this.addonGroups,
    required this.allIngredients,
    required this.onChanged,
    this.onDeleteSaved,
  });

  @override
  State<_AddonGroupsSection> createState() => _AddonGroupsSectionState();
}

class _AddonGroupsSectionState extends State<_AddonGroupsSection> {
  void _addAddonGroup() {
    if (widget.addonGroups.isNotEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(child: Text('Không thể thêm', style: TextStyle(fontSize: 16))),
          ]),
          content: const Text(
            'Không thể tạo mới 2 Addon Group.\n\n'
                'Chỉ có thể tồn tại 1 addon group — vui lòng chỉnh sửa trong addon group hiện tại.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Đã hiểu'),
            ),
          ],
        ),
      );
      return;
    }
    setState(() => widget.addonGroups.add(_AddonGroupDraft(
      groupName: 'Món thêm',
      ingredients: [],
    )));
    widget.onChanged();
  }

  void _removeAddonGroup(int i) async {
    final draft = widget.addonGroups[i];
    if (draft.id != null && widget.onDeleteSaved != null) {
      try {
        await widget.onDeleteSaved!(draft.id!);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi xóa khỏi database: $e'), backgroundColor: Colors.red),
          );
        }
        return;
      }
    }
    if (mounted) {
      setState(() => widget.addonGroups.removeAt(i));
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAddon = widget.addonGroups.isNotEmpty;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        const Icon(Icons.add_shopping_cart, size: 18, color: Color(0xFF7B1FA2)),
        const SizedBox(width: 6),
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Món thêm (Addon)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF7B1FA2))),
            Text('Tùy chọn — khách chọn thêm món, mỗi lần chọn cộng tiền',
                style: TextStyle(fontSize: 11, color: Colors.grey)),
          ]),
        ),
        TextButton.icon(
          onPressed: _addAddonGroup,
          icon: const Icon(Icons.add_circle_outline, size: 16),
          label: const Text('Thêm addon'),
          style: TextButton.styleFrom(
              foregroundColor: hasAddon ? Colors.grey : const Color(0xFF7B1FA2)),
        ),
      ]),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF3E5F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCE93D8)),
        ),
        child: const Text(
          '💡 Chỉ được 1 nhóm addon. VD: "Thêm sốt" gồm [Sốt cay +5,000đ, Sốt tỏi +5,000đ]\n'
              'Khách có thể chọn 0, 1 hoặc nhiều — mỗi món cộng vào tổng.',
          style: TextStyle(fontSize: 11, color: Color(0xFF7B1FA2), height: 1.5),
        ),
      ),
      const SizedBox(height: 12),
      if (hasAddon)
        _AddonGroupCard(
          key: ValueKey('addon_${widget.addonGroups.first.id ?? 0}'),
          index: 0,
          draft: widget.addonGroups.first,
          allIngredients: widget.allIngredients,
          onChanged: () { setState(() {}); widget.onChanged(); },
          onRemove: () async => _removeAddonGroup(0),
        ),
    ]);
  }
}

// ══════════════════════════════════════════════════════
// ADDON GROUP CARD
// ══════════════════════════════════════════════════════

class _AddonGroupCard extends StatefulWidget {
  final int index;
  final _AddonGroupDraft draft;
  final List<Map<String, dynamic>> allIngredients;
  final VoidCallback onChanged;
  final Future<void> Function() onRemove;

  const _AddonGroupCard({
    super.key,
    required this.index,
    required this.draft,
    required this.allIngredients,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<_AddonGroupCard> createState() => _AddonGroupCardState();
}

class _AddonGroupCardState extends State<_AddonGroupCard> {
  late final TextEditingController _nameCtrl;
  late bool _expanded;
  bool _deleting = false;
  bool _isRemoving = false;

  static const _purple = Color(0xFF7B1FA2);
  static const _purpleLight = Color(0xFFF3E5F5);
  static const _purpleBorder = Color(0xFFCE93D8);

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.draft.groupName);
    _expanded = widget.draft.id == null;
  }

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  void _confirmAndRemove() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red),
          SizedBox(width: 12),
          Expanded(child: Text('Xóa Nhóm Thêm', style: TextStyle(fontSize: 18))),
        ]),
        content: Text(
          'Bạn chắc chắn muốn xóa "${widget.draft.groupName}"?\n'
              '${widget.draft.id != null ? "Nhóm này sẽ bị xóa khỏi hệ thống và không thể hoàn tác." : ""}',
          style: const TextStyle(fontSize: 14, height: 1.45),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() { _deleting = true; _isRemoving = true; });
    try {
      await widget.onRemove();
    } catch (e) {
      if (mounted && !_isRemoving) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Lỗi xóa nhóm thêm: $e'), backgroundColor: Colors.red,
              duration: const Duration(seconds: 4)),
        );
      }
    } finally {
      if (mounted && !_isRemoving) setState(() => _deleting = false);
    }
  }

  void _openIngPicker() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.white, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _IngredientPickerSheet(
        allIngredients: widget.allIngredients,
        selected: widget.draft.ingredients,
        showAddonPrice: true,
        onDone: (result) {
          setState(() => widget.draft.ingredients = result);
          widget.onChanged();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    final hasError = draft.ingredients.isEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: hasError ? Colors.red.shade200 : _purpleBorder, width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          child: Container(
            decoration: BoxDecoration(
              color: _purpleLight,
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(13),
                bottom: _expanded ? Radius.zero : const Radius.circular(13),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
            child: Row(children: [
              Container(
                width: 28, height: 28,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: _purple),
                child: const Center(child: Icon(Icons.add_shopping_cart, color: Colors.white, size: 15)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  draft.groupName.isEmpty ? 'Nhóm Addon' : draft.groupName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _purple),
                  overflow: TextOverflow.ellipsis,
                ),
                Text('${draft.ingredients.length} món · tùy chọn, không bắt buộc',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ])),
              if (draft.ingredients.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _purple.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _purple.withOpacity(0.4)),
                  ),
                  child: Text('${draft.ingredients.length} món',
                      style: const TextStyle(fontSize: 9, color: _purple, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 4),
              ],
              Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: _purple.withOpacity(0.7)),
              const SizedBox(width: 4),
              if (_deleting)
                const Padding(padding: EdgeInsets.all(8),
                    child: SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red)))
              else
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: _confirmAndRemove,
                  padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                ),
            ]),
          ),
        ),
        if (_expanded) ...[
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              TextField(
                controller: _nameCtrl,
                onChanged: (v) { draft.groupName = v; widget.onChanged(); },
                decoration: InputDecoration(
                  labelText: 'Tên nhóm addon *',
                  hintText: 'VD: Thêm sốt · Thêm topping',
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  labelStyle: const TextStyle(color: _purple),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _purple, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _openIngPicker,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: hasError ? Colors.red.shade300 : Colors.grey.shade300),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.add_box_outlined, size: 16, color: _purple),
                      const SizedBox(width: 6),
                      Expanded(child: Text('Chọn món thêm *',
                          style: TextStyle(fontSize: 13,
                              color: hasError ? Colors.red : Colors.black87,
                              fontWeight: FontWeight.w500))),
                      Text('Nhấn để chọn', style: TextStyle(fontSize: 11, color: Colors.blue.shade400)),
                      const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                    ]),
                    if (draft.ingredients.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      ...draft.ingredients.map((ing) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _purpleLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _purpleBorder),
                        ),
                        child: Row(children: [
                          const Icon(Icons.add_circle_outline, size: 14, color: _purple),
                          const SizedBox(width: 8),
                          Expanded(child: Text(ing.ingredientName,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                          Text(
                            ing.addonPrice > 0 ? '+${ing.addonPrice.toStringAsFixed(0)}đ' : 'Miễn phí',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                                color: ing.addonPrice > 0 ? _purple : Colors.green),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () { setState(() => draft.ingredients.remove(ing)); widget.onChanged(); },
                            child: const Icon(Icons.close, size: 14, color: Colors.grey),
                          ),
                        ]),
                      )),
                    ] else ...[
                      const SizedBox(height: 6),
                      Text('Chưa chọn món thêm nào...',
                          style: TextStyle(color: hasError ? Colors.red : Colors.grey,
                              fontSize: 12, fontStyle: FontStyle.italic)),
                    ],
                  ]),
                ),
              ),
            ]),
          ),
        ],
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════
// LOCAL MODELS
// ══════════════════════════════════════════════════════

class _IngredientEntry {
  final int ingredientId;
  final String ingredientName;
  double stockDeductPerUnit;
  double addonPrice;
  int maxSelectableCount;

  _IngredientEntry({
    required this.ingredientId,
    required this.ingredientName,
    this.stockDeductPerUnit = 1.0,
    this.addonPrice = 0.0,
    this.maxSelectableCount = 1,
  });
}

class _VariantGroupDraft {
  int? id;
  String groupName;
  int minSelect;
  int maxSelect;
  bool allowRepeat;
  bool isActive;
  bool isDefault; // ← NEW
  List<_IngredientEntry> ingredients;

  _VariantGroupDraft({
    this.id,
    required this.groupName,
    required this.minSelect,
    required this.maxSelect,
    this.allowRepeat = true,
    this.isActive = true,
    this.isDefault = false, // ← NEW
    required this.ingredients,
  });

  Map<String, dynamic> toCreateBody(int productId) => {
    'productId': productId,
    'groupName': groupName,
    'minSelect': minSelect,
    'maxSelect': maxSelect,
    'allowRepeat': allowRepeat,
    'isAddonGroup': false,
    'isDefault': isDefault, // ← NEW
    'displayOrder': 0,
    'ingredients': ingredients.map((e) => {
      'ingredientId': e.ingredientId,
      'stockDeductPerUnit': e.stockDeductPerUnit,
      'maxSelectableCount': e.maxSelectableCount,
      'addonPrice': 0,
      'displayOrder': 0,
    }).toList(),
  };

  Map<String, dynamic> toUpdateBody() => {
    'groupName': groupName,
    'minSelect': minSelect,
    'maxSelect': maxSelect,
    'allowRepeat': allowRepeat,
    'isAddonGroup': false,
    'isActive': isActive,
    'isDefault': isDefault, // ← NEW
    'ingredients': ingredients.map((e) => {
      'ingredientId': e.ingredientId,
      'stockDeductPerUnit': e.stockDeductPerUnit,
      'maxSelectableCount': e.maxSelectableCount,
      'addonPrice': 0,
      'displayOrder': 0,
    }).toList(),
  };
}

class _AddonGroupDraft {
  int? id;
  String groupName;
  bool isActive;
  List<_IngredientEntry> ingredients;

  _AddonGroupDraft({
    this.id,
    this.groupName = 'Món thêm',
    this.isActive = true,
    this.ingredients = const [],
  });

  Map<String, dynamic> toCreateBody(int productId) => {
    'productId': productId,
    'groupName': groupName,
    'minSelect': 0,
    'maxSelect': 9999,
    'allowRepeat': true,
    'isAddonGroup': true,
    'displayOrder': 0,
    'ingredients': ingredients.map((e) => {
      'ingredientId': e.ingredientId,
      'stockDeductPerUnit': e.stockDeductPerUnit,
      'addonPrice': e.addonPrice,
      'displayOrder': 0,
    }).toList(),
  };

  Map<String, dynamic> toUpdateBody() => {
    'groupName': groupName,
    'minSelect': 0,
    'maxSelect': 9999,
    'allowRepeat': true,
    'isAddonGroup': true,
    'isActive': isActive,
    'ingredients': ingredients.map((e) => {
      'ingredientId': e.ingredientId,
      'stockDeductPerUnit': e.stockDeductPerUnit,
      'addonPrice': e.addonPrice,
      'displayOrder': 0,
    }).toList(),
  };
}

// ══════════════════════════════════════════════════════
// MAIN SCREEN
// ══════════════════════════════════════════════════════

class PosMenuScreen extends StatefulWidget {
  const PosMenuScreen({super.key});
  @override
  State<PosMenuScreen> createState() => _PosMenuScreenState();
}

class _PosMenuScreenState extends State<PosMenuScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final _categoryKey   = GlobalKey<_CategoryTabState>();
  final _productKey    = GlobalKey<_ProductTabState>();
  final _ingredientKey = GlobalKey<_IngredientTabState>();

  @override
  void initState() { super.initState(); _initTabs(); }

  void _initTabs() {
    _tabController?.dispose();
    _tabController = TabController(length: 3, vsync: this);
    _tabController!.addListener(() { if (mounted) setState(() {}); });
  }

  @override
  void dispose() { _tabController?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final titles = ['Quản lý Category', 'Quản lý Sản phẩm', 'Quản lý Nguyên liệu'];
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(titles[_tabController?.index ?? 0],
              key: ValueKey(_tabController?.index ?? 0),
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.deepOrange, unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.deepOrange,
          tabs: const [
            Tab(icon: Icon(Icons.category_outlined), text: 'Category'),
            Tab(icon: Icon(Icons.fastfood_outlined), text: 'Sản phẩm'),
            Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Nguyên liệu'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepOrange, foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(['Thêm Category', 'Thêm Sản phẩm', 'Thêm Nguyên liệu'][_tabController?.index ?? 0]),
        onPressed: () {
          switch (_tabController?.index ?? 0) {
            case 0: _categoryKey.currentState?.showAddForm(); break;
            case 1: _productKey.currentState?.showAddForm(); break;
            case 2: _ingredientKey.currentState?.showAddForm(); break;
          }
        },
      ),
      body: _tabController == null
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _CategoryTab(key: _categoryKey),
          _ProductTab(key: _productKey),
          _IngredientTab(key: _ingredientKey),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// TAB: CATEGORY (unchanged)
// ══════════════════════════════════════════════════════

class _CategoryTab extends StatefulWidget {
  const _CategoryTab({super.key});
  @override State<_CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends State<_CategoryTab> {
  List<PosCategoryModel> _all = [];
  bool _loading = true, _reordering = false;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await PosService.getCategories();
      if (mounted) setState(() {
        _all = [...data]..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
        _loading = false;
      });
    } catch (e) { _snack('$e', Colors.red); if (mounted) setState(() => _loading = false); }
  }

  void _snack(String msg, Color c) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: c));
  }

  int get _nextOrder => _all.isEmpty ? 1 : _all.map((c) => c.displayOrder).reduce((a, b) => a > b ? a : b) + 1;
  void showAddForm() => _showCategoryForm(context, null, _load, nextOrder: _nextOrder);

  Future<void> _reorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    setState(() {
      final item = _all.removeAt(oldIndex);
      _all.insert(newIndex, item);
      for (int i = 0; i < _all.length; i++) {
        _all[i] = PosCategoryModel(
          id: _all[i].id, name: _all[i].name, imageUrl: _all[i].imageUrl,
          displayOrder: i + 1, isActive: _all[i].isActive,
          singlePrice: _all[i].singlePrice, productCount: _all[i].productCount,
        );
      }
    });
    setState(() => _reordering = true);
    try {
      await Future.wait(_all.map((cat) => PosService.updateCategory(
        cat.id, name: cat.name, singlePrice: cat.singlePrice,
        displayOrder: cat.displayOrder, isActive: cat.isActive, imageUrl: cat.imageUrl,
      )));
    } catch (e) { _snack('Lỗi lưu thứ tự: $e', Colors.red); }
    finally { if (mounted) setState(() => _reordering = false); }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_all.isEmpty) return const _EmptyState(icon: Icons.category_outlined, label: 'Chưa có category nào');
    return Stack(children: [
      RefreshIndicator(
        onRefresh: _load,
        child: ReorderableListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: _all.length, onReorder: _reorder, buildDefaultDragHandles: false,
          itemBuilder: (_, i) {
            final cat = _all[i];
            return _CategoryCard(
              key: ValueKey(cat.id), cat: cat, dragIndex: i,
              onEdit: () => _showCategoryForm(context, cat, _load, nextOrder: _nextOrder),
              onDelete: () => _confirmDelete(context, name: cat.name,
                  onConfirm: () async { await PosService.deleteCategory(cat.id); _load(); }),
            );
          },
        ),
      ),
      if (_reordering) _SavingIndicator(),
    ]);
  }
}

void _showCategoryForm(BuildContext ctx, PosCategoryModel? existing, VoidCallback onSuccess,
    {int nextOrder = 0}) {
  showModalBottomSheet(context: ctx, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _CategoryFormSheet(existing: existing, onSuccess: onSuccess, nextOrder: nextOrder));
}

class _CategoryFormSheet extends StatefulWidget {
  final PosCategoryModel? existing;
  final VoidCallback onSuccess;
  final int nextOrder;
  const _CategoryFormSheet({this.existing, required this.onSuccess, this.nextOrder = 0});
  @override State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
  final _nameCtrl = TextEditingController();
  bool _singlePrice = false, _isActive = true, _loading = false;
  File? _picked; String? _existingUrl;
  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final e = widget.existing!;
      _nameCtrl.text = e.name; _singlePrice = e.singlePrice; _isActive = e.isActive; _existingUrl = e.imageUrl;
    }
  }

  @override void dispose() { _nameCtrl.dispose(); super.dispose(); }

  Future<void> _pickImage() async {
    final xf = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (xf != null && mounted) setState(() => _picked = File(xf.path));
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) { _snack('Nhập tên category', Colors.orange); return; }
    setState(() => _loading = true);
    try {
      String? imageUrl = _existingUrl;
      if (_picked != null) imageUrl = await PosService.uploadImage(filePath: _picked!.path, type: 'category');
      if (_isEdit) {
        await PosService.updateCategory(widget.existing!.id, name: _nameCtrl.text.trim(),
            singlePrice: _singlePrice, displayOrder: widget.existing!.displayOrder,
            isActive: _isActive, imageUrl: imageUrl);
      } else {
        await PosService.createCategory(name: _nameCtrl.text.trim(),
            singlePrice: _singlePrice, displayOrder: widget.nextOrder, imageUrl: imageUrl);
      }
      if (mounted) Navigator.pop(context);
      widget.onSuccess();
    } catch (e) { _snack('$e', Colors.red); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  void _snack(String msg, Color c) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg), backgroundColor: c));

  @override
  Widget build(BuildContext context) => _FormSheet(
    title: _isEdit ? 'Sửa Category' : 'Thêm Category',
    isLoading: _loading, onSubmit: _submit,
    children: [
      _ImagePickerTile(pickedFile: _picked,
          existingUrl: _existingUrl != null ? PosService.buildImageUrl(_existingUrl) : null,
          onPick: _pickImage, onClear: () => setState(() { _picked = null; _existingUrl = null; })),
      const SizedBox(height: 16),
      _Field(ctrl: _nameCtrl, label: 'Tên category *', hint: 'VD: Xúc xích'),
      const SizedBox(height: 12),
      _SwitchTile(label: '1 giá (Category Lạnh)',
          subtitle: 'Sản phẩm chỉ có 1 mức giá, không giảm giá',
          value: _singlePrice, onChanged: (v) => setState(() => _singlePrice = v)),
      if (_isEdit) ...[
        const SizedBox(height: 8),
        _SwitchTile(label: 'Đang hoạt động', value: _isActive,
            onChanged: (v) => setState(() => _isActive = v)),
      ],
    ],
  );
}

class _CategoryCard extends StatelessWidget {
  final PosCategoryModel cat; final int dragIndex;
  final VoidCallback onEdit, onDelete;
  const _CategoryCard({super.key, required this.cat, required this.dragIndex,
    required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 6)]),
    child: ListTile(
      contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      leading: _ThumbImage(dbPath: cat.imageUrl, size: 54, fallback: Icons.category),
      title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: Row(children: [
        Text('${cat.productCount} sp  ', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        if (cat.singlePrice) _SmallBadge(label: '1 giá', color: Colors.blue),
        const SizedBox(width: 6),
        _StatusDot(active: cat.isActive),
      ]),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        _OrderBadge(order: cat.displayOrder, color: Colors.deepOrange),
        const SizedBox(width: 4),
        _ActionMenu(onEdit: onEdit, onDelete: onDelete),
        const SizedBox(width: 4),
        ReorderableDragStartListener(index: dragIndex,
            child: Padding(padding: const EdgeInsets.all(8),
                child: Icon(Icons.drag_handle, color: Colors.grey.shade400, size: 22))),
      ]),
    ),
  );
}

// ══════════════════════════════════════════════════════
// TAB: PRODUCT
// ══════════════════════════════════════════════════════

class _ProductTab extends StatefulWidget {
  const _ProductTab({super.key});
  @override State<_ProductTab> createState() => _ProductTabState();
}

class _ProductTabState extends State<_ProductTab> {
  List<PosProductModel> _all = [];
  List<PosCategoryModel> _categories = [];
  List<Map<String, dynamic>> _ingredients = [];
  PosCategoryModel? _filterCat;
  String _search = '';
  bool _loading = true, _reordering = false;
  final _searchCtrl = TextEditingController();

  @override void initState() { super.initState(); _load(); }
  @override void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await Future.wait([
        PosService.getCategories(),
        PosService.getProducts(categoryId: _filterCat?.id),
        PosService.getIngredients(),
      ]);
      if (mounted) setState(() {
        _categories  = res[0] as List<PosCategoryModel>;
        final prods  = res[1] as List<PosProductModel>;
        _all         = [...prods]..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
        _ingredients = res[2] as List<Map<String, dynamic>>;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.red));
        setState(() => _loading = false);
      }
    }
  }

  List<PosProductModel> get _filtered => _search.isEmpty
      ? _all : _all.where((p) => p.name.toLowerCase().contains(_search.toLowerCase())).toList();

  int get _nextOrder => _all.isEmpty ? 1 : _all.map((p) => p.displayOrder).reduce((a, b) => a > b ? a : b) + 1;
  void showAddForm() => _showProductForm(context, null, _categories, _ingredients, _load, nextOrder: _nextOrder);

  String _fmt(double v) => v.toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  Future<void> _reorder(int oldIndex, int newIndex) async {
    if (_search.isNotEmpty) return;
    if (newIndex > oldIndex) newIndex--;
    setState(() {
      final item = _all.removeAt(oldIndex);
      _all.insert(newIndex, item);
      for (int i = 0; i < _all.length; i++) _all[i] = _all[i].copyWithOrder(i + 1);
    });
    setState(() => _reordering = true);
    try {
      await Future.wait(_all.map((p) => PosService.updateProductOrder(p.id, displayOrder: p.displayOrder)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi lưu thứ tự: $e'), backgroundColor: Colors.red));
    } finally { if (mounted) setState(() => _reordering = false); }
  }

  @override
  Widget build(BuildContext context) {
    final displayed = _filtered;
    return Column(children: [
      Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
        child: Column(children: [
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Tìm sản phẩm...', isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear, size: 18),
                  onPressed: () { _searchCtrl.clear(); setState(() => _search = ''); })
                  : null,
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              _Chip(label: 'Tất cả', selected: _filterCat == null,
                  onTap: () { setState(() => _filterCat = null); _load(); }),
              ..._categories.map((c) => _Chip(label: c.name, selected: _filterCat?.id == c.id,
                  onTap: () { setState(() => _filterCat = c); _load(); })),
            ]),
          ),
        ]),
      ),
      Expanded(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : displayed.isEmpty
            ? const _EmptyState(icon: Icons.fastfood_outlined, label: 'Chưa có sản phẩm nào')
            : Stack(children: [
          RefreshIndicator(
            onRefresh: _load,
            child: ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
              itemCount: displayed.length, onReorder: _reorder, buildDefaultDragHandles: false,
              itemBuilder: (_, i) {
                final p = displayed[i];
                return _ProductCard(
                  key: ValueKey(p.id), product: p, formatMoney: _fmt, dragIndex: i,
                  onEdit: () => _showProductForm(context, p, _categories, _ingredients, _load, nextOrder: _nextOrder),
                  onDelete: () => _confirmDelete(context, name: p.name,
                      onConfirm: () async { await PosService.deleteProduct(p.id); _load(); }),
                );
              },
            ),
          ),
          if (_reordering) _SavingIndicator(),
        ]),
      ),
    ]);
  }
}

// ══════════════════════════════════════════════════════
// PRODUCT FORM
// ══════════════════════════════════════════════════════

void _showProductForm(BuildContext ctx, PosProductModel? existing,
    List<PosCategoryModel> categories, List<Map<String, dynamic>> ingredients,
    VoidCallback onSuccess, {int nextOrder = 0}) {
  showModalBottomSheet(
    context: ctx, isScrollControlled: true, backgroundColor: Colors.transparent,
    builder: (_) => _ProductFormSheet(
        existing: existing, categories: categories, allIngredients: ingredients,
        onSuccess: onSuccess, nextOrder: nextOrder),
  );
}

class _ProductFormSheet extends StatefulWidget {
  final PosProductModel? existing;
  final List<PosCategoryModel> categories;
  final List<Map<String, dynamic>> allIngredients;
  final VoidCallback onSuccess;
  final int nextOrder;
  const _ProductFormSheet({this.existing, required this.categories,
    required this.allIngredients, required this.onSuccess, this.nextOrder = 0});
  @override State<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<_ProductFormSheet> {
  final _nameCtrl  = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _vatCtrl   = TextEditingController();
  PosCategoryModel? _selectedCat;
  bool _isActive = true, _loading = false;
  bool _isShopeeFood = false, _isGrabFood = false;
  final _shopeePriceCtrl = TextEditingController();
  final _grabPriceCtrl   = TextEditingController();
  File? _picked; String? _existingUrl;
  List<_AddonGroupDraft> _addonGroups = [];
  List<_VariantGroupDraft> _variantGroups = [];

  bool get _isEdit => widget.existing != null;

  void _trySetDefault(int index) {
    final group = _variantGroups[index];

    // Kiểm tra điều kiện full-auto
    if (!_isFullAutoGroup(group)) {
      showDialog(
        context: context,
        builder: (dialogCtx) => ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.60, // 60% chiều rộng màn hình
          ),
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Expanded(child: Text('Không thể đặt mặc định', style: TextStyle(fontSize: 20, color: Colors.redAccent))),
            ]),
            content: const Text(
              'Biến thể này có nhiều lựa chọn khác nhau, không thể làm biến thể mặc định.\n\n'
                  'Chỉ các nhóm bắt buộc chọn đúng 1 lựa chọn duy nhất (ví dụ: chọn 1 size, 1 topping cố định) mới được đặt mặc định để dùng tính năng "Thêm nhanh".',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Đã hiểu', style: TextStyle(color: Colors.deepOrange, fontSize: 16)),
              ),
            ],
          ),
        ),
      );
      return;
    }

    // Nếu hợp lệ → set default
    setState(() {
      for (int i = 0; i < _variantGroups.length; i++) {
        _variantGroups[i].isDefault = (i == index);
      }
    });
    // Gọi callback nếu cần (để card refresh)
    // widget.onSetDefault?.call(index); // nếu có callback
  }

  /// ── Đảm bảo chỉ có đúng 1 variant được set isDefault ──
  void _setDefault(int index) {
    final group = _variantGroups[index];
    // Chỉ cho phép set default nếu là full-auto
    if (!_isFullAutoGroup(group)) return;
    setState(() {
      for (int i = 0; i < _variantGroups.length; i++) {
        _variantGroups[i].isDefault = (i == index);
      }
    });
  }

  bool _isFullAutoGroup(_VariantGroupDraft g) {
    if (g.ingredients.isEmpty) return false;
    if (g.ingredients.any((i) => (i.maxSelectableCount ?? 0) <= 0)) return false;
    final total = g.ingredients.fold(0, (s, i) => s + (i.maxSelectableCount ?? 0));
    return g.minSelect > 0 && g.minSelect == g.maxSelect && g.minSelect == total;
  }

  /// Auto-assign default khi danh sách thay đổi
  void _ensureDefaultAssigned() {
    if (_variantGroups.isEmpty) return;
    final hasDefault = _variantGroups.any((g) => g.isDefault);
    if (!hasDefault) {
      // Chỉ gán default cho variant full-auto đầu tiên
      final firstFullAuto = _variantGroups.where(_isFullAutoGroup).firstOrNull;
      if (firstFullAuto != null) {
        firstFullAuto.isDefault = true;
      }
      // Nếu không có variant nào full-auto → không gán default (không ai được quick-add)
    }
  }

  Future<void> _deleteSavedVariant(int index, int variantId) async {
    await PosService.deleteVariant(variantId);
    setState(() {
      _variantGroups.removeAt(index);
      _ensureDefaultAssigned();
    });
  }

  Future<void> _deleteSavedAddonGroup(int variantId) async {
    await PosService.deleteVariant(variantId);
    setState(() => _addonGroups.clear());
  }

  String? _validateVariants() {
    if (_variantGroups.isEmpty) return 'Sản phẩm phải có ít nhất 1 nhóm lựa chọn (Variant Group)';
    for (int i = 0; i < _variantGroups.length; i++) {
      final g = _variantGroups[i];
      if (g.groupName.trim().isEmpty) return 'Nhóm ${i + 1}: Vui lòng nhập tên nhóm';
      if (g.ingredients.isEmpty) return 'Nhóm "${g.groupName}": Phải có ít nhất 1 nguyên liệu';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final e = widget.existing!;
      _nameCtrl.text  = e.name;
      _descCtrl.text  = e.description ?? '';
      _priceCtrl.text = e.basePrice.toStringAsFixed(0);
      _vatCtrl.text   = e.vatPercent.toString();
      _isActive = e.isActive; _isShopeeFood = e.isShopeeFood; _isGrabFood = e.isGrabFood;
      final shopeeMenu = e.appMenus.where((m) => m.platform == 'SHOPEE_FOOD' && m.isActive).firstOrNull;
      final grabMenu   = e.appMenus.where((m) => m.platform == 'GRAB_FOOD'   && m.isActive).firstOrNull;
      if (shopeeMenu != null) _shopeePriceCtrl.text = shopeeMenu.price.toStringAsFixed(0);
      if (grabMenu   != null) _grabPriceCtrl.text   = grabMenu.price.toStringAsFixed(0);
      _existingUrl = e.imageUrl;
      try { _selectedCat = widget.categories.firstWhere((c) => c.id == e.categoryId); }
      catch (_) { _selectedCat = widget.categories.isNotEmpty ? widget.categories.first : null; }

      _variantGroups = e.variants.where((v) => !v.isAddonGroup).map((v) => _VariantGroupDraft(
        id: v.id, groupName: v.groupName, minSelect: v.minSelect, maxSelect: v.maxSelect,
        allowRepeat: v.allowRepeat, isActive: v.isActive,
        isDefault: v.isDefault, // ← NEW: load từ server
        ingredients: v.ingredients.map((i) => _IngredientEntry(
          ingredientId: i.ingredientId, ingredientName: i.ingredientName,
          stockDeductPerUnit: i.stockDeductPerUnit, maxSelectableCount: i.maxSelectableCount ?? 1,
        )).toList(),
      )).toList();

      _addonGroups = e.variants.where((v) => v.isAddonGroup).map((v) => _AddonGroupDraft(
        id: v.id, groupName: v.groupName, isActive: v.isActive,
        ingredients: v.ingredients.map((i) => _IngredientEntry(
          ingredientId: i.ingredientId, ingredientName: i.ingredientName,
          stockDeductPerUnit: i.stockDeductPerUnit, addonPrice: i.addonPrice,
        )).toList(),
      )).toList();

      _ensureDefaultAssigned();
    } else {
      _selectedCat = widget.categories.isNotEmpty ? widget.categories.first : null;
      _variantGroups = [];
    }
  }

  @override void dispose() {
    _nameCtrl.dispose(); _descCtrl.dispose(); _priceCtrl.dispose();
    _vatCtrl.dispose(); _shopeePriceCtrl.dispose(); _grabPriceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final xf = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (xf != null && mounted) setState(() => _picked = File(xf.path));
  }

  String? _validateGroups() {
    for (int i = 0; i < _variantGroups.length; i++) {
      final g = _variantGroups[i];
      if (g.groupName.trim().isEmpty) return 'Nhóm ${i + 1}: nhập tên nhóm';
      if (g.ingredients.isEmpty) return 'Nhóm "${g.groupName}": cần ít nhất 1 nguyên liệu';
      if (g.minSelect < 0) return 'Nhóm "${g.groupName}": minSelect không được âm';
      if (g.maxSelect < 1) return 'Nhóm "${g.groupName}": maxSelect phải >= 1';
      if (g.minSelect > g.maxSelect) return 'Nhóm "${g.groupName}": minSelect <= maxSelect';
    }
    return null;
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) { _snack('Nhập tên sản phẩm', Colors.orange); return; }
    if (_selectedCat == null) { _snack('Chọn category', Colors.orange); return; }
    final price = double.tryParse(_priceCtrl.text.replaceAll(',', ''));
    if (price == null || price < 0) { _snack('Nhập giá hợp lệ', Colors.orange); return; }
    final ve = _validateGroups();
    if (ve != null) { _snack(ve, Colors.orange); return; }
    final variantError = _validateVariants();
    if (variantError != null) { _snack(variantError, Colors.orange); return; }
    if (_isShopeeFood) {
      final sp = double.tryParse(_shopeePriceCtrl.text.replaceAll(',', ''));
      if (sp == null || sp <= 0) { _snack('Nhập giá ShopeeFood hợp lệ (> 0)', Colors.orange); return; }
    }
    if (_isGrabFood) {
      final gp = double.tryParse(_grabPriceCtrl.text.replaceAll(',', ''));
      if (gp == null || gp <= 0) { _snack('Nhập giá GrabFood hợp lệ (> 0)', Colors.orange); return; }
    }

    setState(() => _loading = true);
    try {
      String? imageUrl = _existingUrl;
      if (_picked != null) imageUrl = await PosService.uploadImage(filePath: _picked!.path, type: 'pos-product');

      int productId;
      if (_isEdit) {
        final updated = await PosService.updateProduct(widget.existing!.id,
            name: _nameCtrl.text.trim(), categoryId: _selectedCat!.id, basePrice: price,
            description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
            isActive: _isActive, imageUrl: imageUrl,
            vatPercent: int.tryParse(_vatCtrl.text.trim()) ?? 0,
            isShopeeFood: _isShopeeFood, isGrabFood: _isGrabFood,
            shopeePrice: _isShopeeFood ? double.tryParse(_shopeePriceCtrl.text.replaceAll(',', '')) : null,
            grabPrice: _isGrabFood ? double.tryParse(_grabPriceCtrl.text.replaceAll(',', '')) : null);
        productId = updated.id;
      } else {
        final created = await PosService.createProduct(
            name: _nameCtrl.text.trim(), categoryId: _selectedCat!.id, basePrice: price,
            description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
            imageUrl: imageUrl, displayOrder: widget.nextOrder,
            vatPercent: int.tryParse(_vatCtrl.text.trim()) ?? 0,
            isShopeeFood: _isShopeeFood, isGrabFood: _isGrabFood,
            shopeePrice: _isShopeeFood ? double.tryParse(_shopeePriceCtrl.text.replaceAll(',', '')) : null,
            grabPrice: _isGrabFood ? double.tryParse(_grabPriceCtrl.text.replaceAll(',', '')) : null);
        productId = created.id;
      }

      // ── Auto-assign default nếu chỉ có 1 variant ──
      if (_variantGroups.length == 1) _variantGroups.first.isDefault = true;
      // Đảm bảo chỉ 1 default
      _ensureDefaultAssigned();

      for (final g in _variantGroups) {
        if (g.id == null) {
          await PosService.createVariant(g.toCreateBody(productId));
        } else {
          await PosService.updateVariant(g.id!, g.toUpdateBody());
        }
      }
      for (final g in _addonGroups) {
        if (g.id == null) {
          await PosService.createVariant(g.toCreateBody(productId));
        } else {
          await PosService.updateVariant(g.id!, g.toUpdateBody());
        }
      }

      if (mounted) Navigator.pop(context);
      widget.onSuccess();
    } catch (e) { _snack('$e', Colors.red); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  void _snack(String msg, Color c) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg), backgroundColor: c));

  void _addGroup() {
    setState(() {
      final isFirst = _variantGroups.isEmpty;
      _variantGroups.add(_VariantGroupDraft(
        groupName: 'Nhóm ${_variantGroups.length + 1}',
        minSelect: 1, maxSelect: 1, ingredients: [],
        isDefault: isFirst, // ← Nhóm đầu tiên tự động là default
      ));
    });
  }

  void _removeGroup(int i) {
    setState(() {
      _variantGroups.removeAt(i);
      _ensureDefaultAssigned();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _FormSheet(
      title: _isEdit ? 'Sửa sản phẩm' : 'Thêm sản phẩm',
      isLoading: _loading, onSubmit: _submit,
      children: [
        _ImagePickerTile(pickedFile: _picked,
            existingUrl: _existingUrl != null ? PosService.buildImageUrl(_existingUrl) : null,
            onPick: _pickImage, onClear: () => setState(() { _picked = null; _existingUrl = null; })),
        const SizedBox(height: 16),
        _Field(ctrl: _nameCtrl, label: 'Tên sản phẩm *'),
        const SizedBox(height: 12),
        _Field(ctrl: _descCtrl, label: 'Mô tả', maxLines: 2),
        const SizedBox(height: 12),
        _Field(ctrl: _priceCtrl, label: 'Giá gốc *', hint: '0',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly], suffixText: 'đ'),
        const SizedBox(height: 12),
        _Field(ctrl: _vatCtrl, label: 'Thuế VAT (%)', hint: '0', keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        DropdownButtonFormField<PosCategoryModel>(
          value: _selectedCat,
          decoration: InputDecoration(labelText: 'Category *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
          items: widget.categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
          onChanged: (v) => setState(() => _selectedCat = v),
        ),
        if (_isEdit) ...[
          const SizedBox(height: 12),
          _SwitchTile(label: 'Đang hoạt động', value: _isActive,
              onChanged: (v) => setState(() => _isActive = v)),
        ],
        const SizedBox(height: 20),
        _AppPlatformSection(
          isShopeeFood: _isShopeeFood, isGrabFood: _isGrabFood,
          shopeePriceCtrl: _shopeePriceCtrl, grabPriceCtrl: _grabPriceCtrl,
          onShopeeChanged: (v) => setState(() => _isShopeeFood = v),
          onGrabChanged:   (v) => setState(() => _isGrabFood   = v),
        ),
        const SizedBox(height: 24),

        // ── VARIANT GROUPS SECTION ──
        _VariantGroupsSection(
          groups: _variantGroups,
          allIngredients: widget.allIngredients,
          onChanged: () => setState(() {}),
          onAddGroup: _addGroup,
          onRemoveGroup: _removeGroup,
          onDeleteSaved: _isEdit ? _deleteSavedVariant : null,
          onSetDefault: _trySetDefault,  // ← Truyền hàm _trySetDefault xuống
        ),

        if (_variantGroups.isNotEmpty || _addonGroups.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('Addon Group',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500))),
            Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
          ]),
          const SizedBox(height: 8),
        ] else const SizedBox(height: 24),

        _AddonGroupsSection(
          addonGroups: _addonGroups, allIngredients: widget.allIngredients,
          onChanged: () => setState(() {}),
          onDeleteSaved: _isEdit ? _deleteSavedAddonGroup : null,
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════
// APP PLATFORM SECTION
// ══════════════════════════════════════════════════════

class _AppPlatformSection extends StatelessWidget {
  final bool isShopeeFood, isGrabFood;
  final TextEditingController shopeePriceCtrl, grabPriceCtrl;
  final void Function(bool) onShopeeChanged, onGrabChanged;

  const _AppPlatformSection({
    required this.isShopeeFood, required this.isGrabFood,
    required this.shopeePriceCtrl, required this.grabPriceCtrl,
    required this.onShopeeChanged, required this.onGrabChanged,
  });

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Row(children: [
      const Icon(Icons.storefront_outlined, size: 18, color: Colors.deepOrange),
      const SizedBox(width: 6),
      const Text('Bán trên ứng dụng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
    ]),
    const SizedBox(height: 10),
    _PlatformTile(label: 'ShopeeFood', icon: Icons.shopping_bag_outlined,
        color: const Color(0xFFEE4D2D), enabled: isShopeeFood,
        priceCtrl: shopeePriceCtrl, onToggle: onShopeeChanged),
    const SizedBox(height: 10),
    _PlatformTile(label: 'GrabFood', icon: Icons.delivery_dining,
        color: const Color(0xFF00B14F), enabled: isGrabFood,
        priceCtrl: grabPriceCtrl, onToggle: onGrabChanged),
  ]);
}

class _PlatformTile extends StatelessWidget {
  final String label; final IconData icon; final Color color;
  final bool enabled; final TextEditingController priceCtrl;
  final void Function(bool) onToggle;

  const _PlatformTile({required this.label, required this.icon, required this.color,
    required this.enabled, required this.priceCtrl, required this.onToggle});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    decoration: BoxDecoration(
      color: enabled ? color.withOpacity(0.06) : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: enabled ? color.withOpacity(0.4) : Colors.grey.shade200,
          width: enabled ? 1.5 : 1),
    ),
    child: Column(children: [
      SwitchListTile(
        dense: true,
        secondary: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: enabled ? color.withOpacity(0.12) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: enabled ? color : Colors.grey, size: 20),
        ),
        title: Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,
            color: enabled ? color : Colors.grey[600])),
        subtitle: Text(enabled ? 'Đang bán — nhập giá bên dưới' : 'Không bán trên $label',
            style: const TextStyle(fontSize: 11)),
        value: enabled, activeColor: color, onChanged: onToggle,
      ),
      if (enabled)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: TextField(
            controller: priceCtrl, keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Giá $label *', hintText: '0', suffixText: 'đ', isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              labelStyle: TextStyle(color: color),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: color, width: 1.5)),
            ),
          ),
        ),
    ]),
  );
}

// ══════════════════════════════════════════════════════
// VARIANT GROUPS SECTION  ← UPDATED with isDefault
// ══════════════════════════════════════════════════════

class _VariantGroupsSection extends StatelessWidget {
  final List<_VariantGroupDraft> groups;
  final List<Map<String, dynamic>> allIngredients;
  final VoidCallback onChanged;
  final VoidCallback onAddGroup;
  final void Function(int) onRemoveGroup;
  final Future<void> Function(int index, int variantId)? onDeleteSaved;
  final void Function(int index)? onSetDefault; // ← Đã có, giữ nguyên

  const _VariantGroupsSection({
    required this.groups,
    required this.allIngredients,
    required this.onChanged,
    required this.onAddGroup,
    required this.onRemoveGroup,
    this.onDeleteSaved,
    this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        const Icon(Icons.tune, size: 18, color: Colors.deepOrange),
        const SizedBox(width: 6),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Nhóm lựa chọn (Variant Groups)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Text('Mỗi nhóm là 1 bộ lựa chọn độc lập — khách phải chọn đủ mỗi nhóm',
              style: TextStyle(fontSize: 11, color: Colors.grey)),
        ])),
        TextButton.icon(
          onPressed: onAddGroup,
          icon: const Icon(Icons.add_circle_outline, size: 16),
          label: const Text('Thêm nhóm'),
          style: TextButton.styleFrom(foregroundColor: Colors.deepOrange),
        ),
      ]),
      const SizedBox(height: 8),

      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade100)),
        child: const Text(
          '💡 Ví dụ sản phẩm "Xúc xích chiên" có 2 nhóm:\n\n'
              '• Nhóm "Chọn loại xúc xích": chọn 1 từ [Cheddar, Garlic, Thueringer]\n'
              '• Nhóm "Chọn sốt": chọn 1 từ [Sốt cay, Sốt tỏi, Không sốt]\n\n'
              'Khách phải chọn cả 2 nhóm trước khi add vào giỏ.',
          style: TextStyle(fontSize: 11, color: Colors.blueAccent, height: 1.5),
        ),
      ),
      const SizedBox(height: 12),

      if (groups.isNotEmpty)
        ...groups.asMap().entries.map((e) => _VariantGroupCard(
          key: ValueKey('group_${e.value.id ?? e.key}'),
          index: e.key,
          draft: e.value,
          allIngredients: allIngredients,
          totalGroups: groups.length,
          onChanged: onChanged,
          onSetDefault: onSetDefault != null ? () => onSetDefault!(e.key) : null, // ← Sửa đúng: gọi callback cha
          onRemove: () async {
            if (groups.length == 1) {
              await showDialog(
                context: context,
                builder: (dialogCtx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Row(children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                    SizedBox(width: 12),
                    Expanded(child: Text('Không thể xóa', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                  ]),
                  content: const Text('Bạn không thể xóa nhóm lựa chọn cuối cùng.\n\n'
                      'Sản phẩm phải giữ ít nhất 1 nhóm variant để hoạt động đúng.',
                      style: TextStyle(fontSize: 15, height: 1.5)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dialogCtx),
                        child: const Text('Đã hiểu', style: TextStyle(color: Colors.deepOrange, fontSize: 16))),
                  ],
                ),
              );
              return;
            }
            if (e.value.id != null && onDeleteSaved != null) {
              await onDeleteSaved!(e.key, e.value.id!);
            }
            onRemoveGroup(e.key);
          },
        )),
    ]);
  }
}

// ══════════════════════════════════════════════════════
// VARIANT GROUP CARD  ← UPDATED with isDefault star
// ══════════════════════════════════════════════════════

class _VariantGroupCard extends StatefulWidget {
  final int index;
  final _VariantGroupDraft draft;
  final List<Map<String, dynamic>> allIngredients;
  final VoidCallback onChanged;
  final Future<void> Function() onRemove;
  final int totalGroups; // ← NEW
  final VoidCallback? onSetDefault; // ← NEW

  const _VariantGroupCard({
    super.key,
    required this.index,
    required this.draft,
    required this.allIngredients,
    required this.onChanged,
    required this.onRemove,
    required this.totalGroups,
    this.onSetDefault,
  });

  @override State<_VariantGroupCard> createState() => _VariantGroupCardState();
}

class _VariantGroupCardState extends State<_VariantGroupCard> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _minCtrl;
  late final TextEditingController _maxCtrl;
  bool _expanded = true;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.draft.groupName);
    _minCtrl  = TextEditingController(text: '${widget.draft.minSelect}');
    _maxCtrl  = TextEditingController(text: '${widget.draft.maxSelect}');
    _expanded = widget.draft.id == null;
  }

  @override void dispose() { _nameCtrl.dispose(); _minCtrl.dispose(); _maxCtrl.dispose(); super.dispose(); }

  void _openIngPicker() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.white, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _IngredientPickerSheet(
        allIngredients: widget.allIngredients, selected: widget.draft.ingredients, showAddonPrice: false,
        onDone: (result) { setState(() => widget.draft.ingredients = result); widget.onChanged(); },
      ),
    );
  }

  void _confirmAndRemove() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red),
          SizedBox(width: 12),
          Expanded(child: Text('Xóa Nhóm Lựa Chọn', style: TextStyle(fontSize: 18))),
        ]),
        content: Text('Bạn chắc chắn muốn xóa nhóm "${widget.draft.groupName}"?\nHành động này không thể hoàn tác.',
            style: const TextStyle(fontSize: 14, height: 1.45)),
        actionsPadding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(onPressed: () => Navigator.pop(dialogCtx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Xóa')),
        ],
      ),
    );
    if (ok != true || !mounted) { if (mounted) setState(() => _deleting = false); return; }
    setState(() => _deleting = true);
    try { await widget.onRemove(); }
    catch (e) {
      if (mounted) scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Lỗi xóa nhóm: $e'), backgroundColor: Colors.red));
    } finally { if (mounted) setState(() => _deleting = false); }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.draft.ingredients.isEmpty;
    final draft    = widget.draft;
    final isDefault = draft.isDefault;
    final showSetDefault = widget.totalGroups > 1 && !isDefault && widget.onSetDefault != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          // Default variant: nổi bật hơn với viền amber
          color: isDefault
              ? Colors.amber.shade400
              : hasError ? Colors.red.shade200 : Colors.deepOrange.shade300,
          width: isDefault ? 2 : 1.5,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
            child: Row(children: [
              // ── Index badge (ngôi sao nếu là default) ──
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDefault
                      ? Colors.amber.shade500
                      : hasError ? Colors.red.shade400 : Colors.deepOrange,
                ),
                child: Center(
                  child: isDefault
                      ? const Icon(Icons.star_rounded, color: Colors.white, size: 17)
                      : Text('${widget.index + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(
                    draft.groupName.isEmpty ? 'Nhóm ${widget.index + 1}' : draft.groupName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,
                        color: isDefault ? Colors.amber.shade700 : Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  )),
                ]),
                Row(children: [
                  Text(_selectLabel(draft), style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  if (draft.ingredients.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    // ── NL count với ngôi sao nếu default ──
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      if (isDefault) Icon(Icons.star_rounded, size: 11, color: Colors.amber.shade600),
                      if (isDefault) const SizedBox(width: 2),
                      Text('${draft.ingredients.length} NL',
                          style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            color: isDefault ? Colors.amber.shade700 : Colors.teal,
                          )),
                    ]),
                  ],
                ]),
              ])),
              Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey),
              const SizedBox(width: 4),
              if (_deleting)
                const Padding(padding: EdgeInsets.all(8),
                    child: SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red)))
              else
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: _confirmAndRemove, padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(), tooltip: 'Xóa nhóm',
                ),
            ]),
          ),
        ),

        // ── Nút "Đặt mặc định" (chỉ hiện khi có nhiều nhóm và chưa là default) ──
        if (showSetDefault)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: GestureDetector(
              onTap: widget.onSetDefault, // ← Callback này giờ có popup
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.star_border_rounded, size: 16, color: Colors.amber.shade700),
                  const SizedBox(width: 6),
                  Text('Đặt làm nhóm mặc định (dùng cho Thêm nhanh)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                          color: Colors.amber.shade700)),
                ]),
              ),
            ),
          ),

        if (_expanded) ...[
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              TextField(
                controller: _nameCtrl,
                onChanged: (v) { draft.groupName = v; widget.onChanged(); },
                decoration: InputDecoration(
                  labelText: 'Tên nhóm *',
                  hintText: 'VD: Chọn loại xúc xích · Chọn sốt · Combo 3 lẻ',
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Chọn tối thiểu', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _minCtrl, textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (v) { draft.minSelect = int.tryParse(v) ?? 0; widget.onChanged(); },
                    decoration: InputDecoration(isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10)),
                  ),
                ])),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Chọn tối đa', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _maxCtrl, textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (v) { draft.maxSelect = int.tryParse(v) ?? 1; widget.onChanged(); },
                    decoration: InputDecoration(isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10)),
                  ),
                ])),
              ]),
              const SizedBox(height: 8),
              Wrap(spacing: 6, children: [
                _PresetChip(label: 'Chọn 1', onTap: () {
                  setState(() { _minCtrl.text = '1'; _maxCtrl.text = '1'; draft.minSelect = 1; draft.maxSelect = 1; });
                  widget.onChanged();
                }),
                _PresetChip(label: 'Chọn 2', onTap: () {
                  setState(() { _minCtrl.text = '2'; _maxCtrl.text = '2'; draft.minSelect = 2; draft.maxSelect = 2; });
                  widget.onChanged();
                }),
                _PresetChip(label: 'Chọn 3', onTap: () {
                  setState(() { _minCtrl.text = '3'; _maxCtrl.text = '3'; draft.minSelect = 3; draft.maxSelect = 3; });
                  widget.onChanged();
                }),
                _PresetChip(label: 'Tùy chọn (0–3)', onTap: () {
                  setState(() { _minCtrl.text = '0'; _maxCtrl.text = '3'; draft.minSelect = 0; draft.maxSelect = 3; });
                  widget.onChanged();
                }),
              ]),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200)),
                child: SwitchListTile(
                  dense: true,
                  title: const Text('Cho phép chọn lặp cùng nguyên liệu', style: TextStyle(fontSize: 13)),
                  subtitle: Text(
                    draft.allowRepeat ? 'VD: Combo 3 Cheddar → chọn Cheddar 3 lần' : 'Mỗi NL chỉ được chọn 1 lần',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  value: draft.allowRepeat, activeColor: Colors.deepOrange,
                  onChanged: (v) { setState(() => draft.allowRepeat = v); widget.onChanged(); },
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _openIngPicker,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: hasError ? Colors.red.shade300 : Colors.grey.shade300)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.set_meal, size: 16, color: Colors.deepOrange),
                      const SizedBox(width: 6),
                      Expanded(child: Text('Nguyên liệu có thể chọn *',
                          style: TextStyle(fontSize: 13, color: hasError ? Colors.red : Colors.black87,
                              fontWeight: FontWeight.w500))),
                      Text('Nhấn để chọn', style: TextStyle(fontSize: 11, color: Colors.blue.shade400)),
                      const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                    ]),
                    if (draft.ingredients.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Padding(padding: const EdgeInsets.only(bottom: 4),
                          child: Row(children: [
                            const Expanded(child: Text('Nguyên liệu',
                                style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600))),
                            const Text('Số lượng',
                                style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 28),
                          ])),
                      ...draft.ingredients.map((ing) {
                        final isLast = draft.ingredients.length == 1;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.deepOrange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.deepOrange.shade200)),
                          child: Row(children: [
                            Expanded(child: Text(ing.ingredientName,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis)),
                            const SizedBox(width: 8),
                            Row(children: [
                              GestureDetector(
                                onTap: ing.maxSelectableCount > 1
                                    ? () { setState(() => ing.maxSelectableCount--); widget.onChanged(); }
                                    : null,
                                child: Container(
                                  width: 26, height: 26,
                                  decoration: BoxDecoration(shape: BoxShape.circle,
                                      color: ing.maxSelectableCount > 1 ? Colors.deepOrange : Colors.grey.shade200),
                                  child: Icon(Icons.remove, size: 14,
                                      color: ing.maxSelectableCount > 1 ? Colors.white : Colors.grey),
                                ),
                              ),
                              SizedBox(width: 32, child: Text('${ing.maxSelectableCount}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.deepOrange))),
                              GestureDetector(
                                onTap: () { setState(() => ing.maxSelectableCount++); widget.onChanged(); },
                                child: Container(width: 26, height: 26,
                                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.deepOrange),
                                    child: const Icon(Icons.add, size: 14, color: Colors.white)),
                              ),
                            ]),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: isLast
                                  ? () {
                                showDialog(context: context, builder: (dialogCtx) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  title: const Row(children: [
                                    Icon(Icons.warning_amber_rounded, color: Colors.orange),
                                    SizedBox(width: 12),
                                    Expanded(child: Text('Không thể xóa', style: TextStyle(fontSize: 18))),
                                  ]),
                                  content: const Text('Variant phải có ít nhất 1 nguyên liệu.\nVui lòng thêm NL khác trước khi xóa.',
                                      style: TextStyle(fontSize: 14, height: 1.45)),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(dialogCtx).pop(),
                                        child: const Text('Đã hiểu', style: TextStyle(color: Colors.deepOrange))),
                                  ],
                                ));
                              }
                                  : () { setState(() => draft.ingredients.remove(ing)); widget.onChanged(); },
                              child: Icon(Icons.close, size: 16, color: isLast ? Colors.grey.shade300 : Colors.grey),
                            ),
                          ]),
                        );
                      }),
                      const SizedBox(height: 4),
                      Row(children: [
                        Expanded(child: Text(
                          'Tổng: ${draft.ingredients.fold(0, (s, i) => s + i.maxSelectableCount)} NL  •  min/max: ${draft.minSelect}/${draft.maxSelect}',
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                        )),
                        GestureDetector(
                          onTap: () {
                            final total = draft.ingredients.fold(0, (s, i) => s + i.maxSelectableCount);
                            if (total <= 0) return;
                            setState(() { draft.minSelect = total; draft.maxSelect = total; _minCtrl.text = '$total'; _maxCtrl.text = '$total'; });
                            widget.onChanged();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Đã set min/max = $total'),
                              duration: const Duration(seconds: 2), backgroundColor: Colors.deepOrange,
                            ));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.deepOrange.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.deepOrange.shade200)),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.auto_fix_high, size: 12, color: Colors.deepOrange.shade400),
                              const SizedBox(width: 4),
                              Text('Auto-fill min/max', style: TextStyle(fontSize: 10, color: Colors.deepOrange.shade600)),
                            ]),
                          ),
                        ),
                      ]),
                    ] else ...[
                      const SizedBox(height: 6),
                      Text('Chưa chọn nguyên liệu nào...',
                          style: TextStyle(color: hasError ? Colors.red : Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
                    ],
                  ]),
                ),
              ),
            ]),
          ),
        ],
      ]),
    );
  }

  String _selectLabel(_VariantGroupDraft d) {
    if (d.minSelect == d.maxSelect) return 'Chọn đúng ${d.minSelect}';
    if (d.minSelect == 0) return 'Chọn tùy ý (tối đa ${d.maxSelect})';
    return 'Chọn từ ${d.minSelect} đến ${d.maxSelect}';
  }
}

class _PresetChip extends StatelessWidget {
  final String label; final VoidCallback onTap;
  const _PresetChip({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => ActionChip(
    label: Text(label, style: const TextStyle(fontSize: 11)), padding: EdgeInsets.zero,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    backgroundColor: Colors.deepOrange.shade50,
    side: BorderSide(color: Colors.deepOrange.shade200), onPressed: onTap,
  );
}

class _IngredientPickerSheet extends StatefulWidget {
  final List<Map<String, dynamic>> allIngredients;
  final List<_IngredientEntry> selected;
  final void Function(List<_IngredientEntry>) onDone;
  final bool showAddonPrice;

  const _IngredientPickerSheet({required this.allIngredients, required this.selected,
    required this.onDone, this.showAddonPrice = false});
  @override State<_IngredientPickerSheet> createState() => _IngredientPickerSheetState();
}

class _IngredientPickerSheetState extends State<_IngredientPickerSheet> {
  late Set<int> _selectedIds;
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override void initState() { super.initState(); _selectedIds = widget.selected.map((e) => e.ingredientId).toSet(); }
  @override void dispose() { _searchCtrl.dispose(); super.dispose(); }

  void _toggle(int id) => setState(() {
    if (_selectedIds.contains(id)) _selectedIds.remove(id); else _selectedIds.add(id);
  });

  void _done() {
    final result = widget.allIngredients
        .where((ing) => _selectedIds.contains(ing['id'] as int))
        .map((ing) {
      final existing = widget.selected.cast<_IngredientEntry?>()
          .firstWhere((e) => e?.ingredientId == ing['id'], orElse: () => null);
      return _IngredientEntry(
        ingredientId: ing['id'] as int, ingredientName: ing['name'] as String,
        stockDeductPerUnit: existing?.stockDeductPerUnit ?? 1.0,
        maxSelectableCount: existing?.maxSelectableCount ?? 1,
        addonPrice: (ing['addonPrice'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();
    if (result.isEmpty && !widget.showAddonPrice) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Variant phải có ít nhất 1 nguyên liệu'), backgroundColor: Colors.orange));
      return;
    }
    Navigator.pop(context);
    widget.onDone(result);
  }

  List<Map<String, dynamic>> get _filtered => _search.isEmpty ? widget.allIngredients
      : widget.allIngredients.where((ing) =>
      (ing['name'] as String).toLowerCase().contains(_search.toLowerCase())).toList();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65, minChildSize: 0.4, maxChildSize: 0.92, expand: false,
      builder: (_, sc) => Column(children: [
        Container(margin: const EdgeInsets.symmetric(vertical: 10), width: 36, height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              const Text('Chọn nguyên liệu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.deepOrange.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Text('Đã chọn: ${_selectedIds.length}',
                      style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 13))),
            ])),
        const SizedBox(height: 8),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl, onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(hintText: 'Tìm nguyên liệu...', isDense: true,
                  prefixIcon: const Icon(Icons.search, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
            )),
        const Divider(height: 16),
        Expanded(child: ListView.builder(
          controller: sc, itemCount: _filtered.length,
          itemBuilder: (_, i) {
            final ing = _filtered[i]; final id = ing['id'] as int; final sel = _selectedIds.contains(id);
            final addonPrice = (ing['addonPrice'] as num?)?.toDouble() ?? 0.0;
            return CheckboxListTile(
              value: sel, onChanged: (_) => _toggle(id),
              title: Row(children: [
                Expanded(child: Text(ing['name'] as String,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                if (widget.showAddonPrice && addonPrice > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(color: Colors.deepOrange.shade50, borderRadius: BorderRadius.circular(4)),
                    child: Text('+${addonPrice.toStringAsFixed(0)}đ',
                        style: const TextStyle(fontSize: 10, color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                  ),
              ]),
              subtitle: Text('1 bịch = ${ing['unitPerPack']} lẻ', style: const TextStyle(fontSize: 11)),
              activeColor: Colors.deepOrange, dense: true,
              secondary: Container(width: 40, height: 40,
                  decoration: BoxDecoration(color: sel ? Colors.deepOrange.shade50 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.set_meal, color: sel ? Colors.deepOrange : Colors.grey[400], size: 22)),
            );
          },
        )),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
          child: ElevatedButton(
            onPressed: _selectedIds.isEmpty ? null : _done,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text('Xác nhận (${_selectedIds.length} nguyên liệu)'),
          ),
        ),
      ]),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final PosProductModel product; final String Function(double) formatMoney;
  final int dragIndex; final VoidCallback onEdit, onDelete;

  const _ProductCard({super.key, required this.product, required this.formatMoney,
    required this.dragIndex, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 6)]),
    child: ListTile(
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      leading: _ThumbImage(dbPath: product.imageUrl, size: 56, fallback: Icons.fastfood),
      title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(product.categoryName, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Wrap(spacing: 4, runSpacing: 2, children: [
          Text('${formatMoney(product.basePrice)}đ',
              style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 13)),
          if (product.hasVariants)
            _SmallBadge(label: '${product.variants.length} nhóm', color: Colors.blue),
          if (product.singlePrice) _SmallBadge(label: '1 giá', color: Colors.teal),
          ...product.appMenus.map((m) => _SmallBadge(
              label: m.platform == 'SHOPEE_FOOD' ? 'Shopee' : 'Grab',
              color: m.platform == 'SHOPEE_FOOD' ? Colors.orange : Colors.green)),
        ]),
      ]),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        _StatusDot(active: product.isActive),
        const SizedBox(width: 4),
        _OrderBadge(order: product.displayOrder, color: Colors.deepOrange),
        const SizedBox(width: 4),
        _ActionMenu(onEdit: onEdit, onDelete: onDelete),
        const SizedBox(width: 4),
        ReorderableDragStartListener(index: dragIndex,
            child: Padding(padding: const EdgeInsets.all(8),
                child: Icon(Icons.drag_handle, color: Colors.grey.shade400, size: 22))),
      ]),
    ),
  );
}

// ══════════════════════════════════════════════════════
// TAB: INGREDIENT (unchanged)
// ══════════════════════════════════════════════════════

class _IngredientTab extends StatefulWidget {
  const _IngredientTab({super.key});
  @override State<_IngredientTab> createState() => _IngredientTabState();
}

class _IngredientTabState extends State<_IngredientTab> {
  List<Map<String, dynamic>> _all = [];
  bool _loading = true, _reordering = false;

  @override void initState() { super.initState(); _load(); }

  Future<void> _reorderGroup(List<Map<String, dynamic>> groupItems, int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    setState(() {
      final item = groupItems.removeAt(oldIndex);
      groupItems.insert(newIndex, item);
      for (int i = 0; i < groupItems.length; i++) {
        final allIdx = _all.indexOf(groupItems[i]);
        if (allIdx >= 0) {
          _all[allIdx] = Map<String, dynamic>.from(_all[allIdx])..['displayOrder'] = i + 1;
          groupItems[i] = _all[allIdx];
        }
      }
    });
    setState(() => _reordering = true);
    try {
      await Future.wait(groupItems.map((ing) => PosService.updateIngredient(
          ing['id'] as int, name: ing['name'] as String,
          unitPerPack: ing['unitPerPack'] as int? ?? 1, displayOrder: ing['displayOrder'] as int)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi lưu thứ tự: $e'), backgroundColor: Colors.red));
    } finally { if (mounted) setState(() => _reordering = false); }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await PosService.getIngredients();
      if (mounted) setState(() {
        _all = [...data]..sort((a, b) =>
            ((a['displayOrder'] as int? ?? 0)).compareTo((b['displayOrder'] as int? ?? 0)));
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.red));
        setState(() => _loading = false);
      }
    }
  }

  int get _nextOrder => _all.isEmpty ? 1
      : _all.map((i) => (i['displayOrder'] as int? ?? 0)).reduce((a, b) => a > b ? a : b) + 1;
  void showAddForm() => _showIngredientForm(context, null, _load, nextOrder: _nextOrder);

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_all.isEmpty) return const _EmptyState(icon: Icons.inventory_2_outlined, label: 'Chưa có nguyên liệu nào');

    final mainItems = _all.where((i) => (i['ingredientType'] as String?) != 'SUB').toList();
    final subItems  = _all.where((i) => (i['ingredientType'] as String?) == 'SUB').toList();

    return Stack(children: [
      RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            _ingGroup('Nguyên liệu Chính', mainItems, const Color(0xFF1976D2),
                const Color(0xFFE3F2FD), const Color(0xFF90CAF9), Icons.star_outline),
            const SizedBox(height: 16),
            _ingGroup('Nguyên liệu Phụ / Addon', subItems, const Color(0xFFE65100),
                const Color(0xFFFFF3E0), const Color(0xFFFFCC80), Icons.add_circle_outline),
          ],
        ),
      ),
      if (_reordering) _SavingIndicator(),
    ]);
  }

  Widget _ingGroup(String title, List<Map<String, dynamic>> items,
      Color textColor, Color bgColor, Color borderColor, IconData icon) {
    return Container(
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(children: [
              Icon(icon, size: 18, color: textColor), const SizedBox(width: 6),
              Text('$title (${items.length})',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
            ])),
        if (items.isEmpty)
          Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Text('Chưa có nguyên liệu',
                  style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 13, fontStyle: FontStyle.italic)))
        else
          ReorderableListView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            itemCount: items.length,
            onReorder: (o, n) => _reorderGroup(items, o, n),
            buildDefaultDragHandles: false,
            itemBuilder: (_, i) {
              final ing = items[i];
              return _IngredientCard(
                key: ValueKey(ing['id']), ingredient: ing, dragIndex: i,
                onEdit: () => _showIngredientForm(context, ing, _load, nextOrder: _nextOrder),
                onDelete: () => _confirmDelete(context, name: ing['name'] as String,
                    onConfirm: () async { await PosService.deleteIngredient(ing['id'] as int); _load(); }),
              );
            },
          ),
      ]),
    );
  }
}

void _showIngredientForm(BuildContext ctx, Map<String, dynamic>? existing, VoidCallback onSuccess,
    {int nextOrder = 0}) {
  showModalBottomSheet(context: ctx, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _IngredientFormSheet(existing: existing, onSuccess: onSuccess, nextOrder: nextOrder));
}

class _IngredientFormSheet extends StatefulWidget {
  final Map<String, dynamic>? existing;
  final VoidCallback onSuccess;
  final int nextOrder;
  const _IngredientFormSheet({this.existing, required this.onSuccess, this.nextOrder = 0});
  @override State<_IngredientFormSheet> createState() => _IngredientFormSheetState();
}

class _IngredientFormSheetState extends State<_IngredientFormSheet> {
  final _nameCtrl = TextEditingController();
  final _unitCtrl = TextEditingController(text: '1');
  final _addonPriceCtrl = TextEditingController(text: '0');
  String _ingredientType = 'MAIN';
  bool _loading = false;
  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _nameCtrl.text = widget.existing!['name'] as String;
      _unitCtrl.text = '${widget.existing!['unitPerPack'] ?? 1}';
      _ingredientType = widget.existing!['ingredientType'] as String? ?? 'MAIN';
      _addonPriceCtrl.text = '${((widget.existing!['addonPrice'] as num?)?.toDouble() ?? 0).toStringAsFixed(0)}';
    }
  }

  @override void dispose() { _nameCtrl.dispose(); _unitCtrl.dispose(); _addonPriceCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) { _snack('Nhập tên nguyên liệu', Colors.orange); return; }
    final u = int.tryParse(_unitCtrl.text);
    if (u == null || u < 1) { _snack('Số lẻ/bịch phải >= 1', Colors.orange); return; }
    setState(() => _loading = true);
    try {
      if (_isEdit) {
        await PosService.updateIngredient(widget.existing!['id'] as int,
            name: _nameCtrl.text.trim(), unitPerPack: u,
            displayOrder: widget.existing!['displayOrder'] as int? ?? 0,
            ingredientType: _ingredientType,
            addonPrice: double.tryParse(_addonPriceCtrl.text) ?? 0);
      } else {
        await PosService.createIngredient(name: _nameCtrl.text.trim(), unitPerPack: u,
            displayOrder: widget.nextOrder, ingredientType: _ingredientType,
            addonPrice: double.tryParse(_addonPriceCtrl.text) ?? 0);
      }
      if (mounted) Navigator.pop(context);
      widget.onSuccess();
    } catch (e) { _snack('$e', Colors.red); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  void _snack(String msg, Color c) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg), backgroundColor: c));

  Widget _typeBtn(String value, String label, Color color) {
    final sel = _ingredientType == value;
    return GestureDetector(
      onTap: () => setState(() => _ingredientType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: sel ? color.withOpacity(0.15) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: sel ? color : Colors.grey.shade300, width: sel ? 1.5 : 1),
        ),
        child: Center(child: Text(label, style: TextStyle(fontSize: 13,
            fontWeight: sel ? FontWeight.bold : FontWeight.normal,
            color: sel ? color : Colors.grey[600]))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _FormSheet(
    title: _isEdit ? 'Sửa nguyên liệu' : 'Thêm nguyên liệu',
    isLoading: _loading, onSubmit: _submit,
    children: [
      _Field(ctrl: _nameCtrl, label: 'Tên nguyên liệu *', hint: 'VD: Cheddar'),
      const SizedBox(height: 12),
      _Field(ctrl: _unitCtrl, label: 'Số lẻ trong 1 bịch *', hint: '1',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          helperText: 'VD: 1 bịch Cheddar = 5 lẻ → nhập 5'),
      const SizedBox(height: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Loại nguyên liệu', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(child: _typeBtn('MAIN', 'Chính', Colors.lightBlue)),
          const SizedBox(width: 8),
          Expanded(child: _typeBtn('SUB', 'Phụ', Colors.orange)),
        ]),
      ]),
      const SizedBox(height: 12),
      _Field(ctrl: _addonPriceCtrl, label: 'Giá Addon (khi dùng trong nhóm thêm món)',
          hint: '0', helperText: '0 = không tính tiền thêm khi chọn NL này',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly], suffixText: 'đ'),
    ],
  );
}

class _IngredientCard extends StatelessWidget {
  final Map<String, dynamic> ingredient; final int dragIndex;
  final VoidCallback onEdit, onDelete;
  const _IngredientCard({super.key, required this.ingredient, required this.dragIndex,
    required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final name        = ingredient['name'] as String;
    final unitPerPack = ingredient['unitPerPack'] as int? ?? 1;
    final isActive    = ingredient['isActive'] as bool? ?? true;
    final order       = ingredient['displayOrder'] as int? ?? 0;
    final isSub       = (ingredient['ingredientType'] as String?) == 'SUB';
    final addonPrice  = (ingredient['addonPrice'] as num?)?.toDouble() ?? 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 6)]),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        leading: _ThumbImage(dbPath: ingredient['imageUrl'] as String?, size: 52, fallback: Icons.set_meal),
        title: Row(children: [
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          if (isSub) Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(4)),
            child: const Text('Phụ', style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
          ),
          if (addonPrice > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.deepOrange.shade50, borderRadius: BorderRadius.circular(4)),
              child: Text('+${addonPrice.toStringAsFixed(0)}đ',
                  style: const TextStyle(fontSize: 10, color: Colors.deepOrange, fontWeight: FontWeight.bold)),
            ),
          ],
        ]),
        subtitle: Row(children: [
          const Icon(Icons.inventory_2_outlined, size: 12, color: Colors.grey), const SizedBox(width: 4),
          Text('1 bịch = $unitPerPack lẻ', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(width: 8), _StatusDot(active: isActive),
        ]),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          _OrderBadge(order: order, color: Colors.teal), const SizedBox(width: 4),
          _ActionMenu(onEdit: onEdit, onDelete: onDelete), const SizedBox(width: 4),
          ReorderableDragStartListener(index: dragIndex,
              child: Padding(padding: const EdgeInsets.all(8),
                  child: Icon(Icons.drag_handle, color: Colors.grey.shade400, size: 22))),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// SHARED WIDGETS
// ══════════════════════════════════════════════════════

class _SavingIndicator extends StatelessWidget {
  @override Widget build(BuildContext context) => Positioned(
    top: 12, left: 0, right: 0,
    child: Center(child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)),
      child: const Row(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
        SizedBox(width: 8),
        Text('Đang lưu thứ tự...', style: TextStyle(color: Colors.white, fontSize: 12)),
      ]),
    )),
  );
}

class _FormSheet extends StatelessWidget {
  final String title; final bool isLoading; final VoidCallback onSubmit; final List<Widget> children;
  const _FormSheet({required this.title, required this.isLoading, required this.onSubmit, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
        decoration: const BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(margin: const EdgeInsets.only(top: 12), width: 36, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          Padding(padding: const EdgeInsets.fromLTRB(20, 14, 8, 0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ])),
          const Divider(height: 1),
          Flexible(child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
          )),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange,
                  disabledBackgroundColor: Colors.grey[300], foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: isLoading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : const Text('Lưu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ImagePickerTile extends StatelessWidget {
  final File? pickedFile; final String? existingUrl; final VoidCallback onPick, onClear;
  const _ImagePickerTile({this.pickedFile, this.existingUrl, required this.onPick, required this.onClear});
  bool get _has => pickedFile != null || (existingUrl != null && existingUrl!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPick,
      child: Container(height: 140,
          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _has ? Colors.deepOrange.shade200 : Colors.grey.shade300, width: _has ? 2 : 1)),
          child: ClipRRect(borderRadius: BorderRadius.circular(13),
              child: Stack(fit: StackFit.expand, children: [
                if (pickedFile != null) Image.file(pickedFile!, fit: BoxFit.cover)
                else if (existingUrl != null && existingUrl!.isNotEmpty)
                  CachedNetworkImage(imageUrl: existingUrl!, fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: Colors.grey[100]),
                      errorWidget: (_, __, ___) => _ph())
                else _ph(),
                if (!_has) Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey[400]),
                  const SizedBox(height: 6),
                  Text('Chọn ảnh từ thư viện', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                ])),
                if (_has) Positioned(bottom: 0, left: 0, right: 0,
                    child: Container(padding: const EdgeInsets.symmetric(vertical: 5), color: Colors.black38,
                        child: const Text('Nhấn để đổi ảnh', textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 11)))),
                if (_has) Positioned(top: 6, right: 6,
                    child: GestureDetector(onTap: onClear, child: Container(padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                        child: const Icon(Icons.close, size: 16, color: Colors.white)))),
              ]))),
    );
  }
  Widget _ph() => Container(color: Colors.grey.shade100,
      child: Center(child: Icon(Icons.image_outlined, size: 52, color: Colors.grey[300])));
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl; final String label;
  final String? hint, helperText, suffixText; final int maxLines;
  final TextInputType keyboardType; final List<TextInputFormatter>? inputFormatters;

  const _Field({required this.ctrl, required this.label, this.hint, this.helperText,
    this.suffixText, this.maxLines = 1, this.keyboardType = TextInputType.text, this.inputFormatters});

  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl, maxLines: maxLines, keyboardType: keyboardType, inputFormatters: inputFormatters,
    decoration: InputDecoration(labelText: label, hintText: hint, helperText: helperText, suffixText: suffixText,
        isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
  );
}

class _SwitchTile extends StatelessWidget {
  final String label; final String? subtitle; final bool value; final void Function(bool) onChanged;
  const _SwitchTile({required this.label, this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200)),
    child: SwitchListTile(dense: true, title: Text(label, style: const TextStyle(fontSize: 14)),
        subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 11, color: Colors.grey)) : null,
        value: value, activeColor: Colors.deepOrange, onChanged: onChanged),
  );
}

class _ThumbImage extends StatelessWidget {
  final String? dbPath; final double size; final IconData fallback;
  const _ThumbImage({this.dbPath, required this.size, required this.fallback});

  @override
  Widget build(BuildContext context) {
    final rawUrl = PosService.buildImageUrl(dbPath);
    final versionedUrl = "$rawUrl?v=${dbPath.hashCode}";
    return ClipRRect(borderRadius: BorderRadius.circular(10),
        child: rawUrl.isNotEmpty
            ? CachedNetworkImage(imageUrl: versionedUrl, width: size, height: size, fit: BoxFit.cover,
            placeholder: (_, __) => Container(width: size, height: size, color: Colors.grey.shade100),
            errorWidget: (_, __, ___) => _box())
            : _box());
  }
  Widget _box() => Container(width: size, height: size, color: Colors.grey.shade100,
      child: Icon(fallback, color: Colors.grey[400], size: size * 0.5));
}

class _StatusDot extends StatelessWidget {
  final bool active; const _StatusDot({required this.active});
  @override Widget build(BuildContext context) => Container(width: 8, height: 8,
      decoration: BoxDecoration(shape: BoxShape.circle, color: active ? Colors.green : Colors.grey));
}

class _OrderBadge extends StatelessWidget {
  final int order; final Color color;
  const _OrderBadge({required this.order, required this.color});
  @override Widget build(BuildContext context) => Container(
    width: 26, height: 26,
    decoration: BoxDecoration(color: color.withOpacity(0.08), shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.3))),
    child: Center(child: Text('$order', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color.withOpacity(0.8)))),
  );
}

class _SmallBadge extends StatelessWidget {
  final String label; final Color color;
  const _SmallBadge({required this.label, required this.color});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.4))),
    child: Text(label, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold)),
  );
}

class _ActionMenu extends StatelessWidget {
  final VoidCallback onEdit, onDelete;
  const _ActionMenu({required this.onEdit, required this.onDelete});
  @override Widget build(BuildContext context) => PopupMenuButton<String>(
    icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
    onSelected: (v) { if (v == 'edit') onEdit(); if (v == 'delete') onDelete(); },
    itemBuilder: (_) => const [
      PopupMenuItem(value: 'edit', child: Row(children: [
        Icon(Icons.edit_outlined, size: 18, color: Colors.blue), SizedBox(width: 8), Text('Sửa')])),
      PopupMenuItem(value: 'delete', child: Row(children: [
        Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8),
        Text('Xóa', style: TextStyle(color: Colors.red))])),
    ],
  );
}

class _EmptyState extends StatelessWidget {
  final IconData icon; final String label;
  const _EmptyState({required this.icon, required this.label});
  @override Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 64, color: Colors.grey[300]), const SizedBox(height: 12),
    Text(label, style: const TextStyle(color: Colors.grey, fontSize: 15)),
  ]));
}

class _Chip extends StatelessWidget {
  final String label; final bool selected; final VoidCallback onTap;
  const _Chip({required this.label, required this.selected, required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
            color: selected ? Colors.deepOrange : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? Colors.deepOrange : Colors.grey.shade300)),
        child: Text(label, style: TextStyle(fontSize: 12,
            color: selected ? Colors.white : Colors.black87,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal))),
  );
}

Future<void> _confirmDelete(BuildContext context,
    {required String name, required Future<void> Function() onConfirm}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(children: [
        Icon(Icons.warning_amber_rounded, color: Colors.red), SizedBox(width: 8), Text('Xác nhận xóa'),
      ]),
      content: RichText(text: TextSpan(style: const TextStyle(color: Colors.black87, fontSize: 14), children: [
        const TextSpan(text: 'Bạn chắc chắn muốn xóa '),
        TextSpan(text: '"$name"', style: const TextStyle(fontWeight: FontWeight.bold)),
        const TextSpan(text: '?\nHành động này không thể hoàn tác.'),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
        ElevatedButton(onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Xóa')),
      ],
    ),
  );
  if (ok == true && context.mounted) {
    try { await onConfirm(); }
    catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
    }
  }
}