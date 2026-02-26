import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:original_taste/controller/my_controller.dart';
import 'package:remixicon/remixicon.dart';

class SellerCreateController extends MyController {
  final List<PlatformFile> files = [];
  bool selectMultipleFile = false;
  FileType fileType = FileType.image;

  final formKey = GlobalKey<FormState>();

  RangeValues currentRangeValues = const RangeValues(40, 80);

  final brandTitleController = TextEditingController();
  final brandLinkController = TextEditingController();
  final locationController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final revenueController = TextEditingController(text: "\$500");
  final itemsStockController = TextEditingController();
  final productSellsController = TextEditingController();
  final happyClientController = TextEditingController();

  String? selectedCategory;
  double yearlyRevenue = 500;

  final List<String> categories = [
    "Fashion",
    "Electronics",
    "Footwear",
    "Sportswear",
    "Watches",
    "Furniture",
    "Appliances",
    "Headphones",
    "Other Accessories",
  ];

  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: selectMultipleFile, type: fileType);

    if (result?.files.isNotEmpty ?? false) {
      files.addAll(result!.files);
      update();
    }
  }

  void removeFile(PlatformFile file) {
    files.remove(file);
    update();
  }

  IconData getFileIcon(String fileName) {
    final ext = _getFileExtension(fileName);

    if (_extensionMatches(_imageExtensions, ext)) return RemixIcons.image_2_line;
    if (_extensionMatches(_pdfExtensions, ext)) return RemixIcons.file_pdf_line;
    if (_extensionMatches(_wordExtensions, ext)) return RemixIcons.file_word_2_line;
    if (_extensionMatches(_excelExtensions, ext)) return RemixIcons.file_excel_2_line;
    if (_extensionMatches(_pptExtensions, ext)) return RemixIcons.file_ppt_2_line;
    if (_extensionMatches(_textExtensions, ext)) return RemixIcons.file_text_line;
    if (_extensionMatches(_archiveExtensions, ext)) return RemixIcons.file_zip_line;
    if (_extensionMatches(_videoExtensions, ext)) return RemixIcons.film_line;
    if (_extensionMatches(_audioExtensions, ext)) return RemixIcons.music_line;
    if (_extensionMatches(_codeExtensions, ext)) return RemixIcons.code_line;

    return RemixIcons.file_line;
  }

  String _getFileExtension(String fileName) => fileName.split('.').last.toLowerCase();

  bool _extensionMatches(List<String> extensions, String ext) => extensions.contains(ext);

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
