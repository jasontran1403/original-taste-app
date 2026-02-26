import 'dart:async';
import 'package:original_taste/controller/my_controller.dart';

class ProductDetailController extends MyController {
  final List<String> images = ['assets/product/p-1.png', 'assets/product/p-10.png', 'assets/product/p-13.png', 'assets/product/p-14.png'];

  String selectedImage = 'assets/product/p-1.png';
  int _currentIndex = 0;
  Timer? _autoChangeTimer;
  int isQuantity = 1;

  @override
  void onInit() {
    super.onInit();
    _startAutoImageRotation();
  }

  void _startAutoImageRotation() {
    _autoChangeTimer?.cancel();

    _autoChangeTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _currentIndex = (_currentIndex + 1) % images.length;
      selectedImage = images[_currentIndex];
      update();
    });
  }

  void onChangeImage(String image) {
    if (selectedImage == image) return;

    _autoChangeTimer?.cancel();
    selectedImage = image;
    _currentIndex = images.indexOf(image);
    update();

    _startAutoImageRotation();
  }

  Set<String> selectedColors = {'dark'};

  void toggleColor(String colorId) {
    if (selectedColors.contains(colorId)) {
      selectedColors.remove(colorId);
    } else {
      selectedColors.add(colorId);
    }
    update();
  }

  bool isSelected(String colorId) => selectedColors.contains(colorId);

  Set<String> selectedSizes = {'M'};

  void toggleSize(String size) {
    if (selectedSizes.contains(size)) {
      selectedSizes.remove(size);
    } else {
      selectedSizes.add(size);
    }
    update();
  }

  bool isSelectedSize(String size) => selectedSizes.contains(size);

  void incrementQuantity() {
    isQuantity++;
    update();
  }

  void decrementQuantity() {
    if (isQuantity > 1) {
      isQuantity--;
      update();
    }
  }

  @override
  void onClose() {
    _autoChangeTimer?.cancel();
    super.onClose();
  }
}
