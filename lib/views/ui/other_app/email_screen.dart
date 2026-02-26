import 'package:flutter/material.dart';
// import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/ui/other_app/email_controller.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_flex.dart';
import 'package:original_taste/helper/widgets/my_list_extension.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/images.dart';
import 'package:original_taste/models/email_model.dart';
import 'package:original_taste/views/layout/layout.dart';
import 'package:remixicon/remixicon.dart';

import '../../../helper/widgets/my_flex_item.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> with UIMixin {
  EmailController controller = Get.put(EmailController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) {
        final totalPages = (controller.filteredEmails.length / controller.itemsPerPage).ceil();
        final startIndex = (controller.currentPage - 1) * controller.itemsPerPage;
        final endIndex = startIndex + controller.itemsPerPage;
        final currentItems = controller.filteredEmails.sublist(
          startIndex,
          endIndex < controller.filteredEmails.length ? endIndex : controller.filteredEmails.length,
        );

        // Calculate lengths
        final importantEmailsLength = controller.emails.where((email) => email.important).length;
        final starredEmailsLength = controller.emails.where((email) => email.starred).length;

        return Layout(
          screenName: "INBOX",
          child: MyFlex(
            children: [
              MyFlexItem(sizes: 'lg-2.3', child: _indexView(importantEmailsLength, starredEmailsLength)),
              MyFlexItem(sizes: 'lg-9.7', child: controller.isEmailDetail ? _emailDetails() : _emailContentView(currentItems, totalPages)),
            ],
          ),
        );
      },
    );
  }

  Widget _indexView(int importantEmailsLength, int starredEmailsLength) {
    return MyCard(
      shadow: MyShadow(elevation: 0.2),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      height: MediaQuery.of(context).size.height / 1.35,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _composeButton(),
          MySpacing.height(16),
          _buildNavigationItems(importantEmailsLength, starredEmailsLength),
          MySpacing.height(20),
          _buildLabelsSection(),
          Spacer(),
          _storageInfo(),
          Spacer(),
        ],
      ),
    );
  }

  // Compose Button
  Widget _composeButton() {
    return MyContainer(
      onTap: () {},
      color: contentTheme.danger,
      paddingAll: 12,
      child: Center(child: MyText.bodyMedium("Compose", fontWeight: 600, color: contentTheme.onPrimary)),
    );
  }

  // Navigation Items
  Widget _buildNavigationItems(int importantEmailsLength, int starredEmailsLength) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildNavItem('Inbox', 0, RemixIcons.inbox_line, badge: controller.emails.length.toString(), badgeColor: contentTheme.danger),
        _buildNavItem('Starred', 1, RemixIcons.star_line, badge: starredEmailsLength.toString(), badgeColor: contentTheme.warning),
        _buildNavItem('Draft', 2, RemixIcons.file_text_line, badge: '32', badgeColor: contentTheme.info),
        _buildNavItem('Sent Mail', 3, RemixIcons.mail_send_line),
        _buildNavItem('Trash', 4, RemixIcons.delete_bin_line),
        _buildNavItem('Important', 5, RemixIcons.price_tag_line, badge: importantEmailsLength.toString(), badgeColor: contentTheme.success),
      ],
    );
  }

  // Labels Section
  Widget _buildLabelsSection() {
    return Wrap(
      runSpacing: 16,
      children: [
        MyText.bodyMedium('Labels', fontWeight: 600),
        _buildNavItem('Updates', 6, RemixIcons.circle_line),
        _buildNavItem('Social', 7, RemixIcons.circle_line),
        _buildNavItem('Promotions', 8, RemixIcons.circle_line),
        _buildNavItem('Forums', 9, RemixIcons.circle_line),
      ],
    );
  }

  // Navigation Item Builder
  Widget _buildNavItem(String label, int index, IconData icon, {String? badge, Color? badgeColor}) {
    return InkWell(
      onTap: () {
        controller.onCategorySelected(label);
      },
      child: Row(
        children: [
          Icon(icon, size: 16, color: contentTheme.secondary),
          MySpacing.width(12),
          Expanded(child: MyText.bodyMedium(label, fontWeight: 600, color: contentTheme.secondary)),
          if (badge != null) ...[
            MyContainer(
              color: badgeColor!.withValues(alpha: 0.2),
              paddingAll: 4,
              child: MyText.labelSmall(badge, color: badgeColor, fontWeight: 600),
            ),
          ],
        ],
      ),
    );
  }

  // Storage Info Section
  Widget _storageInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyContainer(
          borderRadiusAll: 100,
          color: contentTheme.secondary.withValues(alpha: 0.2),
          padding: MySpacing.all(6),
          child: MyText.labelMedium('FREE', color: contentTheme.secondary, fontWeight: 600),
        ),
        MySpacing.height(12),
        MyText.bodyMedium('Storage', fontWeight: 600, color: contentTheme.secondary),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: 0.46,
          color: contentTheme.success,
          minHeight: 5,
          borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
        ),
        SizedBox(height: 8),
        MyText.bodyMedium('7.02 GB (46%) of 15 GB used', fontWeight: 600, color: contentTheme.secondary),
      ],
    );
  }

  // Email Content View (Main content with list and pagination)
  Widget _emailContentView(List<EmailModel> currentItems, int totalPages) {
    return MyCard(
      shadow: MyShadow(elevation: 0.2),
      height: MediaQuery.of(context).size.height / 1.35,
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: MySpacing.all(16), child: listingHeader()),
          _buildCategoryTabs(),
          Expanded(
            child: ListView.separated(
              itemCount: currentItems.length,
              padding: MySpacing.nTop(16),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                EmailModel email = currentItems[index];
                double screenWidth = MediaQuery.of(context).size.width;
                return InkWell(
                  onTap: controller.toggleEmailDetail,
                  child: Row(
                    children: [
                      Theme(
                        data: ThemeData(),
                        child: Checkbox(
                          value: email.unread,
                          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                          activeColor: contentTheme.primary,
                          onChanged: (value) => controller.onReadMail(email),
                        ),
                      ),
                      MySpacing.width(screenWidth > 600 ? 20 : 10),
                      InkWell(
                        onTap: () => controller.onStarToggle(email),
                        child: Icon(
                          email.starred ? Icons.star : Icons.star_border_outlined,
                          color: email.starred ? contentTheme.warning : null,
                          size: screenWidth > 600 ? 24 : 20,
                        ),
                      ),
                      MySpacing.width(screenWidth > 600 ? 20 : 10),
                      InkWell(
                        onTap: () => controller.onImportantToggle(email),
                        child: Icon(
                          email.important ? Icons.label_important_rounded : Icons.label_important_outline,
                          color: email.important ? contentTheme.warning : null,
                          size: screenWidth > 600 ? 24 : 20,
                        ),
                      ),
                      MySpacing.width(screenWidth > 600 ? 20 : 10),
                      SizedBox(
                        width: screenWidth > 600 ? 150 : screenWidth * 0.3,
                        child: MyText.bodyMedium(email.from, fontWeight: 600, muted: true),
                      ),
                      MySpacing.width(screenWidth > 600 ? 20 : 10),
                      Expanded(
                        child: SizedBox(
                          height: 32,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              MyText.bodyMedium(email.subject, fontWeight: 600, muted: true, overflow: TextOverflow.ellipsis),
                              MySpacing.width(4),
                              MyText.bodyMedium(email.content, fontWeight: 600, muted: true, overflow: TextOverflow.ellipsis),
                              MySpacing.width(12),
                              Wrap(
                                spacing: 12,
                                children:
                                    email.attachments.mapIndexed((index, element) {
                                      return MyContainer(
                                        color: contentTheme.secondary.withValues(alpha: 0.2),
                                        paddingAll: 4,
                                        child: Row(
                                          children: [
                                            Icon(
                                              element.type == 'image'
                                                  ? RemixIcons.image_ai_line
                                                  : element.type == 'pdf'
                                                  ? RemixIcons.file_text_line
                                                  : element.type == 'zip'
                                                  ? RemixIcons.archive_line
                                                  : element.type == 'log'
                                                  ? RemixIcons.scroll_to_bottom_line
                                                  : element.type == 'doc'
                                                  ? RemixIcons.sticky_note_line
                                                  : null,
                                              color: contentTheme.secondary,
                                              size: 12,
                                            ),
                                            MySpacing.width(4),
                                            MyText.labelSmall(element.name, fontWeight: 500, color: contentTheme.secondary),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      MySpacing.width(screenWidth > 600 ? 20 : 10),
                      MyText.bodyMedium(email.date, fontWeight: 600),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return MySpacing.height(12);
              },
            ),
          ),
          Padding(padding: MySpacing.all(16), child: _pagination(totalPages)),
        ],
      ),
    );
  }

  Widget _emailDetails() {
    return MyCard(
      shadow: MyShadow(elevation: 0.2),
      height: MediaQuery.of(context).size.height / 1.35,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(onPressed: controller.toggleEmailDetail, icon: Icon(RemixIcons.arrow_left_line, size: 20)),
              Expanded(child: MyText.bodyMedium("Medium", fontWeight: 600)),
              MyContainer(
                paddingAll: 12,
                color: contentTheme.secondary.withValues(alpha: 0.1),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(RemixIcons.inbox_line, size: 18),
                    MySpacing.width(20),
                    Icon(RemixIcons.file_warning_line, size: 18),
                    MySpacing.width(20),
                    Icon(RemixIcons.delete_bin_line, size: 18),
                  ],
                ),
              ),
            ],
          ),
          MySpacing.height(16),
          MyContainer.bordered(
            height: 300,
            child: ListView(
              children: [
                MyText.titleMedium("Hi Jorge, How are you?", fontWeight: 600),
                MySpacing.height(16),
                Divider(height: 0),
                MySpacing.height(16),
                Row(
                  children: [
                    MyContainer.rounded(height: 40, width: 40, paddingAll: 0, child: Image.asset(Images.userAvatars[1], fit: BoxFit.cover)),
                    MySpacing.width(12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.bodyMedium("Jonathan Smith", fontWeight: 600),
                        MySpacing.height(3),
                        MyText.bodySmall("From: jonathan@domain.com", fontWeight: 600, muted: true),
                      ],
                    ),
                  ],
                ),
                MySpacing.height(20),
                MyText.bodyMedium("Hi Jorge...", fontWeight: 800),
                MySpacing.height(20),
                MyText.bodySmall(controller.dummyTexts[0], fontWeight: 600, muted: true),
                MySpacing.height(20),
                MyText.bodySmall(controller.dummyTexts[1], fontWeight: 600, muted: true),
                MySpacing.height(20),
                MyText.bodySmall(controller.dummyTexts[2], fontWeight: 600, muted: true),
                MySpacing.height(20),
                MyText.bodySmall(controller.dummyTexts[3], fontWeight: 600, muted: true),
                MySpacing.height(16),
                Divider(height: 0),
                MySpacing.height(16),
                MyText.bodySmall("Attachment (3)", fontWeight: 600),
                MySpacing.height(16),
                Wrap(
                  spacing: 12,
                  children: [
                    MyContainer.bordered(
                      paddingAll: 4,
                      child: MyContainer(paddingAll: 0, height: 80, child: Image.asset(Images.smallImages[0], fit: BoxFit.cover)),
                    ),
                    MyContainer.bordered(
                      paddingAll: 4,
                      child: MyContainer(paddingAll: 0, height: 80, child: Image.asset(Images.smallImages[1], fit: BoxFit.cover)),
                    ),
                    MyContainer.bordered(
                      paddingAll: 4,
                      child: MyContainer(paddingAll: 0, height: 80, child: Image.asset(Images.smallImages[2], fit: BoxFit.cover)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          MySpacing.height(12),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyContainer.rounded(paddingAll: 0, height: 40, width: 40, child: Image.asset(Images.userAvatars[6], fit: BoxFit.cover)),
                MySpacing.width(12),
                Expanded(
                  child: SingleChildScrollView(
                    child: MyContainer.bordered(
                      paddingAll: 0,
                      child: Column(
                        children: [
                          Padding(
                            padding: MySpacing.all(8),
                            // child: QuillSimpleToolbar(
                            //   controller: controller.quillController,
                            //   config: const QuillSimpleToolbarConfig(
                            //     showRedo: false,
                            //     showFontFamily: false,
                            //     showSubscript: false,
                            //     showSuperscript: false,
                            //     showUndo: false,
                            //     showUnderLineButton: false,
                            //     toolbarSize: 0,
                            //     toolbarSectionSpacing: 0,
                            //     toolbarRunSpacing: 12,
                            //   ),
                            // ),
                          ),
                          Divider(height: 0),
                          MySpacing.height(16),
                          // Padding(
                          //   padding: MySpacing.all(8),
                          //   child: SizedBox(
                          //     height: 150,
                          //     child: QuillEditor.basic(controller: controller.quillController, config: const QuillEditorConfig(autoFocus: true)),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          MySpacing.height(12),
          Align(
            alignment: Alignment.centerRight,
            child: MyContainer(
              color: contentTheme.primary,
              paddingAll: 12,
              onTap: () => controller.toggleEmailDetail(),
              child: MyText.labelMedium("Send", fontWeight: 600, color: contentTheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget listingHeader() {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        MyContainer(
          paddingAll: 12,
          color: contentTheme.secondary.withValues(alpha: 0.1),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(RemixIcons.inbox_line, size: 18),
              MySpacing.width(20),
              Icon(RemixIcons.file_warning_line, size: 18),
              MySpacing.width(20),
              Icon(RemixIcons.delete_bin_line, size: 18),
            ],
          ),
        ),
        PopupMenuButton(
          offset: Offset(0, 44),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          itemBuilder:
              (BuildContext context) => [
                PopupMenuItem(padding: MySpacing.xy(16, 8), height: 10, child: MyText.bodyMedium("Social", fontWeight: 600)),
                PopupMenuItem(padding: MySpacing.xy(16, 8), height: 10, child: MyText.bodyMedium("Promotion", fontWeight: 600)),
                PopupMenuItem(padding: MySpacing.xy(16, 8), height: 10, child: MyText.bodyMedium("Updates", fontWeight: 600)),
                PopupMenuItem(padding: MySpacing.xy(16, 8), height: 10, child: MyText.bodyMedium("Forums", fontWeight: 600)),
              ],
          child: MyContainer(
            color: contentTheme.secondary.withValues(alpha: 0.2),
            paddingAll: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(RemixIcons.folder_line, size: 18, color: contentTheme.secondary),
                MySpacing.width(4),
                Icon(RemixIcons.arrow_down_s_line, size: 18, color: contentTheme.secondary),
              ],
            ),
          ),
        ),
        PopupMenuButton(
          offset: Offset(0, 44),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          itemBuilder:
              (BuildContext context) => [
                PopupMenuItem(padding: MySpacing.xy(16, 8), height: 10, child: MyText.bodyMedium("Updates", fontWeight: 600)),
                PopupMenuItem(padding: MySpacing.xy(16, 8), height: 10, child: MyText.bodyMedium("Social", fontWeight: 600)),
                PopupMenuItem(padding: MySpacing.xy(16, 8), height: 10, child: MyText.bodyMedium("Promotion", fontWeight: 600)),
                PopupMenuItem(padding: MySpacing.xy(16, 8), height: 10, child: MyText.bodyMedium("Forums", fontWeight: 600)),
              ],
          child: MyContainer(
            color: contentTheme.secondary.withValues(alpha: 0.2),
            paddingAll: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(RemixIcons.price_tag_3_line, size: 18, color: contentTheme.secondary),
                MySpacing.width(4),
                Icon(RemixIcons.arrow_down_s_line, size: 18, color: contentTheme.secondary),
              ],
            ),
          ),
        ),
        PopupMenuButton(
          offset: Offset(0, 44),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          itemBuilder:
              (BuildContext context) => [
                PopupMenuItem(padding: MySpacing.xy(16, 8), height: 10, child: MyText.bodyMedium("Mark as unread", fontWeight: 600)),
                PopupMenuItem(padding: MySpacing.xy(16, 8), height: 10, child: MyText.bodyMedium("Add to task", fontWeight: 600)),
                PopupMenuItem(padding: MySpacing.xy(16, 8), height: 10, child: MyText.bodyMedium("Add star", fontWeight: 600)),
                PopupMenuItem(padding: MySpacing.xy(16, 8), height: 10, child: MyText.bodyMedium("Mute", fontWeight: 600)),
              ],
          child: MyContainer(
            color: contentTheme.secondary.withValues(alpha: 0.2),
            paddingAll: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MyText.bodyMedium("More", fontWeight: 600, color: contentTheme.secondary),
                MySpacing.width(4),
                Icon(RemixIcons.arrow_down_s_line, size: 18, color: contentTheme.secondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Category Tabs
  Widget _buildCategoryTabs() {
    return Padding(
      padding: MySpacing.bottom(16),
      child: Row(
        children: [
          _buildCategoryTab('Primary', RemixIcons.inbox_line),
          _buildCategoryTab('Social', RemixIcons.user_line),
          _buildCategoryTab('Promotions', RemixIcons.inbox_line),
          _buildCategoryTab('Updates', RemixIcons.info_i),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String label, IconData icons) {
    bool isActive = controller.selectedCategory == label;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyContainer(
            onTap: () => controller.onCategorySelected(label),
            padding: MySpacing.xy(16, 8),
            margin: MySpacing.right(8),
            child: Row(
              children: [
                Icon(icons, size: 16, color: isActive ? contentTheme.primary : null),
                MySpacing.width(12),
                Flexible(
                  child: MyText.bodyMedium(label, fontWeight: 600, overflow: TextOverflow.ellipsis, color: isActive ? contentTheme.primary : null),
                ),
              ],
            ),
          ),
          MySpacing.height(8),
          Divider(height: 0, color: isActive ? contentTheme.primary : null),
        ],
      ),
    );
  }

  // Pagination Controls
  Widget _pagination(int totalPages) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MyText.bodySmall("Showing 1 - 20 of 289", fontWeight: 600),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            MyContainer(
              onTap: controller.currentPage > 1 ? () => setState(() => controller.currentPage--) : null,
              paddingAll: 8,
              color: contentTheme.primary,
              child: Icon(Icons.chevron_left, color: contentTheme.onPrimary),
            ),
            MySpacing.width(4),
            MyContainer(
              onTap: controller.currentPage < totalPages ? () => setState(() => controller.currentPage++) : null,
              paddingAll: 8,
              color: contentTheme.primary,
              child: Icon(Icons.chevron_right, color: contentTheme.onPrimary),
            ),
          ],
        ),
      ],
    );
  }
}
