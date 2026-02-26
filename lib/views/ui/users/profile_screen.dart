import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/ui/users/profile_controller.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_flex.dart';
import 'package:original_taste/helper/widgets/my_flex_item.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/helper/widgets/my_text_style.dart';
import 'package:original_taste/images.dart';
import 'package:original_taste/views/layout/layout.dart';
import 'package:remixicon/remixicon.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with UIMixin {
  ProfileController controller = Get.put(ProfileController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'profile_controller',
      builder: (controller) {
        return Layout(
          screenName: "PROFILE",
          child: MyFlex(
            children: [
              MyFlexItem(sizes: 'lg-9', child: profileInformation()),
              MyFlexItem(sizes: 'lg-3', child: personalInformation()),
              MyFlexItem(sizes: 'lg-8', child: about()),
              MyFlexItem(
                sizes: 'lg-4',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyFlex(
                      contentPadding: false,
                      children: [
                        MyFlexItem(sizes: 'lg-6', child: buildCard('assets/svg/cup_star.svg', '+12', 'Achievements')),
                        MyFlexItem(sizes: 'lg-6', child: buildCard('assets/svg/medal_star_circle.svg', '+24', 'Accomplishments')),
                      ],
                    ),
                    MySpacing.height(12),
                    shareYourProfile(),
                  ],
                ),
              ),
              MyFlexItem(sizes: 'lg-3', child: popularFilter()),
              MyFlexItem(sizes: 'lg-9', child: postCard()),
            ],
          ),
        );
      },
    );
  }

  Widget profileInformation() {
    return MyCard(
      borderRadiusAll: 12,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      paddingAll: 0,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(height: 300, width: double.infinity, color: contentTheme.primary),
              Positioned(
                top: 260,
                left: 20,
                child: MyContainer.rounded(
                  paddingAll: 3,
                  child: MyContainer.rounded(paddingAll: 0, height: 80, width: 80, child: Image.asset(Images.userAvatars[0])),
                ),
              ),
            ],
          ),
          MySpacing.height(50),
          Padding(
            padding: MySpacing.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            MyText.bodyLarge('Gaston Lapierre ', fontWeight: 700),
                            Icon(Icons.verified, color: contentTheme.success, size: 18),
                          ],
                        ),
                        MySpacing.height(8),
                        MyText.bodyMedium('Project Head Manager', color: contentTheme.secondary),
                      ],
                    ),
                    Row(
                      children: [
                        MyContainer(
                          color: contentTheme.info,
                          borderRadiusAll: 12,
                          paddingAll: 12,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.message, size: 16, color: contentTheme.light),
                              MySpacing.width(8),
                              MyText.bodySmall("Message", color: contentTheme.light),
                            ],
                          ),
                        ),
                        MySpacing.width(12),
                        MyContainer.bordered(
                          borderColor: contentTheme.primary,
                          paddingAll: 12,
                          borderRadiusAll: 12,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, size: 16, color: contentTheme.primary),
                              MySpacing.width(4),
                              MyText.bodyMedium("Follow", color: contentTheme.primary),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: contentTheme.secondary, size: 20),
                          itemBuilder:
                              (context) => [
                                const PopupMenuItem(value: "download", child: MyText.labelMedium("Download")),
                                const PopupMenuItem(value: "export", child: MyText.labelMedium("Export")),
                                const PopupMenuItem(value: "import", child: MyText.labelMedium("Import")),
                              ],
                        ),
                      ],
                    ),
                  ],
                ),
                MySpacing.height(20),
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    _StatTile(svgImage: 'assets/svg/clock_circle.svg', iconColor: Colors.blue, title: '3+ Years Job', subtitle: 'Experience'),
                    _StatTile(svgImage: 'assets/svg/cup_star.svg', iconColor: Colors.blue, title: '5 Certificate', subtitle: 'Achieved'),
                    _StatTile(svgImage: 'assets/svg/notebook_bold_duotone.svg', iconColor: Colors.blue, title: '5 Certificate', subtitle: 'Achieved'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget personalInformation() {
    Widget infoRow(String icon, Widget text) {
      return Padding(
        padding: MySpacing.bottom(12),
        child: Row(
          children: [
            Container(
              height: 34,
              width: 34,
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
              child: Center(child: SvgPicture.asset(icon, height: 20, colorFilter: ColorFilter.mode(contentTheme.secondary, BlendMode.srcIn))),
            ),
            MySpacing.width(12),
            Expanded(child: text),
          ],
        ),
      );
    }

    return MyCard(
      borderRadiusAll: 12,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      paddingAll: 0,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: MySpacing.all(20), child: MyText.bodyLarge('Personal Information', fontWeight: 700)),
          Divider(height: 0),
          Padding(
            padding: MySpacing.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                infoRow("assets/svg/backpack_bold_duotone.svg", MyText("Project Head Manager")),
                infoRow("assets/svg/square_academic_cap_2.svg", MyText("Went to Oxford International")),
                infoRow("assets/svg/map_point.svg", MyText("Lives in Pittsburgh, PA 15212")),
                infoRow("assets/svg/users_group_two_rounded.svg", MyText("Followed by 16.6k People")),
                infoRow("assets/svg/letter_bold.svg", Row(children: [MyText("Email"), Expanded(child: MyText(" hello@dundermuffilin.com",maxLines: 1,))])),
                infoRow("assets/svg/link_bold.svg", Row(children: [MyText("Website"), Expanded(child: MyText("  www.larkon.co",maxLines: 1,))])),
                infoRow("assets/svg/global_bold.svg", MyText("Language English , Spanish , German")),
                infoRow(
                  "assets/svg/check_circle_bold.svg",
                  Row(
                    children: [
                      MyText("Status "),
                      MyContainer(
                        color: contentTheme.success.withValues(alpha: 0.2),
                        paddingAll: 4,
                        borderRadiusAll: 2,
                        child: MyText.labelMedium("Active", color: contentTheme.success),
                      ),
                    ],
                  ),
                ),
                InkWell(onTap: () {}, child: MyText.bodyMedium("View More", color: contentTheme.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget about() {
    Widget marketingCard(String title, List<String> tags, String statusLabel, String statusValue) {
      return MyContainer.bordered(
        borderRadiusAll: 12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText.titleMedium(title),
            MySpacing.height(16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  tags
                      .map(
                        (tag) => MyContainer(
                          borderRadiusAll: 12,
                          padding: MySpacing.symmetric(horizontal: 8, vertical: 4),
                          color: contentTheme.secondary.withValues(alpha: 0.2),
                          child: MyText.bodyMedium(tag, color: contentTheme.secondary),
                        ),
                      )
                      .toList(),
            ),
            MySpacing.height(16),
            Row(
              children: [
                MyText.bodyMedium("$statusLabel :"),
                MySpacing.width(6),
                MyContainer(
                  padding: MySpacing.all(4),
                  borderRadiusAll: 6,
                  color: contentTheme.success.withValues(alpha: 0.2),
                  child: MyText.labelMedium(statusValue, color: contentTheme.success),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget buildSkillRating(String title, int stars) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: List.generate(stars, (index) => Icon(Icons.star, color: contentTheme.warning, size: 20))),
          MySpacing.width(12),
          MyText.bodyMedium(title),
        ],
      );
    }

    return MyCard(
      borderRadiusAll: 12,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      paddingAll: 0,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: MySpacing.all(20), child: MyText.bodyLarge('About', fontWeight: 700)),
          Divider(height: 0),
          Padding(
            padding: MySpacing.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.bodyMedium(controller.dummyTexts[2], maxLines: 3),
                MySpacing.height(12),
                MyText.bodyLarge('My Approach :', fontWeight: 700),
                MySpacing.height(12),
                MyText.bodyMedium(controller.dummyTexts[2], maxLines: 3),
                MySpacing.height(16),
                MyFlex(
                  contentPadding: false,
                  children: [
                    MyFlexItem(
                      sizes: 'lg-6',
                      child: marketingCard(
                        "Marketing expertise",
                        ["#Leadership", "#Advertising", "#Public-relations", "#Branding-manage"],
                        "Open to networking",
                        "Yes",
                      ),
                    ),
                    MyFlexItem(
                      sizes: 'lg-6',
                      child: marketingCard(
                        "Marketing interests",
                        ["#Event-marketing", "#Performance-marketing", "#Account-based-marketing"],
                        "Open to advising",
                        "Yes",
                      ),
                    ),
                  ],
                ),
                MySpacing.height(16),
                MyText.bodyLarge('More Core Skills :', fontWeight: 700),
                MySpacing.height(16),
                Wrap(
                  spacing: 20,
                  children: [
                    buildSkillRating("Inbound Marketing", 4),
                    buildSkillRating("Entrepreneurship", 3),
                    buildSkillRating("Growth Marketing", 2),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard(String svgImage, String count, String name) {
    return MyCard(
      borderRadiusAll: 12,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      paddingAll: 20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MyContainer(
            color: contentTheme.info,
            paddingAll: 8,
            height: 44,
            width: 44,
            child: SvgPicture.asset(svgImage, colorFilter: ColorFilter.mode(contentTheme.light, BlendMode.srcIn)),
          ),
          MySpacing.height(12),
          MyText.titleLarge(count, fontWeight: 700),
          MySpacing.height(8),
          MyText.titleMedium(name, xMuted: true, fontWeight: 700),
        ],
      ),
    );
  }

  Widget shareYourProfile() {
    Widget socialButton(IconData icon, Color color) {
      return MyContainer(
        width: 44,
        height: 44,
        paddingAll: 0,
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        child: Center(child: Icon(icon, color: color, size: 20)),
      );
    }

    return MyCard(
      borderRadiusAll: 12,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      paddingAll: 20,
      child: Column(
        children: [
          MyText.bodyMedium("Share your profile", textAlign: TextAlign.center, fontWeight: 700),
          MySpacing.height(12),
          MyText.bodyMedium("Now that your agency is created, go ahead and share it to start generating leads.", textAlign: TextAlign.center),
          MySpacing.height(16),
          SizedBox(height: 100, child: Image.asset("assets/qr-code.png")),
          MySpacing.height(16),
          Wrap(
            spacing: 10,
            alignment: WrapAlignment.center,
            children: [
              socialButton(RemixIcons.facebook_fill, Colors.blue),
              socialButton(RemixIcons.instagram_fill, Colors.pink),
              socialButton(RemixIcons.twitter_fill, Colors.lightBlue),
              socialButton(RemixIcons.whatsapp_fill, Colors.green),
              socialButton(Icons.email_outlined, Colors.orange),
            ],
          ),
          MySpacing.height(16),
          MyText.bodyMedium("Copy the URL below and share it with your friends:", textAlign: TextAlign.center),
          MySpacing.height(16),
          MyContainer.bordered(
            borderRadiusAll: 12,
            padding: MySpacing.xy(12, 8),
            color: contentTheme.secondary.withValues(alpha: 0.1),
            child: Row(
              children: [
                Expanded(child: Text("https://larkon-mileage.com", style: TextStyle(color: Colors.black87))),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('URL copied!')));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget popularFilter() {
    return MyCard(
      borderRadiusAll: 12,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: MySpacing.all(20), child: MyText.bodyLarge('Popular Filter', fontWeight: 700)),
          Divider(height: 0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: MySpacing.all(16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                      controller.filters.keys.map((filter) {
                        final selected = controller.filters[filter]!;
                        return FilterChip(
                          label: Text(filter),
                          selected: selected,
                          onSelected: (bool value) => setState(() => controller.filters[filter] = value),
                          labelStyle: MyTextStyle.bodyMedium(),
                          backgroundColor: Colors.grey.shade100,
                          selectedColor: Colors.blue.shade100,
                          checkmarkColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
          Divider(height: 0),
          Padding(
            padding: MySpacing.all(20),
            child: Center(child: InkWell(onTap: () {}, child: MyText.bodyMedium("View More", color: contentTheme.primary))),
          ),
        ],
      ),
    );
  }

  Widget postCard() {
    return Column(
      spacing: 20,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostCard(
          userName: "Gaston Lapierre",
          userRole: "Project Head Manager",
          date: "Nov 16",
          hashtags: ["#inbound", "#SaaS"],
          question: "Do you have any experience with deploying @Hubspot for a SaaS business with both a direct and self-serve model?",
          description:
              "We are a Series A B2B startup offering a custom solution. Currently, we are utilizing @MixPanel and collaborating with @Division of Labor to rebuild our pages. Shoutout to @Jennifer Smith for her support...",
        ),
        PostCard(
          userName: "Gaston Lapierre",
          userRole: "Project Head Manager",
          date: "Nov 11",
          hashtags: ["#LatAm", "#Europe"],
          question: "Looking for a new landing page optimization vendor",
          description: "We are currently using @Optimizely, but find that they are missing a number with a custom solution that no...",
        ),
        PostCard(
          userName: "Gaston Lapierre",
          userRole: "Project Head Manager",
          date: "Nov 08",
          hashtags: ["#Performance-marketing", "#CRM"],
          question: "Why Your Company Needs a CRM to Grow Better?",
          description:
              "CRMs are powerful tools that help you expedite business growth while number with a custom eliminating friction, improving cross-team collaboration, managing your contact records, syncing...",
        ),
      ],
    );
  }
}

class PostCard extends StatefulWidget {
  final String userName;
  final String userRole;
  final String date;
  final List<String> hashtags;
  final String question;
  final String description;

  const PostCard({
    super.key,
    required this.userName,
    required this.userRole,
    required this.date,
    required this.hashtags,
    required this.question,
    required this.description,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with UIMixin {
  @override
  Widget build(BuildContext context) {
    return MyCard(
      borderRadiusAll: 12,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      paddingAll: 0,
      child: Column(
        children: [
          Padding(
            padding: MySpacing.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    MyContainer.rounded(paddingAll: 0, height: 52, width: 52, child: Image.asset(Images.userAvatars[0])),
                    MySpacing.width(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText.bodyMedium("${widget.userName} ,"),
                          MyText.bodySmall("${widget.userRole} · ${widget.date}"),
                          MySpacing.height(4),
                          Wrap(spacing: 6, children: widget.hashtags.map((tag) => MyText.bodyMedium(tag, color: contentTheme.primary)).toList()),
                        ],
                      ),
                    ),
                  ],
                ),
                MySpacing.height(16),
                MyText.bodyMedium(widget.question),
                MySpacing.height(8),
                Text.rich(
                  TextSpan(
                    text: widget.description,
                    style: const TextStyle(fontSize: 14),
                    children: [TextSpan(text: " See more", style: TextStyle(color: contentTheme.primary))],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 0),

          Padding(
            padding: MySpacing.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                footerAction(Icons.edit_note_outlined, "Answer", color: contentTheme.primary),
                MySpacing.width(16),
                footerAction(Icons.handshake_outlined, "Thanks"),
                MySpacing.width(16),
                footerAction(Icons.lightbulb_outline, "Insightful"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget footerAction(IconData icon, String label, {Color? color}) {
    return Row(children: [Icon(icon, size: 18, color: color ?? Colors.black54), MySpacing.width(8), MyText.bodyMedium(label)]);
  }
}

class _StatTile extends StatelessWidget {
  final String? svgImage;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _StatTile({required this.iconColor, required this.title, required this.subtitle, this.svgImage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(svgImage ?? ""),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [MyText.bodyLarge(title, fontWeight: 700), MySpacing.height(8), MyText.bodyMedium(subtitle, fontWeight: 600, xMuted: true)],
        ),
      ],
    );
  }
}
