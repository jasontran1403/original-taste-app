import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/ui/custom/pages/coming_soon_controller.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/images.dart';
import 'package:original_taste/views/layout/auth_layout.dart';

class ComingSoonScreen extends StatefulWidget {
  const ComingSoonScreen({super.key});

  @override
  State<ComingSoonScreen> createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen> with UIMixin {
  ComingSoonController controller = ComingSoonController();
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) {
        final days = controller.remaining.inDays;
        final hours = controller.remaining.inHours.remainder(24);
        final minutes = controller.remaining.inMinutes.remainder(60);
        final seconds = controller.remaining.inSeconds.remainder(60);

        return AuthLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(Images.darkLogo, height: 24),
              MySpacing.height(24),
              Image.asset("assets/coming-soon.png"),
              MySpacing.height(24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTimeCard('Days', days),
                  _buildTimeCard('Hours', hours),
                  _buildTimeCard('Minutes', minutes),
                  _buildTimeCard('Seconds', seconds),
                ],
              ),
              MySpacing.height(24),
              MyText.labelMedium(
                "Exciting news is on the horizon! We're thrilled to announce that something incredible is coming your way very soon. Our team has been hard at work behind the scenes, crafting something special just for you.",
                textAlign: TextAlign.center,
              ),
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
      },
    );
  }

  Widget _buildTimeCard(String label, int value) {
    return Expanded(
      child: Column(
        children: [
          Text(controller.twoDigits(value), style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(label.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
