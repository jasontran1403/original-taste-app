import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/ui/custom/pages/welcome_controller.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/views/layout/layout.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>with UIMixin {
  WelcomeController controller = Get.put(WelcomeController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'welcome_controller',
      builder: (controller) {
      return Layout(screenName: "WELCOME");
    },);
  }
}
