import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/layout/layout_controller.dart';
import 'package:original_taste/helper/theme/admin_theme.dart';
import 'package:original_taste/helper/theme/theme_customizer.dart';
import 'package:original_taste/helper/widgets/my_button.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_responsiv.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/theme/app_theme.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/helper/widgets/responsive.dart';
import 'package:original_taste/views/layout/left_bar.dart';
import 'package:original_taste/views/layout/right_bar.dart';
import 'package:original_taste/views/layout/top_bar.dart';

class Layout extends StatefulWidget {
  final Widget? child;
  final String screenName;

  const Layout({super.key, this.child, required this.screenName});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  final LayoutController controller = LayoutController();
  final topBarTheme   = AdminTheme.theme.topBarTheme;
  final contentTheme  = AdminTheme.theme.contentTheme;
  Function? languageHideFn;
  List notification = [];

  @override
  Widget build(BuildContext context) {
    return MyResponsive(
      builder: (BuildContext context, _, screenMT) {
        return GetBuilder(
          init: controller,
          builder: (controller) {
            if (screenMT.isMobile || screenMT.isTablet) {
              return mobileScreen();
            } else {
              return largeScreen();
            }
          },
        );
      },
    );
  }

  Widget mobileScreen() {
    return Scaffold(
      key: controller.scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => controller.scaffoldKey.currentState!.openDrawer(),
          icon: SvgPicture.asset(
            'assets/svg/hamburger_menu_broken.svg',
            colorFilter: ColorFilter.mode(contentTheme.secondary, BlendMode.srcIn),
          ),
        ),
        title: MyText.titleMedium(widget.screenName, fontWeight: 800, xMuted: true),
        actions: [
          MouseRegion(
            onEnter: (_) => setState(() => controller.isHovered = true),
            onExit:  (_) => setState(() => controller.isHovered = false),
            child: InkWell(
              onTap: () => ThemeCustomizer.setTheme(
                ThemeCustomizer.instance.theme == ThemeMode.dark
                    ? ThemeMode.light
                    : ThemeMode.dark,
              ),
              child: SvgPicture.asset(
                'assets/svg/moon.svg',
                width: 22, height: 22,
                colorFilter: ColorFilter.mode(
                  controller.isHovered ? contentTheme.primary : contentTheme.secondary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer:    LeftBar(),
      endDrawer: RightBar(),
      // ── FIX: Navigator nội bộ chỉ swap content, giữ AppBar + Drawer ──
      body: _ContentArea(child: widget.child),
    );
  }

  Widget largeScreen() {
    return Scaffold(
      key: controller.scaffoldKey,
      backgroundColor: ThemeCustomizer.instance.theme == ThemeMode.dark
          ? const Color(0xff22282e)
          : const Color(0xfff9f7f7),
      body: Row(
        children: [
          // LeftBar luôn tồn tại, không bị rebuild khi navigate
          LeftBar(isCondensed: ThemeCustomizer.instance.leftBarCondensed),
          Expanded(
            child: MyCard.none(
              color: ThemeCustomizer.instance.theme == ThemeMode.dark
                  ? const Color(0xff22282e)
                  : const Color(0xfff9f7f7),
              child: Stack(
                children: [
                  Positioned.fill(
                    // ── FIX: dùng Navigator nội bộ để swap content ──
                    child: Padding(
                      padding: MySpacing.fromLTRB(40, 77 + flexSpacing, 40, flexSpacing),
                      child: _ContentArea(child: widget.child),
                    ),
                  ),
                  // TopBar luôn đứng yên bên trên
                  Positioned(
                    top: 0, left: 0, right: 0,
                    child: TopBar(screensName: widget.screenName),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Notification, account menu (giữ nguyên) ──────────────────────────────

  Widget buildNotification() {
    return MyContainer.bordered(
      paddingAll: 0,
      borderRadiusAll: 8,
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.xy(12, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText.titleMedium("Notifications", fontWeight: 700, muted: true),
                MyButton.text(
                  onPressed: () {},
                  padding: MySpacing.zero,
                  splashColor: contentTheme.secondary.withAlpha(28),
                  msPadding: WidgetStatePropertyAll(MySpacing.zero),
                  child: MyText.labelMedium("Clear All", fontWeight: 600, xMuted: true),
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          SizedBox(
            height: 270,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: notification.length,
              itemBuilder: (context, index) {
                final item = notification[index];
                return MyButton(
                  onPressed: () {},
                  elevation: 0,
                  borderRadiusAll: 0,
                  padding: MySpacing.all(20),
                  backgroundColor: theme.colorScheme.surface.withAlpha(5),
                  splashColor: theme.colorScheme.onSurface.withAlpha(10),
                  child: Row(children: [
                    MyContainer.rounded(
                      height: 36, width: 36, paddingAll: 0,
                      color: getBackgroundColor(item['background']),
                      child: Center(
                        child: Icon(item['icon'], color: getIconColor(item['icon_color']), size: 16),
                      ),
                    ),
                    MySpacing.width(12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        MyText.bodyMedium(item['message'], fontWeight: 600, muted: true, maxLines: 1, overflow: TextOverflow.ellipsis),
                        MyText.bodySmall(item['time'],    fontWeight: 600, muted: true),
                      ]),
                    ),
                  ]),
                );
              },
            ),
          ),
          const Divider(height: 0),
          Center(
            child: MyButton.text(
              onPressed: () {},
              padding: MySpacing.zero,
              msPadding: WidgetStatePropertyAll(MySpacing.zero),
              splashColor: contentTheme.primary.withAlpha(28),
              child: MyText.labelMedium("View All", fontWeight: 600, xMuted: true, color: contentTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAccountMenu() {
    return MyContainer(
      borderRadiusAll: 8, paddingAll: 0, width: 150,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: MySpacing.nBottom(12), child: MyText.labelMedium("Welcome!", fontWeight: 700, muted: true)),
        MySpacing.height(12),
        _accountBtn('My Account',  () { languageHideFn?.call(); Get.toNamed('/page/profile'); }),
        MySpacing.height(8),
        _accountBtn('Settings',    () { languageHideFn?.call(); Get.toNamed('/page/profile'); }),
        MySpacing.height(8),
        _accountBtn('Support',     () { languageHideFn?.call(); Get.toNamed('/page/faq'); }),
        MySpacing.height(8),
        _accountBtn('Lock Screen', () { languageHideFn?.call(); Get.offNamed('/auth/lock'); }),
        MySpacing.height(8),
        _accountBtn('Log out',     () { languageHideFn?.call(); Get.toNamed('/auth/logout'); }),
        MySpacing.height(12),
      ]),
    );
  }

  Widget _accountBtn(String label, VoidCallback onTap) {
    return MyButton(
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: onTap,
      borderRadiusAll: 0,
      padding: MySpacing.all(12),
      splashColor: theme.colorScheme.onSurface.withAlpha(20),
      backgroundColor: Colors.transparent,
      child: Row(children: [
        MySpacing.width(8),
        MyText.labelMedium(label, fontWeight: 700, muted: true),
      ]),
    );
  }

  Color getIconColor(String colorKey) {
    switch (colorKey) {
      case "text-primary":  return Colors.blue;
      case "text-warning":  return Colors.orange;
      case "text-danger":   return Colors.red;
      case "text-pink":     return Colors.pink;
      case "text-purple":   return Colors.purple;
      case "text-success":  return Colors.green;
      default:              return Colors.grey;
    }
  }

  Color getBackgroundColor(String bgKey) {
    switch (bgKey) {
      case "bg-primary-subtle":  return Colors.blue.shade50;
      case "bg-warning-subtle":  return Colors.orange.shade50;
      case "bg-danger-subtle":   return Colors.red.shade50;
      case "bg-pink-subtle":     return Colors.pink.shade50;
      case "bg-purple-subtle":   return Colors.purple.shade50;
      case "bg-success-subtle":  return Colors.green.shade50;
      default:                   return Colors.grey.shade50;
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
// _ContentArea — AnimatedSwitcher để swap nội dung có loading animation
// ════════════════════════════════════════════════════════════════════════════
class _ContentArea extends StatelessWidget {
  final Widget? child;
  const _ContentArea({this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve:  Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: child != null
          ? KeyedSubtree(
        key: ValueKey(child.runtimeType),
        child: child!,
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}