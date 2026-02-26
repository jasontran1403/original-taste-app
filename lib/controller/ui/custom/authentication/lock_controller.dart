import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/helper/widgets/my_form_validator.dart';
import 'package:original_taste/helper/widgets/my_validators.dart';

class LockController extends MyController {
  void gotoLogin() {
    Get.toNamed('/auth/login');
  }

  MyFormValidator basicValidator = MyFormValidator();

  @override
  void onInit() {
    basicValidator.addField(
      'password',
      required: true,
      label: "Password",
      validators: [MyLengthValidator(min: 6, max: 10)],
      controller: TextEditingController(text: '1234567'),
    );
    super.onInit();
  }

  Future<void> onLogin() async {
    if (basicValidator.validateForm()) {
      update();
      await Future.delayed(Duration(seconds: 1));
      Get.toNamed('/dashboard');
      update();
    }
  }
}
