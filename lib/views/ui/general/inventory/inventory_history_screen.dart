import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/helper/theme/app_theme.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_flex.dart';
import 'package:original_taste/helper/widgets/my_flex_item.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/views/layout/layout.dart';
import 'package:intl/intl.dart';
import 'package:original_taste/views/ui/general/inventory/import_warehouse_screen.dart';

import '../../../../controller/seller/inventory_history_controller.dart';
import '../../../../helper/services/seller_services.dart';

class InventoryHistoryScreen extends StatefulWidget {
  const InventoryHistoryScreen({super.key});

  @override
  State<InventoryHistoryScreen> createState() => _InventoryHistoryScreenState();
}

class _InventoryHistoryScreenState extends State<InventoryHistoryScreen> with UIMixin {
  late final InventoryHistoryController controller;

  @override
  void initState() {
    super.initState();
    // Đăng ký lazy (chỉ đăng ký 1 lần, không gán trực tiếp)
    Get.lazyPut<InventoryHistoryController>(() => InventoryHistoryController());
    // Lấy instance đã đăng ký
    controller = Get.find<InventoryHistoryController>();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InventoryHistoryController>(
      init: controller,
      builder: (controller) {
        return Layout(
          screenName: "LỊCH SỬ XUẤT/NHẬP KHO",
          child: MyFlex(
            children: [
              MyFlexItem(
                sizes: 'lg-12',
                child: MyCard(
                  shadow: MyShadow(elevation: 0.5, position: MyShadowPosition.bottom),
                  borderRadiusAll: 12,
                  paddingAll: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Padding(
                        padding: MySpacing.all(20),
                        child: Row(
                          children: [
                            // Nút back
                            MyContainer.bordered(
                              onTap: () => Get.back(),
                              color: Colors.transparent,
                              borderRadiusAll: 10,
                              padding: MySpacing.xy(12, 8),
                              borderColor: contentTheme.secondary.withOpacity(0.4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.arrow_back_rounded, size: 16, color: contentTheme.secondary),
                                  MySpacing.width(6),
                                  MyText.bodyMedium('Quay lại', color: contentTheme.secondary, fontWeight: 600),
                                ],
                              ),
                            ),
                            MySpacing.width(12),

                            // Tiêu đề
                            Expanded(
                              child: MyText.titleMedium(
                                controller.ingredientName.isNotEmpty
                                    ? 'Lịch sử: ${controller.ingredientName}'
                                    : 'Lịch sử xuất/nhập kho',
                                style: TextStyle(
                                  fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Divider(height: 0),

                      // Header bảng (cố định)
                      Container(
                        color: contentTheme.primary.withOpacity(0.08),
                        padding: MySpacing.xy(20, 12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: MyText.bodyMedium("Nguyên liệu / Ngày", fontWeight: 700),
                            ),
                            Expanded(
                              flex: 4,
                              child: Center(
                                child: MyText.bodyMedium("Mục đích", fontWeight: 700),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: MyText.bodyMedium("Số lượng", textAlign: TextAlign.right, fontWeight: 700),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: MyText.bodyMedium("Trạng thái", fontWeight: 700),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Nội dung
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.55, // điều chỉnh chiều cao phù hợp
                        child: RefreshIndicator(
                          onRefresh: controller.fetchLogs,
                          child: controller.isLoading.value && controller.logs.isEmpty
                              ? const Center(child: CircularProgressIndicator())
                              : controller.logs.isEmpty
                              ? Center(
                            child: MyText.bodyMedium(
                              "Chưa có lịch sử xuất/nhập kho",
                              muted: true,
                            ),
                          )
                              : ListView.builder(
                            controller: controller.scrollController,
                            itemCount: controller.logs.length + (controller.hasMore.value ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == controller.logs.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }
                              final log = controller.logs[index];
                              return _buildLogItem(log);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogItem(InventoryLogModel log) {
    final date = DateTime.fromMillisecondsSinceEpoch(log.createdAt ?? 0);
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);

    // Hiển thị quantity + unit trong cùng ô
    final quantityText = "${log.quantity.toStringAsFixed(2)}${log.unit != null && log.unit!.isNotEmpty ? ' ${log.unit}' : ''}";

    return Container(
      padding: MySpacing.xy(20, 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Cột 1: Tên + Ngày
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.bodyMedium(
                  log.ingredientName ?? "Không xác định",
                  fontWeight: 600,
                ),
                MySpacing.height(4),
                MyText.bodySmall(
                  formattedDate,
                  muted: true,
                  fontSize: 12,
                ),
              ],
            ),
          ),

          // Cột 2: Mục đích
          Expanded(
            flex: 4,
            child: Center(
              child: MyText.bodyMedium(
                log.purpose ?? "Không rõ",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Cột 3: Số lượng + unit
          Expanded(
            flex: 2,
            child: MyText.bodyMedium(
              quantityText,
              textAlign: TextAlign.right,
              color: log.purpose.contains("Nhập") ? contentTheme.success : contentTheme.danger,
              fontWeight: 600,
            ),
          ),

          // Cột 4: Status
          Expanded(
            flex: 2,
            child: Center(
              child: MyContainer(
                color: contentTheme.success.withAlpha(20),
                padding: MySpacing.xy(12, 6),
                borderRadiusAll: 6,
                child: MyText.bodySmall(
                  log.status ?? "Completed",
                  color: contentTheme.success,
                  fontWeight: 600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}