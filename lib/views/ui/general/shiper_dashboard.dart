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

class ShiperDashboard extends StatefulWidget {
  const ShiperDashboard({super.key});

  @override
  State<ShiperDashboard> createState() => _ShiperDashboardState();
}

class _ShiperDashboardState extends State<ShiperDashboard> with UIMixin {
  DashboardController controller = Get.put(DashboardController());

  @override
  void initState() {
    super.initState();
    controller = Get.put(DashboardController(), tag: 'dashboard_controller');
  }

  // ✅ Xóa controller khi widget bị dispose
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'dashboard_controller',
      builder: (controller) {
        return Layout(
          screenName: "WELCOME!",
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
        );
      },
    );
  }
}
