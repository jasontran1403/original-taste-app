import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/ui/custom/pages/maintenance_controller.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/images.dart';
import 'package:original_taste/views/layout/auth_layout.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> with UIMixin{
  MaintenanceController controller = Get.put(MaintenanceController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) {
      return AuthLayout(
        child: Column(
          children: [
            Image.asset(Images.darkLogo, height: 24),
            MySpacing.height(24),
            Image.asset("assets/maintenance-2.png"),
            MySpacing.height(24),
            MyText.titleLarge("We are currently performing maintenance",fontWeight: 700),
            MySpacing.height(12),
            MyText.bodyMedium("We're making the system more awesome. We'll be back shortly.",textAlign: TextAlign.center),
            MySpacing.height(24),
            MyContainer(
              color: contentTheme.primary,
              borderRadiusAll: 12,
              paddingAll: 12,
              onTap: (){
                Get.back();
              },
              child: MyText.bodyMedium("Back to Home",color: contentTheme.onPrimary),
            )
          ],
        ),
      );
    },);
  }
}
