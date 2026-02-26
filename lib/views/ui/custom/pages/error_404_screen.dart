import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/ui/custom/pages/error_404_controller.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/images.dart';
import 'package:original_taste/views/layout/auth_layout.dart';

class Error404Screen extends StatefulWidget {
  const Error404Screen({super.key});

  @override
  State<Error404Screen> createState() => _Error404ScreenState();
}

class _Error404ScreenState extends State<Error404Screen> with UIMixin{
  Error404Controller controller = Get.put(Error404Controller());
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
            Image.asset("assets/404-error.png"),
            MySpacing.height(24),
            MyText.titleLarge("Ooops! The Page You're Looking For Was Not Found",fontWeight: 700),
            MySpacing.height(12),
            MyText.bodyMedium("Sorry, we couldn't find the page you were looking for. We suggest that you return to main sections",textAlign: TextAlign.center),
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
