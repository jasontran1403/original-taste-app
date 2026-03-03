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
                        onChanged: controller.isLoading ? null : controller.toggleRememberMe,
                      ),
                    ),
                    MyText.bodyMedium("Ghi nhớ đăng nhập"),
                  ],
                ),
                MySpacing.height(16),

                // ── Nút đăng nhập với loading state ──
                _LoginButton(
                  isLoading: controller.isLoading,
                  primaryColor: contentTheme.primary,
                  onTap: controller.isLoading ? null : () => controller.onLogin(),
                ),
                MySpacing.height(24),

                // ── Link đến đăng ký ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyText.bodyMedium("Chưa có tài khoản?", color: contentTheme.primary),
                    MySpacing.width(8),
                    InkWell(
                      onTap: controller.isLoading ? null : controller.goToSignUp,
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

// ─────────────────────────────────────────────────────────────
// Login button với loading animation
// ─────────────────────────────────────────────────────────────
class _LoginButton extends StatefulWidget {
  final bool isLoading;
  final Color primaryColor;
  final VoidCallback? onTap;

  const _LoginButton({
    required this.isLoading,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  State<_LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<_LoginButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinCtrl;

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didUpdateWidget(_LoginButton old) {
    super.didUpdateWidget(old);
    if (widget.isLoading && !_spinCtrl.isAnimating) {
      _spinCtrl.repeat();
    } else if (!widget.isLoading && _spinCtrl.isAnimating) {
      _spinCtrl.stop();
      _spinCtrl.reset();
    }
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool disabled = widget.isLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: disabled
            ? widget.primaryColor.withOpacity(0.05)
            : widget.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.primaryColor.withOpacity(disabled ? 0.2 : 0.4),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: disabled
                    ? _buildLoadingContent()
                    : _buildIdleContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIdleContent() {
    return Text(
      'Đăng nhập',
      key: const ValueKey('idle'),
      style: TextStyle(
        color: widget.primaryColor,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Row(
      key: const ValueKey('loading'),
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _spinCtrl,
          builder: (_, child) => Transform.rotate(
            angle: _spinCtrl.value * 2 * 3.14159,
            child: child,
          ),
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: widget.primaryColor.withOpacity(0.6),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Đang đăng nhập...',
          style: TextStyle(
            color: widget.primaryColor.withOpacity(0.6),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}