import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/ui/custom/authentication/lock_controller.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/images.dart';
import 'package:original_taste/views/layout/auth_layout.dart';
import 'package:original_taste/views/ui/custom/authentication/widget/custom_text_form_field.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with UIMixin{
  late LockController controller;

  @override
  void initState() {
    controller = Get.put(LockController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) {
      return AuthLayout(
        child: Form(
          key: controller.basicValidator.formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(Images.darkLogo, height: 24),
              MySpacing.height(24),
              MyText.titleLarge("Hi ! Gaston", fontWeight: 700),
              MySpacing.height(8),
              MyText.bodyMedium("Enter your email address and we'll send you an email with instructions to reset your password."),
              MySpacing.height(32),
              CustomTextFormField(
                labelText: "Password",
                controller: controller.basicValidator.getController('password'),
                validator: controller.basicValidator.getValidation('password'),
                hintText: "Enter your password",
              ),

              MySpacing.height(16),
              MyContainer(
                onTap: () => controller.onLogin(),
                color: contentTheme.primary,
                paddingAll: 12,
                borderRadiusAll: 12,
                child: Center(child: MyText.bodyMedium("Sign In", color: contentTheme.onPrimary)),
              ),
              MySpacing.height(28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyText.bodyMedium("Back to", color: contentTheme.primary),
                  MySpacing.width(12),
                  InkWell(
                      onTap: controller.gotoLogin,
                      child: MyText.bodyMedium("Sign Up", fontWeight: 700)),
                ],
              ),
            ],
          ),
        ),
      );
      },
    );
  }
}
