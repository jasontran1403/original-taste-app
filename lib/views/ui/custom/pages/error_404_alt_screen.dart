import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/ui/custom/pages/error_404_alt_controller.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/views/layout/layout.dart';

class Error404AltScreen extends StatefulWidget {
  const Error404AltScreen({super.key});

  @override
  State<Error404AltScreen> createState() => _Error404AltScreenState();
}

class _Error404AltScreenState extends State<Error404AltScreen> with UIMixin{
  Error404AltController controller = Get.put(Error404AltController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) {
      return Layout(screenName: "PAGE 404 (ALT)",child: MyContainer(
        child: Column(
          children: [
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
      ),);
    },);
  }
}
