import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/ui/custom/authentication/sign_in_controller.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/images.dart';
import 'package:original_taste/views/layout/auth_layout.dart';
import 'package:original_taste/views/ui/custom/authentication/widget/custom_text_form_field.dart';
import 'package:remixicon/remixicon.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with UIMixin {
  SignInController controller = Get.put(SignInController());

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
                MyText.titleLarge("Sign In", fontWeight: 700),
                MySpacing.height(8),
                MyText.bodyMedium("Nhập tên đăng nhập và mật khẩu để tiếp tục."),
                MySpacing.height(32),

                // ── Username ──
                CustomTextFormField(
                  labelText: "Tên đăng nhập",
                  controller: controller.basicValidator.getController('username'),
                  validator: controller.basicValidator.getValidation('username'),
                  hintText: "Nhập tên đăng nhập",
                ),
                MySpacing.height(16),

                // ── Password ──
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyText.bodyMedium("Mật khẩu"),
                        InkWell(
                          onTap: () => Get.toNamed('/auth/reset_password'),
                          child: MyText.labelMedium("Quên mật khẩu?"),
                        ),
                      ],
                    ),
                    MySpacing.height(8),
                    CustomTextFormField(
                      controller: controller.basicValidator.getController('password'),
                      validator: controller.basicValidator.getValidation('password'),
                      hintText: "Nhập mật khẩu",
                      obscureText: true,
                    ),
                  ],
                ),
                MySpacing.height(16),

                // ── Remember me ──
                Row(
                  children: [
                    Theme(
                      data: ThemeData(
                        visualDensity: VisualDensity.compact,
                        checkboxTheme: CheckboxThemeData(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                            side: const BorderSide(width: 1.5),
                          ),
                          side: const BorderSide(width: 0.5),
                          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                            if (states.contains(WidgetState.selected)) {
                              return contentTheme.primary;
                            }
                            return Colors.transparent;
                          }),
                          checkColor: WidgetStateProperty.all(Colors.white),
                        ),
                      ),
                      child: Checkbox(
                        visualDensity: VisualDensity.compact,
                        value: controller.rememberMe,
                        onChanged: controller.toggleRememberMe,
                      ),
                    ),
                    MyText.bodyMedium("Ghi nhớ đăng nhập"),
                  ],
                ),
                MySpacing.height(16),

                // ── Nút đăng nhập ──
                MyContainer(
                  onTap: () => controller.onLogin(),
                  color: contentTheme.primary.withValues(alpha: 0.1),
                  paddingAll: 12,
                  borderRadiusAll: 12,
                  child: Center(
                    child: MyText.bodyMedium("Đăng nhập", color: contentTheme.primary),
                  ),
                ),
                MySpacing.height(24),

                // ── Link đến đăng ký ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyText.bodyMedium("Chưa có tài khoản?", color: contentTheme.primary),
                    MySpacing.width(8),
                    InkWell(
                      onTap: controller.goToSignUp,
                      child: MyText.bodyMedium("Đăng ký", fontWeight: 700),
                    ),
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