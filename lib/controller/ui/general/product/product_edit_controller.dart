import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:original_taste/controller/my_controller.dart';
import 'package:remixicon/remixicon.dart';

class ProductEditController extends MyController {
  late TextEditingController productNameController,
      brandController,
      weightController,
      descriptionController,
      tagNumberController,
      stockController,
      priceController,
      discountController,
      texController;

  String? selectedCategory;
  String? selectedGender;

  final List<String> categories = [
    'Fashion',
    'Electronics',
    'Footwear',
    'Sportswear',
    'Watches',
    'Furniture',
    'Appliances',
    'Headphones',
    'Other Accessories',
  ];

  final List<String> genders = ['Male', 'Female', 'Other'];

  var sizes = <String, bool>{'S': false, 'M': false, 'XL': false, 'XXL': false};

  var selectedColors = <String, bool>{
    "dark": false,
    "yellow": false,
    "white": false,
    "red": false,
    "green": false,
    "blue": false,
    "sky": false,
    "gray": false,
  };

  final List<String> availableSizes = ['XS', 'S', 'M', 'XL', 'XXL', '3XL'];
  final List<String> selectedSizeOptions = [];

  final Map<String, int> availableColors = {
    'Dark': 0xFF000000,
    'Yellow': 0xFFFFC107,
    'White': 0xFFFFFFFF,
    'Red': 0xFFF44336,
    'Green': 0xFF4CAF50,
    'Blue': 0xFF2196F3,
    'Sky': 0xFF03A9F4,
    'Gray': 0xFF9E9E9E,
  };
  final List<String> selectedColorOptions = [];

  @override
  void onInit() {
    productNameController = TextEditingController(text: "Men Black Slim Fit T-shirt");
    brandController = TextEditingController(text: "Larkon Fashion");
    weightController = TextEditingController(text: "300gm");
    descriptionController = TextEditingController(text: "Top in sweatshirt fabric made from a cotton blend with a soft brushed inside. Relaxed fit with dropped shoulders, long sleeves and ribbing around the neckline, cuffs and hem. Small metal text applique.");
    tagNumberController = TextEditingController(text: "36294007");
    stockController = TextEditingController(text: "465");
    priceController = TextEditingController(text: "80");
    discountController = TextEditingController(text: "30");
    texController = TextEditingController(text: "3");
    super.onInit();
  }

  void toggleSizeOption(String size) {
    if (selectedSizeOptions.contains(size)) {
      selectedSizeOptions.remove(size);
    } else {
      selectedSizeOptions.add(size);
    }
    update();
  }

  void toggleColorOption(String color) {
    if (selectedColorOptions.contains(color)) {
      selectedColorOptions.remove(color);
    } else {
      selectedColorOptions.add(color);
    }
    update();
  }

  void toggleColor(String key) {
    selectedColors[key] = !selectedColors[key]!;
    update();
  }

  void toggleSize(String size) {
    sizes[size] = !(sizes[size] ?? false);
    update();
  }

  final List<PlatformFile> files = [];
  bool selectMultipleFile = false;
  FileType fileType = FileType.any;

  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: selectMultipleFile, type: fileType);

    if (result?.files.isNotEmpty ?? false) {
      files.addAll(result!.files);
      update();
    }
  }

  IconData getFileIcon(String fileName) {
    final ext = _getFileExtension(fileName);

    if (_imageExtensions.contains(ext)) return RemixIcons.image_2_line;
    if (_pdfExtensions.contains(ext)) return RemixIcons.file_pdf_line;
    if (_wordExtensions.contains(ext)) return RemixIcons.file_word_2_line;
    if (_excelExtensions.contains(ext)) return RemixIcons.file_excel_2_line;
    if (_pptExtensions.contains(ext)) return RemixIcons.file_ppt_2_line;
    if (_textExtensions.contains(ext)) return RemixIcons.file_text_line;
    if (_archiveExtensions.contains(ext)) return RemixIcons.file_zip_line;
    if (_videoExtensions.contains(ext)) return RemixIcons.film_line;
    if (_audioExtensions.contains(ext)) return RemixIcons.music_line;
    if (_codeExtensions.contains(ext)) return RemixIcons.code_line;

    return RemixIcons.file_line;
  }

  String _getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  static const List<String> _imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg'];
  static const List<String> _pdfExtensions = ['pdf'];
  static const List<String> _wordExtensions = ['doc', 'docx'];
  static const List<String> _excelExtensions = ['xls', 'xlsx'];
  static const List<String> _pptExtensions = ['ppt', 'pptx'];
  static const List<String> _textExtensions = ['txt', 'md'];
  static const List<String> _archiveExtensions = ['zip', 'rar', '7z', 'tar', 'gz'];
  static const List<String> _videoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'webm'];
  static const List<String> _audioExtensions = ['mp3', 'wav', 'flac', 'aac'];
  static const List<String> _codeExtensions = ['html', 'css', 'js', 'json', 'xml', 'dart', 'py', 'java', 'ts'];
}
