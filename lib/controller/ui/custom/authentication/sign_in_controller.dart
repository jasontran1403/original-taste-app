import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/helper/services/auth_services.dart';
import 'package:original_taste/helper/widgets/my_form_validator.dart';
import 'package:original_taste/helper/widgets/my_validators.dart';

class SignInController extends MyController {
  bool rememberMe = false;

  MyFormValidator basicValidator = MyFormValidator();

  @override
  void onInit() {
    basicValidator.addField(
      'username',
      required: true,
      label: "Tên đăng nhập",
      validators: [MyLengthValidator(min: 3, max: 50)],
      controller: TextEditingController(),
    );

    basicValidator.addField(
      'password',
      required: true,
      label: "Mật khẩu",
      validators: [MyLengthValidator(min: 6, max: 50)],
      controller: TextEditingController(),
    );
    super.onInit();
  }

  @override
  void onClose() {
    basicValidator.disposeControllers();
    super.onClose();
  }

  void toggleRememberMe(bool? value) {
    rememberMe = value ?? false;
    update();
  }

  Future<void> onLogin() async {
    if (basicValidator.validateForm()) {
      update();

      final data = basicValidator.getData();
      final error = await AuthService.login(
        username: data['username'] ?? '',
        password: data['password'] ?? '',
      );

      if (error != null) {
        Get.snackbar(
          'Đăng nhập thất bại',
          error,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }

      update();
    }
  }

  void goToSignUp() {
    // offNamed thay vì toNamed: xóa SignInScreen khỏi stack
    // → khi quay lại /auth/sign_in sẽ tạo controller MỚI → formKey MỚI
    Get.offNamed('/auth/sign_up');
  }
}