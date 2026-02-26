import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/ui/custom/authentication/sign_up_controller.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/images.dart';
import 'package:original_taste/views/layout/auth_layout.dart';
import 'package:original_taste/views/ui/custom/authentication/widget/custom_text_form_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with UIMixin {
  late final SignUpController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(SignUpController());
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
                MyText.titleLarge("Đăng ký", fontWeight: 700),
                MySpacing.height(8),
                MyText.bodyMedium("Tạo tài khoản mới, chỉ mất vài giây!"),
                MySpacing.height(32),

                // ── Tên đăng nhập ──
                CustomTextFormField(
                  labelText: "Tên đăng nhập",
                  controller: controller.basicValidator.getController('username'),
                  validator: controller.basicValidator.getValidation('username'),
                  hintText: "Nhập tên đăng nhập (3–50 ký tự)",
                ),
                MySpacing.height(16),

                // ── Họ và tên ──
                CustomTextFormField(
                  labelText: "Họ và tên",
                  controller: controller.basicValidator.getController('fullName'),
                  validator: controller.basicValidator.getValidation('fullName'),
                  hintText: "Nhập họ và tên đầy đủ",
                ),
                MySpacing.height(16),

                // ── Email ──
                CustomTextFormField(
                  labelText: "Email",
                  controller: controller.basicValidator.getController('email'),
                  validator: controller.basicValidator.getValidation('email'),
                  hintText: "Nhập địa chỉ email",
                  keyboardType: TextInputType.emailAddress,
                ),
                MySpacing.height(16),

                // ── Số điện thoại ──
                CustomTextFormField(
                  labelText: "Số điện thoại",
                  controller: controller.basicValidator.getController('phoneNumber'),
                  validator: controller.basicValidator.getValidation('phoneNumber'),
                  hintText: "Nhập số điện thoại",
                  keyboardType: TextInputType.phone,
                ),
                MySpacing.height(16),

                // ── Mật khẩu ──
                CustomTextFormField(
                  labelText: "Mật khẩu",
                  controller: controller.basicValidator.getController('password'),
                  validator: controller.basicValidator.getValidation('password'),
                  hintText: "Tối thiểu 6 ký tự",
                  obscureText: true,
                ),
                MySpacing.height(16),

                // ── Terms & Conditions ──
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
                        value: controller.termsAndCondition,
                        onChanged: controller.toggleTermsAndCondition,
                      ),
                    ),
                    MyText.bodyMedium("Tôi đồng ý với "),
                    InkWell(
                      onTap: () {}, // TODO: mở trang điều khoản
                      child: MyText.bodyMedium(
                        "Điều khoản sử dụng",
                        fontWeight: 700,
                        color: contentTheme.primary,
                      ),
                    ),
                  ],
                ),
                MySpacing.height(16),

                // ── Nút đăng ký ──
                MyContainer(
                  onTap: () => controller.onSignUp(),
                  color: contentTheme.primary.withValues(alpha: 0.1),
                  paddingAll: 12,
                  borderRadiusAll: 12,
                  child: Center(
                    child: MyText.bodyMedium("Đăng ký", color: contentTheme.primary),
                  ),
                ),
                MySpacing.height(24),

                // ── Link đến đăng nhập ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyText.bodyMedium("Đã có tài khoản?", color: contentTheme.primary),
                    MySpacing.width(8),
                    InkWell(
                      onTap: controller.goToSignIn,
                      child: MyText.bodyMedium("Đăng nhập", fontWeight: 700),
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