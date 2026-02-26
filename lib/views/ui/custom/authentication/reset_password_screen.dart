import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/ui/custom/authentication/reset_password_controller.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/images.dart';
import 'package:original_taste/views/layout/auth_layout.dart';
import 'package:original_taste/views/ui/custom/authentication/widget/custom_text_form_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> with UIMixin {
  late ResetPasswordController controller;

  @override
  void initState() {
    controller = Get.put(ResetPasswordController());
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
                MyText.titleLarge("Reset Password", fontWeight: 700),
                MySpacing.height(8),
                MyText.bodyMedium("Enter your email address and we'll send you an email with instructions to reset your password."),
                MySpacing.height(32),
                CustomTextFormField(
                  labelText: "Email",
                  controller: controller.basicValidator.getController('email'),
                  validator: controller.basicValidator.getValidation('email'),
                  hintText: "Enter your email",
                ),

                MySpacing.height(16),
                MyContainer(
                  onTap: () => controller.onResetPassword(),
                  color: contentTheme.primary,
                  paddingAll: 12,
                  borderRadiusAll: 12,
                  child: Center(child: MyText.bodyMedium("Reset Password", color: contentTheme.onPrimary)),
                ),
                MySpacing.height(28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyText.bodyMedium("Back to", color: contentTheme.primary),
                    MySpacing.width(12),
                    InkWell(
                        onTap: controller.gotoLogIn,
                        child: MyText.bodyMedium("Sign In", fontWeight: 700)),
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
