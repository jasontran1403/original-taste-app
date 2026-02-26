import 'package:flutter_quill/flutter_quill.dart';
import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/helper/widgets/my_text_utils.dart';
import 'package:original_taste/models/email_model.dart';

class EmailController extends MyController {
  List<EmailModel> emails = [];
  List<EmailModel> filteredEmails = [];
  final int itemsPerPage = 20;
  int currentPage = 1;
  String selectedCategory = 'Inbox';
  bool isEmailDetail = false;
  List<String> dummyTexts = List.generate(12, (index) => MyTextUtils.getDummyText(60));
  QuillController quillController = QuillController.basic();

  @override
  void onInit() {
    super.onInit();
    _loadEmails();
  }

  Future<void> _loadEmails() async {
    final List<EmailModel> emailList = await EmailModel.dummyList;
    emails = emailList;
    filterEmails();
  }

  void filterEmails() {
    filteredEmails = _categoryFilters[selectedCategory]?.call() ?? emails;
    update();
  }

  void onCategorySelected(String category) {
    selectedCategory = category;
    filterEmails();
    update();
  }

  void onReadMail(EmailModel email) {
    _toggleEmailProperty(email, (e) => e.unread = !e.unread);
  }

  void onStarToggle(EmailModel email) {
    _toggleEmailProperty(email, (e) => e.starred = !e.starred);
  }

  void onImportantToggle(EmailModel email) {
    _toggleEmailProperty(email, (e) => e.important = !e.important);
  }

  void _toggleEmailProperty(EmailModel email, void Function(EmailModel) toggleAction) {
    toggleAction(email);
    update();
  }

  void toggleEmailDetail() {
    isEmailDetail = !isEmailDetail;
    update();
  }

  Map<String, List<EmailModel> Function()> get _categoryFilters => {
    'Inbox': () => emails,
    'Starred': () => emails.where((e) => e.starred).toList(),
    'Important': () => emails.where((e) => e.important).toList(),
    'Updates': () => emails.where((e) => e.category == 'updates').toList(),
    'Social': () => emails.where((e) => e.category == 'social').toList(),
    'Promotions': () => emails.where((e) => e.category == 'promotions').toList(),
    'Primary': () => emails,
  };
}