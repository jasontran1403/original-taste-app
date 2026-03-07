import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/ui/general/dashboard_controller.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_flex.dart';
import 'package:original_taste/helper/widgets/my_flex_item.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/views/layout/layout.dart';

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({super.key});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> with UIMixin {
  DashboardController controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      init: controller,
      tag: 'dashboard_controller',
      builder: (controller) {
        return Layout(
          screenName: "WELCOME!",
          child: SingleChildScrollView(  // ← Thêm scroll toàn màn hình
            physics: const AlwaysScrollableScrollPhysics(), // Hoặc BouncingScrollPhysics() cho mượt iOS
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Padding bottom lớn để tránh che bởi bottom nav/FAB
            child: MyFlex(
              children: [
                MyFlexItem(
                  sizes: 'xl-5 lg-6',
                  child: Column(
                    children: [
                      MyContainer(
                        color: contentTheme.primary.withValues(alpha: 0.2),
                        borderRadiusAll: 12,
                        width: double.infinity,
                        child: MyText.bodyMedium(
                          "We regret to inform you that our server is currently experiencing technical difficulties.",
                          fontWeight: 600,
                          maxLines: 1,
                        ),
                      ),
                      MySpacing.height(20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

