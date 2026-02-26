import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/ui/other_app/chat_controller.dart';
import 'package:original_taste/helper/theme/app_theme.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/utils/utils.dart';
import 'package:original_taste/helper/widgets/my_button.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_flex.dart';
import 'package:original_taste/helper/widgets/my_flex_item.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';

import 'package:original_taste/helper/widgets/my_text_style.dart';
import 'package:original_taste/helper/widgets/responsive.dart';
import 'package:original_taste/images.dart';
import 'package:original_taste/models/chat_model.dart';
import 'package:original_taste/views/layout/layout.dart';
import 'package:remixicon/remixicon.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with UIMixin {
  ChatController controller = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      drawer: Drawer(child: drawerSetting()),
      endDrawer: Drawer(child: endDrawer()),
      body: Layout(
        screenName: "CHAT",
        child: GetBuilder(
          init: controller,
          tag: 'chat_controller',
          builder: (controller) {
            return Padding(
              padding: MySpacing.x(flexSpacing / 1.6),
              child: MyFlex(spacing: 3, children: [MyFlexItem(sizes: 'lg-3', child: userIndex()), MyFlexItem(sizes: 'lg-8.98', child: messages())]),
            );
          },
        ),
      ),
    );
  }

  Widget userIndex() {
    return MyCard(
      shadow: MyShadow(elevation: 0.2),
      paddingAll: 0,
      height: 800,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText.titleMedium("Chat", fontWeight: 600),
                    InkWell(onTap: () => controller.scaffoldKey.currentState?.openDrawer(), child: Icon(RemixIcons.settings_line, size: 16)),
                  ],
                ),
                MySpacing.height(16),
                TextFormField(
                  style: MyTextStyle.bodyMedium(),
                  onChanged: controller.onSearchChat,
                  controller: controller.searchController,
                  decoration: InputDecoration(
                    hintText: "Search...",
                    hintStyle: MyTextStyle.bodyMedium(),
                    border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    isCollapsed: true,
                    isDense: true,
                    suffixIcon: Icon(RemixIcons.search_line, size: 14),
                    contentPadding: MySpacing.all(16),
                  ),
                ),
                MySpacing.height(20),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: Images.userAvatars.length,
                    itemBuilder: (context, index) {
                      final img = Images.userAvatars[index];
                      return InkWell(
                        onTap: () {},
                        child: Stack(
                          children: [
                            MyContainer.rounded(paddingAll: 0, child: Image.asset(img)),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: MyContainer.rounded(paddingAll: 2, child: MyContainer.rounded(paddingAll: 4, color: contentTheme.success)),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return MySpacing.width(10);
                    },
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          inboxTab(),
          if (controller.currentIndex == 0) chatUserList(),
          if (controller.currentIndex == 1) groupView(),
          if (controller.currentIndex == 2) userContacts(),
        ],
      ),
    );
  }

  Widget chatUserList() {
    return Expanded(
      child:
          controller.searchChat.isEmpty
              ? Center(child: MyText.bodyMedium("Not User Found", fontWeight: 600))
              : ListView.separated(
                shrinkWrap: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                itemCount: controller.searchChat.length,
                padding: MySpacing.top(16),
                itemBuilder: (context, index) {
                  ChatModel chat = controller.chat[index];
                  String name = chat.firstName;

                  List<TextSpan> textSpans = _highlightText(name, controller.searchController.text);

                  return MyButton(
                    onPressed: () => controller.onChangeChat(chat),
                    elevation: 0,
                    borderRadiusAll: 8,
                    padding: MySpacing.all(12),
                    backgroundColor: theme.colorScheme.surface.withAlpha(5),
                    splashColor: theme.colorScheme.onSurface.withAlpha(10),
                    child: Row(
                      children: [
                        MyContainer.rounded(paddingAll: 0, height: 44, width: 44, child: Image.asset(chat.image)),
                        MySpacing.width(12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: RichText(text: TextSpan(style: MyTextStyle.bodyMedium(), children: textSpans))),
                                  MyText.bodySmall(
                                    Utils.getTimeStringFromDateTime(chat.timestamp, showSecond: false),
                                    fontWeight: 600,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    muted: true,
                                  ),
                                ],
                              ),
                              MySpacing.height(6),
                              MyText.bodySmall(chat.messages.lastOrNull!.message, overflow: TextOverflow.ellipsis, muted: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) => SizedBox(height: 20),
              ),
    );
  }

  List<TextSpan> _highlightText(String text, String searchQuery) {
    if (searchQuery.isEmpty) return [TextSpan(text: text)];

    final regex = RegExp(RegExp.escape(searchQuery), caseSensitive: false);
    final matches = regex.allMatches(text);

    if (matches.isEmpty) return [TextSpan(text: text)];

    final List<TextSpan> spans = [];
    int currentIndex = 0;

    for (final match in matches) {
      if (match.start > currentIndex) spans.add(TextSpan(text: text.substring(currentIndex, match.start)));
      spans.add(TextSpan(text: match.group(0), style: TextStyle(fontWeight: FontWeight.bold, color: contentTheme.primary)));
      currentIndex = match.end;
    }
    if (currentIndex < text.length) spans.add(TextSpan(text: text.substring(currentIndex)));
    return spans;
  }

  Widget groupView() {
    return Expanded(
      child: ListView(
        children: [
          Padding(
            padding: MySpacing.xy(12, 8),
            child: Row(
              children: [
                MyContainer(
                  height: 48,
                  width: 48,
                  color: contentTheme.primary.withValues(alpha: 0.2),
                  paddingAll: 0,
                  child: Center(child: Icon(RemixIcons.user_line, size: 20, color: contentTheme.primary)),
                ),
                MySpacing.width(16),
                MyText.bodyMedium("New Group", fontWeight: 600),
              ],
            ),
          ),
          ListView.separated(
            itemCount: controller.group.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: MySpacing.xy(12, 8),
            itemBuilder: (context, index) {
              Groups currentGroup = controller.group[index];

              return Row(
                children: [
                  MyContainer(
                    height: 48,
                    width: 48,
                    color: contentTheme.primary.withValues(alpha: 0.2),
                    paddingAll: 0,
                    child: Center(
                      child: MyText.titleMedium(
                        currentGroup.name.isNotEmpty ? currentGroup.name[0] : "G",
                        fontWeight: 700,
                        color: contentTheme.primary,
                      ),
                    ),
                  ),
                  MySpacing.width(16),
                  MyText.bodyMedium("#${currentGroup.name}", fontWeight: 600),
                  Spacer(),
                  if (currentGroup.badge > 0)
                    MyContainer.bordered(
                      borderColor: contentTheme.danger,
                      paddingAll: 4,
                      child: MyText.bodySmall("+${currentGroup.badge} ", fontWeight: 700, color: contentTheme.danger),
                    ),
                ],
              );
            },
            separatorBuilder: (context, index) {
              return MySpacing.height(16);
            },
          ),
        ],
      ),
    );
  }

  Widget userContacts() {
    Widget buildUserRow(String avatarPath, String name, String status) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(backgroundImage: AssetImage(avatarPath), radius: 18),
        title: Text(name, style: TextStyle(fontSize: 14)),
        subtitle: status.isNotEmpty ? Text(status, style: TextStyle(color: Colors.grey, fontSize: 12)) : null,
        onTap: () {},
      );
    }

    return Expanded(
      child: ListView(
        padding: MySpacing.all(20),
        children: [
          InkWell(
            onTap: () {},
            child: Row(
              children: [
                MyContainer.rounded(
                  height: 48,
                  width: 48,
                  color: contentTheme.primary,
                  paddingAll: 0,
                  child: Icon(RemixIcons.group_line, size: 16, color: contentTheme.onPrimary),
                ),
                MySpacing.width(12),
                MyText.bodyMedium("New Group", fontWeight: 600),
              ],
            ),
          ),
          MySpacing.height(12),
          InkWell(
            onTap: () {},
            child: Row(
              children: [
                MyContainer.rounded(
                  height: 48,
                  width: 48,
                  color: contentTheme.primary,
                  paddingAll: 0,
                  child: Icon(RemixIcons.user_add_line, size: 16, color: contentTheme.onPrimary),
                ),
                MySpacing.width(12),
                MyText.bodyMedium("New Contact", fontWeight: 600),
              ],
            ),
          ),
          MySpacing.height(12),
          buildUserRow(Images.userAvatars[0], 'Gaston Lapierre', ''),
          buildUserRow(Images.userAvatars[1], 'Fantina LeBatelier', '** no status **'),
          buildUserRow(Images.userAvatars[2], 'Gilbert Chicoine', '|| Karma ||'),
          buildUserRow(Images.userAvatars[3], 'Mignonette Brodeur', 'Hey there! I am using Chat.'),
          buildUserRow(Images.userAvatars[4], 'Thomas Menard', 'TM'),
          buildUserRow(Images.userAvatars[5], 'Melisande Lapointe', 'Available'),
          buildUserRow(Images.userAvatars[6], 'Danielle Despins', 'Hey there! I am using Chat.'),
        ],
      ),
    );
  }

  Widget inboxTab() {
    Widget customIndex(int id, String title) {
      bool index = controller.currentIndex == id;
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MyContainer(
              onTap: () => controller.onChangeIndex(id),
              padding: MySpacing.xy(12, 8),
              child: MyText.bodyMedium(title, fontWeight: 600, color: index ? contentTheme.secondary : null),
            ),
            MySpacing.height(8),
            Divider(color: index ? contentTheme.secondary : null, height: 0),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [customIndex(0, "Chat"), customIndex(1, "Group"), customIndex(2, "Contact")],
    );
  }

  Widget messages() {
    return MyCard(
      shadow: MyShadow(elevation: 0.2),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      paddingAll: 0,
      height: 800,
      child: Column(
        children: [
          userDetail(),
          Divider(height: 0),
          Expanded(
            child: ListView.separated(
              padding: MySpacing.xy(16, 12),
              shrinkWrap: true,
              controller: controller.scrollController,
              itemCount: (controller.selectedChat?.messages ?? []).length,
              itemBuilder: (context, index) {
                final message = (controller.selectedChat?.messages ?? [])[index];
                final isSent = message.fromMe == true;
                final theme = isSent ? contentTheme.primary : contentTheme.secondary.withAlpha(32);
                return Row(
                  mainAxisAlignment: isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Wrap(
                        alignment: isSent ? WrapAlignment.end : WrapAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              MyContainer(
                                padding: EdgeInsets.all(8),
                                margin: EdgeInsets.only(
                                  left: isSent ? MediaQuery.of(context).size.width * 0.20 : 0,
                                  right: isSent ? 0 : MediaQuery.of(context).size.width * 0.20,
                                ),
                                color: theme,
                                child: Column(
                                  crossAxisAlignment: isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    MyText.bodyMedium(
                                      message.message,
                                      fontWeight: 600,
                                      color: isSent ? contentTheme.onPrimary : contentTheme.secondary,
                                      overflow: TextOverflow.clip,
                                    ),
                                  ],
                                ),
                              ),
                              MySpacing.height(4),
                              MyText.labelSmall(
                                Utils.getTimeStringFromDateTime(message.sendAt, showSecond: false),
                                fontSize: 9,
                                muted: true,
                                fontWeight: 600,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              separatorBuilder: (context, index) {
                return MySpacing.height(12);
              },
            ),
          ),
          MyContainer.none(paddingAll: 9, color: contentTheme.dark.withAlpha(16), child: sendMessage()),
        ],
      ),
    );
  }

  Widget userDetail() {
    return Padding(
      padding: MySpacing.all(20),
      child: InkWell(
        onTap: () {
          controller.scaffoldKey.currentState!.openEndDrawer();
        },
        child: Row(
          children: [
            if (controller.selectedChat != null)
              MyContainer(
                height: 36,
                width: 36,
                paddingAll: 0,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Image.asset(controller.selectedChat!.image, fit: BoxFit.cover),
              ),
            MySpacing.width(12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.selectedChat != null) MyText.bodyMedium(controller.selectedChat!.firstName, fontWeight: 600),
                if (!controller.isTyping)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MyContainer.rounded(paddingAll: 4, color: Colors.green),
                      MySpacing.width(4),
                      MyText.bodySmall("Active Now", fontWeight: 600, muted: true),
                    ],
                  ),
                if (controller.isTyping) MyText.bodySmall("Typing...", fontWeight: 600),
              ],
            ),
            Spacer(),
            InkWell(onTap: () {}, child: Icon(RemixIcons.phone_line, size: 20)),
            MySpacing.width(12),
            InkWell(onTap: () {}, child: Icon(RemixIcons.vidicon_line, size: 20)),
            MySpacing.width(12),
            InkWell(onTap: () {}, child: Icon(RemixIcons.group_line, size: 20)),
            MySpacing.width(12),
            InkWell(onTap: () {}, child: Icon(RemixIcons.delete_bin_5_line, size: 20)),
          ],
        ),
      ),
    );
  }

  Widget sendMessage() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MyContainer.none(
          paddingAll: 10,
          color: contentTheme.secondary.withValues(alpha: 0.1),
          child: Icon(RemixIcons.user_smile_line, size: 16, color: contentTheme.secondary),
        ),
        Expanded(
          child: MyContainer.none(
            paddingAll: 0,
            child: TextFormField(
              maxLines: 1,
              minLines: 1,
              textInputAction: TextInputAction.go,
              controller: controller.messageController,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              onChanged: (value) {
                controller.onTyping();
              },
              style: MyTextStyle.bodyMedium(fontWeight: 600, color: contentTheme.secondary),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: MySpacing.xy(12, 14),
                hintText: "Enter your message",
                hintStyle: MyTextStyle.bodyMedium(fontWeight: 600, color: contentTheme.secondary),
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
        MySpacing.width(12),
        MyContainer.none(
          paddingAll: 8,
          color: contentTheme.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.horizontal(left: Radius.circular(4)),
          child: Icon(RemixIcons.attachment_line, size: 16, color: contentTheme.secondary),
        ),
        MyContainer.none(
          paddingAll: 8,
          color: contentTheme.secondary.withValues(alpha: 0.1),
          child: Icon(RemixIcons.video_on_line, size: 16, color: contentTheme.secondary),
        ),
        MyContainer.none(
          paddingAll: 8,
          onTap: () => controller.sendMessage(),
          color: contentTheme.primary,
          borderRadius: BorderRadius.horizontal(right: Radius.circular(4)),
          child: Icon(RemixIcons.send_plane_line, size: 16, color: contentTheme.onPrimary),
        ),
      ],
    );
  }

  Widget endDrawer() {
    Widget userDetail(IconData? icon, String title, String detail) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 16), MySpacing.width(8), MyText.bodyMedium(title, fontWeight: 700)]),
          MySpacing.height(8),
          MyText.bodyMedium(detail, fontWeight: 600, muted: true),
        ],
      );
    }

    return MyCard(
      shadow: MyShadow(elevation: 0.2),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText.titleMedium("Profile", fontWeight: 600),
              IconButton(
                onPressed: () {
                  controller.scaffoldKey.currentState!.closeEndDrawer();
                },
                icon: Icon(RemixIcons.close_line),
              ),
            ],
          ),
          MySpacing.height(20),
          MyContainer.roundBordered(
            paddingAll: 4,
            height: 100,
            width: 100,
            child: MyContainer.rounded(
              paddingAll: 0,
              child: Image.asset(controller.selectedChat != null ? controller.selectedChat!.image : Images.userAvatars[0], fit: BoxFit.cover),
            ),
          ),
          MySpacing.height(12),
          MyText.titleMedium(controller.selectedChat != null ? controller.selectedChat!.firstName : "Aston Lapierre", fontWeight: 600),
          MySpacing.height(12),
          MyContainer(
            color: contentTheme.primary,
            paddingAll: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(RemixIcons.mail_line, color: contentTheme.onPrimary, size: 16),
                MySpacing.width(8),
                MyText.labelMedium("Send Email", fontWeight: 600, color: contentTheme.onPrimary),
              ],
            ),
          ),
          MySpacing.height(12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyText.bodyMedium("Last Interacted:", fontWeight: 600),
              MySpacing.width(4),
              MyText.bodyMedium("Online", fontWeight: 600, color: contentTheme.success),
            ],
          ),
          Divider(height: 62),
          userDetail(RemixIcons.phone_line, "Phone NUmber:", "+12 1234567890"),
          MySpacing.height(28),
          userDetail(RemixIcons.map_pin_line, "Location:", "California, USA"),
          MySpacing.height(28),
          userDetail(RemixIcons.global_line, "Language:", "English, German, Spanish"),
          MySpacing.height(28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [Icon(RemixIcons.user_line, size: 16), MySpacing.width(8), MyText.bodyMedium("Groups :", fontWeight: 700)]),
              MySpacing.height(12),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  MyContainer(
                    color: contentTheme.success.withValues(alpha: 0.2),
                    paddingAll: 4,
                    child: MyText.bodyMedium("Work", fontWeight: 600, color: contentTheme.success),
                  ),
                  MyContainer(
                    color: contentTheme.primary.withValues(alpha: 0.2),
                    paddingAll: 4,
                    child: MyText.bodyMedium("Friends", fontWeight: 600, color: contentTheme.primary),
                  ),
                ],
              ),
            ],
          ),
          MySpacing.height(28),
          Row(
            children: [
              Expanded(child: MyText.titleMedium("Shared Photos", fontWeight: 600)),
              InkWell(onTap: () {}, child: MyText.bodyMedium("See All", fontWeight: 600)),
            ],
          ),
          MySpacing.height(12),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              MyContainer(
                height: 50,
                width: 80,
                paddingAll: 0,
                borderRadiusAll: 8,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Image.asset(Images.smallImages[0], fit: BoxFit.cover),
              ),
              MyContainer(
                height: 50,
                width: 80,
                paddingAll: 0,
                borderRadiusAll: 8,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Image.asset(Images.smallImages[1], fit: BoxFit.cover),
              ),
              MyContainer(
                height: 50,
                width: 80,
                paddingAll: 0,
                borderRadiusAll: 8,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Stack(
                  children: [
                    Image.asset(Images.smallImages[2], fit: BoxFit.cover),
                    MyContainer(
                      color: contentTheme.dark.withValues(alpha: 0.3),
                      child: Center(child: MyText.bodyMedium("+3", fontWeight: 600, color: contentTheme.onDark)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget drawerSetting() {
    return Scaffold(
      appBar: AppBar(
        title: MyText.bodyMedium("Profile", fontWeight: 600),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              controller.scaffoldKey.currentState!.closeDrawer();
            },
            visualDensity: VisualDensity.compact,
            icon: Icon(RemixIcons.close_line, size: 16),
          ),
        ],
      ),
      body: MyContainer(
        paddingAll: 0,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [userProfile(), Divider(), settingsAccordion()]),
      ),
    );
  }

  Widget userProfile() {
    return Padding(
      padding: MySpacing.nTop(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.titleMedium("Setting", fontWeight: 600),
          MySpacing.height(12),
          Row(
            children: [
              MyContainer.rounded(paddingAll: 0, height: 40, width: 40, child: Image.asset(Images.userAvatars[0], fit: BoxFit.cover)),
              MySpacing.width(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.titleMedium('Gaston Lapierre', fontWeight: 600),
                    SizedBox(height: 4),
                    MyText.bodySmall('Hey there! I am using Rasket Chat.', fontWeight: 600, xMuted: true),
                  ],
                ),
              ),
              IconButton(icon: Icon(Icons.qr_code_scanner), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget settingsAccordion() {
    return Expanded(
      child: Padding(
        padding: MySpacing.x(14),
        child: ListView(
          children: [
            _buildAccordionItem(
              titleIcons: RemixIcons.key_line,
              title: 'Account',
              subtitle: 'Privacy, security, change number',
              children: [
                _buildListTile(title: 'Privacy', icon: RemixIcons.lock_line),
                MySpacing.height(12),
                _buildListTile(title: 'Security'),
                MySpacing.height(12),
                _buildListTile(title: 'Two-step verification', icon: RemixIcons.verified_badge_line),
                MySpacing.height(12),
                _buildListTile(title: 'Change number', icon: RemixIcons.contract_right_line),
                MySpacing.height(12),
                _buildListTile(title: 'Request account info', icon: RemixIcons.information_line),
                MySpacing.height(12),
                _buildListTile(title: 'Delete my account', icon: RemixIcons.delete_bin_line),
                MySpacing.height(12),
              ],
            ),
            _buildAccordionItem(
              titleIcons: RemixIcons.chat_quote_line,
              title: 'Chats',
              subtitle: 'Theme, wallpapers, chat history',
              children: [
                Padding(
                  padding: MySpacing.x(flexSpacing),
                  child: Align(alignment: Alignment.centerLeft, child: MyText.titleMedium("Display", fontWeight: 600)),
                ),
                MySpacing.height(8),
                _buildListTile(title: 'Theme', subtitle: 'System default', icon: RemixIcons.palette_line),
                MySpacing.height(12),
                _buildListTile(title: 'Wallpaper', icon: RemixIcons.image_line),
                MySpacing.height(12),
                Divider(height: 0),
                MySpacing.height(12),
                _buildSwitchListTile('Media Visibility', 'Show newly downloaded media in your phone\'s gallery', true, (value) {}),
                _buildSwitchListTile('Enter is send', 'Enter key will send your message', false, (value) {}),
                _buildListTile(title: 'Font size', subtitle: 'Small'),
                MySpacing.height(12),
                Divider(height: 0),
                MySpacing.height(12),
                _buildListTile(title: 'App Language', subtitle: 'English', icon: RemixIcons.text_snippet),
                MySpacing.height(12),
                _buildListTile(title: 'Chat Backup', icon: RemixIcons.file_cloud_line),
                MySpacing.height(12),
                _buildListTile(title: 'Chat History', icon: RemixIcons.history_line),
                MySpacing.height(12),
              ],
            ),
            _buildAccordionItem(
              titleIcons: RemixIcons.notification_line,
              title: 'Notification',
              subtitle: 'Message, group, call tones',
              children: [
                _buildSwitchListTile('Conversation Tones', 'Play sound for incoming and outgoing message.', true, (value) {}),
                MySpacing.height(12),
                Divider(height: 0),
                MySpacing.height(12),
                Padding(
                  padding: MySpacing.x(flexSpacing),
                  child: Align(alignment: Alignment.centerLeft, child: MyText.titleMedium("Messages", fontWeight: 600)),
                ),
                MySpacing.height(12),
                _buildListTile(title: 'Notification Tone', subtitle: 'Default ringtone'),
                MySpacing.height(12),
                _buildListTile(title: 'Vibrate', subtitle: 'Default'),
                MySpacing.height(12),
                _buildListTile(title: 'Light', subtitle: 'White'),
                MySpacing.height(12),
                Divider(height: 0),
                MySpacing.height(12),
                Padding(
                  padding: MySpacing.x(flexSpacing),
                  child: Align(alignment: Alignment.centerLeft, child: MyText.titleMedium("Groups", fontWeight: 600)),
                ),
                MySpacing.height(12),
                _buildListTile(title: 'Group Notification Tone', subtitle: 'Default ringtone'),
                MySpacing.height(12),
                _buildListTile(title: 'Group Vibrate', subtitle: 'Off'),
                MySpacing.height(12),
                _buildListTile(title: 'Group Light', subtitle: 'Dark'),
                MySpacing.height(12),
                Divider(height: 0),
                MySpacing.height(12),
                Padding(
                  padding: MySpacing.x(flexSpacing),
                  child: Align(alignment: Alignment.centerLeft, child: MyText.titleMedium("Calls", fontWeight: 600)),
                ),
                MySpacing.height(12),
                _buildListTile(title: 'Call Ringtone', subtitle: 'Default ringtone'),
                MySpacing.height(12),
                _buildListTile(title: 'Call Vibrate', subtitle: 'Default'),
                MySpacing.height(12),
              ],
            ),
            _buildAccordionItem(
              titleIcons: RemixIcons.history_line,
              title: 'Storage and data',
              subtitle: 'Network usage, auto download',
              children: [
                _buildListTile(title: 'Manage storage', subtitle: '2.4 GB', icon: Icons.folder),
                MySpacing.height(12),
                Divider(height: 0),
                MySpacing.height(12),
                _buildListTile(title: 'Network usage', subtitle: '7.2 GB sent - 13.8 GB received', icon: Icons.wifi),
                MySpacing.height(12),
                Divider(height: 0),
                MySpacing.height(12),
                _buildListTile(
                  title: 'Media auto-download',
                  subtitle: 'Voice message are always automatically downloaded',
                  icon: Icons.cloud_download,
                ),
                MySpacing.height(12),
                Divider(height: 0),
                MySpacing.height(12),
                _buildListTile(title: 'When using mobile data', subtitle: 'No media', icon: Icons.wifi),
                MySpacing.height(12),
                _buildListTile(title: 'When connected on wi-fi', subtitle: 'No media', icon: Icons.wifi),
                MySpacing.height(12),
                _buildListTile(title: 'When roaming', subtitle: 'No media', icon: Icons.wifi),
                MySpacing.height(12),
                Divider(height: 0),
                MySpacing.height(12),
                _buildListTile(title: 'Photo upload quality', subtitle: 'Auto (recommended)', icon: Icons.image),
                MySpacing.height(12),
              ],
            ),
            _buildAccordionItem(
              titleIcons: RemixIcons.information_line,
              title: 'Help',
              subtitle: 'Help center, contact us, privacy policy',
              children: [
                _buildListTile(title: 'Help center', icon: Icons.info_outline),
                MySpacing.height(12),
                _buildListTile(title: 'Contact us', subtitle: 'Questions?', icon: Icons.contact_phone),
                MySpacing.height(12),
                _buildListTile(title: 'Teams and Privacy Policy', icon: Icons.book),
                MySpacing.height(12),
                _buildListTile(title: 'App info', icon: Icons.info),
                MySpacing.height(12),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccordionItem({IconData? titleIcons, String? title, String? subtitle, List<Widget>? children}) {
    return ExpansionTile(
      visualDensity: VisualDensity.compact,
      tilePadding: MySpacing.all(flexSpacing / 2.5),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(titleIcons, size: 20),
          if (titleIcons != null) MySpacing.width(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) MyText.titleMedium(title, fontWeight: 600),
                MySpacing.height(4),
                if (subtitle != null) MyText.bodySmall(subtitle, muted: true),
              ],
            ),
          ),
        ],
      ),
      children: children!,
    );
  }

  Widget _buildListTile({String? title, String? subtitle, IconData? icon}) {
    return Padding(
      padding: MySpacing.x(flexSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) Icon(icon, size: 16),
          if (icon != null) MySpacing.width(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) MyText.bodyMedium(title, fontWeight: 600, muted: true),
                if (subtitle != null) MyText.bodySmall(subtitle, xMuted: true, fontWeight: 600),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchListTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: MyText.bodyMedium(title, fontWeight: 600),
      subtitle: MyText.bodySmall(subtitle, xMuted: true),
      value: value,
      onChanged: onChanged,
    );
  }
}
