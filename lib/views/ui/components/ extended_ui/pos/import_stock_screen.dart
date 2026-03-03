// lib/views/ui/components/extended_ui/pos/import_stock_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:original_taste/helper/services/pos_service.dart';

class ImportStockScreen extends StatefulWidget {
  const ImportStockScreen({super.key});

  @override
  State<ImportStockScreen> createState() => _ImportStockScreenState();
}

class _ImportStockScreenState extends State<ImportStockScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _ingredients = [];
  final Map<int, TextEditingController> _packCtrl = {};

  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }

  @override
  void dispose() {
    for (final c in _packCtrl.values) c.dispose();
    super.dispose();
  }

  Future<void> _loadIngredients() async {
    setState(() => _isLoading = true);
    try {
      final ingredients = await PosService.getIngredients();
      if (mounted) {
        setState(() {
          _ingredients = ingredients;
          for (final ing in ingredients) {
            final id = ing['id'] as int;
            _packCtrl[id] = TextEditingController(text: '0');
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải nguyên liệu: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<StockImportItem> _buildImportItems() {
    return _ingredients.map((ing) {
      final id = ing['id'] as int;
      final pack = int.tryParse(_packCtrl[id]?.text ?? '0') ?? 0;
      return StockImportItem(ingredientId: id, packQty: pack);
    }).where((item) => item.packQty > 0).toList();
  }

  Future<void> _submitImport() async {
    final items = _buildImportItems();
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập ít nhất 1 nguyên liệu'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final imported = await PosService.importStock(items);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nhập kho thành công! (${imported.length} mục)'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } on Exception catch (e) {
      if (mounted) {
        String errorMsg = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi nhập kho: $errorMsg'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi không xác định: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Nhập kho', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              icon: _isLoading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save_outlined, size: 20),
              label: const Text('Lưu nhập kho', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isLoading ? null : _submitImport,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ingredients.isEmpty
          ? const Center(child: Text('Không có nguyên liệu nào', style: TextStyle(fontSize: 18, color: Colors.grey)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green.shade700, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Nhập số lượng bịch nguyên liệu cần nhập vào kho.',
                      style: TextStyle(fontSize: 14, color: Colors.green.shade800, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            _buildGroupedInventoryGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedInventoryGrid() {
    final mainList = _ingredients.where((i) => (i['ingredientType'] as String?)?.toUpperCase() != 'SUB').toList();
    final subList = _ingredients.where((i) => (i['ingredientType'] as String?)?.toUpperCase() == 'SUB').toList();

    return Column(
      children: [
        if (mainList.isNotEmpty)
          _IngredientGroupCard(title: 'Nguyên liệu Chính', icon: Icons.kitchen_outlined, color: Colors.blue, ingredients: mainList, packCtrl: _packCtrl),
        if (mainList.isNotEmpty && subList.isNotEmpty) const SizedBox(height: 16),
        if (subList.isNotEmpty)
          _IngredientGroupCard(title: 'Nguyên liệu Phụ', icon: Icons.add_box_outlined, color: Colors.deepOrange, ingredients: subList, packCtrl: _packCtrl),
      ],
    );
  }
}

class _IngredientGroupCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Map<String, dynamic>> ingredients;
  final Map<int, TextEditingController> packCtrl;

  const _IngredientGroupCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.ingredients,
    required this.packCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.18)),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: color.withOpacity(0.07), borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
            child: Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color.withOpacity(0.9))),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                  child: Text('${ingredients.length}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                ),
              ],
            ),
          ),
          ...ingredients.map((ing) {
            final id = ing['id'] as int;
            final name = ing['name'] as String;
            final unitPerPack = ing['unitPerPack'] as int? ?? 1;
            final imageUrl = ing['imageUrl'] as String?;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade100))),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageUrl != null
                        ? CachedNetworkImage(
                      imageUrl: PosService.buildImageUrl(imageUrl),
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _placeholder(),
                    )
                        : _placeholder(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        Text('1 bịch = $unitPerPack lẻ', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                  _NumberInput(controller: packCtrl[id]!, label: 'Bịch'),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(width: 44, height: 44, color: Colors.grey[100], child: const Icon(Icons.set_meal, color: Colors.grey, size: 22));
}

// Widget chung cho input số (dùng cho cả 2 screen)
class _NumberInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _NumberInput({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        SizedBox(
          width: 54,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              border: OutlineInputBorder(),
              hintText: '0',
            ),
            // FIX: Chọn toàn bộ nội dung khi tap → nhập mới sẽ ghi đè
            onTap: () {
              controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length);
            },
          ),
        ),
      ],
    );
  }
}