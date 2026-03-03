import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/parse_route.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/helper/services/seller_services.dart';
import 'package:original_taste/helper/theme/app_theme.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';

class PricePickerDialog extends StatefulWidget {
  final ProductModel product;

  const PricePickerDialog({super.key, required this.product});

  /// Returns the selected [ProductPriceModel] or null if dismissed.
  static Future<ProductPriceModel?> show(
      BuildContext context, ProductModel product) {
    return showDialog<ProductPriceModel>(
      context: context,
      builder: (_) => PricePickerDialog(product: product),
    );
  }

  @override
  State<PricePickerDialog> createState() => _PricePickerDialogState();
}

class _PricePickerDialogState extends State<PricePickerDialog>
    with UIMixin {
  ProductPriceModel? selected;

  @override
  void initState() {
    super.initState();
    // Pre-select giá mặc định
    final prices = widget.product.prices;
    if (prices.isNotEmpty) {
      selected = prices.firstWhereOrNull((p) => p.isDefault) ?? prices.first;
    }
  }

  String _fmt(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M đ';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K đ';
    return '${value.toStringAsFixed(0)} đ';
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final prices = product.prices;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: product.imageUrl != null
                    ? Image.network(
                  SellerService.buildImageUrl(product.imageUrl!),
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
                    : _placeholder(),
              ),
              MySpacing.width(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.bodyMedium(product.name,
                        fontWeight: 700,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    if (product.categoryName != null)
                      MyText.bodySmall(product.categoryName!, muted: true),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ]),

            MySpacing.height(16),
            MyText.bodyMedium('Chọn mức giá',
                style: TextStyle(
                    fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                    fontWeight: FontWeight.w600)),
            MySpacing.height(10),

            if (prices.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: MyText.bodyMedium('Sản phẩm chưa có mức giá nào',
                    muted: true),
              )
            else
              ...prices.map((price) => _PriceTile(
                price: price,
                isSelected: selected?.id == price.id,
                formatCurrency: _fmt,
                onTap: () => setState(() => selected = price),
              )),

            MySpacing.height(16),

            // Confirm button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selected == null
                    ? null
                    : () => Navigator.pop(context, selected),
                style: ElevatedButton.styleFrom(
                  backgroundColor: contentTheme.primary,
                  foregroundColor: contentTheme.onPrimary,
                  disabledBackgroundColor:
                  contentTheme.secondary.withValues(alpha: 0.2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: MyText.bodyMedium(
                  selected != null
                      ? 'Thêm vào giỏ — ${_fmt(selected!.price)}'
                      : 'Chọn giá để thêm vào giỏ',
                  fontWeight: 700,
                  color: selected != null
                      ? contentTheme.onPrimary
                      : contentTheme.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: contentTheme.secondary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(Icons.fastfood_outlined,
        size: 24, color: contentTheme.secondary),
  );
}

class _PriceTile extends StatelessWidget with UIMixin {
  final ProductPriceModel price;
  final bool isSelected;
  final String Function(double) formatCurrency;
  final VoidCallback onTap;

  const _PriceTile({
    required this.price,
    required this.isSelected,
    required this.formatCurrency,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? contentTheme.primary.withValues(alpha: 0.08)
              : contentTheme.secondary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? contentTheme.primary
                : contentTheme.secondary.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            size: 20,
            color: isSelected ? contentTheme.primary : contentTheme.secondary,
          ),
          MySpacing.width(10),
          Expanded(
            child: MyText.bodyMedium(price.priceName,
                fontWeight: isSelected ? 700 : 500),
          ),
          MyText.bodyMedium(
            formatCurrency(price.price),
            fontWeight: 700,
            color: contentTheme.primary,
          ),
          if (price.isDefault) ...[
            MySpacing.width(8),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: contentTheme.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: MyText.labelSmall('MĐ',
                  color: contentTheme.success, fontWeight: 700),
            ),
          ],
        ]),
      ),
    );
  }
}