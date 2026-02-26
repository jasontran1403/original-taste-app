import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/helper/widgets/my_form_validator.dart';
import 'package:original_taste/helper/widgets/my_validators.dart';

class ResetPasswordController extends MyController {
  MyFormValidator basicValidator = MyFormValidator();

  @override
  void onInit() {
    super.onInit();
    basicValidator.addField(
      'email',
      required: true,
      label: "Email",
      validators: [MyEmailValidator()],
      controller: TextEditingController(),
    );
  }

  // TODO: Triển khai khi server có API reset password
  Future<void> onResetPassword() async {
    if (basicValidator.validateForm()) {
      Get.snackbar(
        'Thông báo',
        'Tính năng đặt lại mật khẩu chưa được triển khai',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  void gotoLogIn() {
    Get.offNamed('/auth/sign_in');
  }
}