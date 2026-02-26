import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/helper/services/auth_services.dart';
import 'package:original_taste/helper/widgets/my_form_validator.dart';
import 'package:original_taste/helper/widgets/my_validators.dart';

class SignUpController extends MyController {
  bool termsAndCondition = false;

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
      'email',
      required: true,
      label: "Email",
      validators: [MyEmailValidator()],
      controller: TextEditingController(),
    );

    basicValidator.addField(
      'fullName',
      required: true,
      label: "Họ và tên",
      validators: [MyLengthValidator(min: 2, max: 100)],
      controller: TextEditingController(),
    );

    basicValidator.addField(
      'phoneNumber',
      required: true,
      label: "Số điện thoại",
      validators: [MyLengthValidator(min: 9, max: 15)],
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

  void toggleTermsAndCondition(bool? value) {
    termsAndCondition = value ?? false;
    update();
  }

  void goToSignIn() {
    // offNamed: xóa SignUpScreen khỏi stack → controller bị dispose → formKey bị hủy
    Get.offNamed('/auth/sign_in');
  }

  Future<void> onSignUp() async {
    if (!termsAndCondition) {
      Get.snackbar(
        'Lưu ý',
        'Vui lòng đồng ý với điều khoản sử dụng',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (basicValidator.validateForm()) {
      update();

      final data = basicValidator.getData();
      final error = await AuthService.register(
        username: data['username'] ?? '',
        email: data['email'] ?? '',
        fullName: data['fullName'] ?? '',
        phoneNumber: data['phoneNumber'] ?? '',
        password: data['password'] ?? '',
      );

      if (error != null) {
        Get.snackbar(
          'Đăng ký thất bại',
          error,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Thành công',
          'Tạo tài khoản thành công, vui lòng đăng nhập',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Delay nhỏ để snackbar hiển thị trước khi navigate
        await Future.delayed(const Duration(milliseconds: 300));
        // offAllNamed: xóa TOÀN BỘ stack → SignUpController bị dispose hoàn toàn
        // → formKey của SignUp bị hủy trước khi SignIn mount → không còn duplicate
        Get.offAllNamed('/auth/sign_in');
      }

      update();
    }
  }
}