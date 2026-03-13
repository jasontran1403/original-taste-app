// views/layout/layout.dart
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/layout/layout_controller.dart';
import 'package:original_taste/controller/layout/top_bar_controller.dart';
import 'package:original_taste/helper/services/auth_services.dart';
import 'package:original_taste/helper/theme/admin_theme.dart';
import 'package:original_taste/helper/theme/theme_customizer.dart';
import 'package:original_taste/helper/widgets/my_button.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_responsiv.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/theme/app_theme.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/images.dart';
import 'package:original_taste/views/layout/left_bar.dart';
import 'package:original_taste/views/layout/top_bar.dart';
import 'package:original_taste/widgets/custom_pop_menu.dart';

class Layout extends StatefulWidget {
  final Widget? child;
  final String screenName;

  const Layout({super.key, this.child, required this.screenName});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  final LayoutController controller = LayoutController();
  final topBarTheme = AdminTheme.theme.topBarTheme;
  final contentTheme = AdminTheme.theme.contentTheme;

  // TopBarController dùng chung để lấy notifications
  // Khởi tạo trực tiếp — tránh LateInitializationError khi GetBuilder build trước initState
  final TopBarController topBarController =
  Get.isRegistered<TopBarController>()
      ? Get.find<TopBarController>()
      : Get.put(TopBarController());

  Function? languageHideFn;

  bool _isLeftBarExpanded = false;

  void _showLogoutDialog() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: true,   // ← thoát khỏi GetX navigator, backdrop không can thiệp được
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 360,
          padding: MySpacing.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyContainer.rounded(
                color: contentTheme.danger.withOpacity(0.12),
                paddingAll: 16,
                child: Icon(Boxicons.bx_log_out,
                    size: 32, color: contentTheme.danger),
              ),
              MySpacing.height(16),
              MyText.titleMedium('Xác nhận đăng xuất',
                  fontWeight: 700, textAlign: TextAlign.center),
              MySpacing.height(8),
              MyText.bodyMedium('Bạn có chắc chắn muốn đăng xuất không?',
                  muted: true, textAlign: TextAlign.center),
              MySpacing.height(24),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: MyButton.outlined(
                        onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(false),
                        borderColor: theme.colorScheme.outline.withOpacity(0.4),
                        padding: MySpacing.xy(0, 12),
                        child: MyText.labelLarge('Hủy', fontWeight: 600),
                      ),
                    ),
                    MySpacing.width(12),
                    Expanded(
                      child: MyButton(
                        onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(true),
                        backgroundColor: contentTheme.danger,
                        padding: MySpacing.xy(0, 12),
                        elevation: 0,
                        child: MyText.labelLarge('Đăng xuất',
                            fontWeight: 600, color: contentTheme.onDanger),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      await Future.delayed(const Duration(milliseconds: 120));
      AuthService.logout();
    }
  }

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

  // ── Mobile ────────────────────────────────────────────────────────
  Widget mobileScreen() {
    return GetBuilder<TopBarController>(
      init: topBarController,
      builder: (tc) => Scaffold(
        key: controller.scaffoldKey,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            onPressed: () =>
                controller.scaffoldKey.currentState!.openDrawer(),
            icon: SvgPicture.asset(
              'assets/svg/hamburger_menu_broken.svg',
              colorFilter: ColorFilter.mode(
                  contentTheme.secondary, BlendMode.srcIn),
            ),
          ),
          title: MyText.titleMedium(widget.screenName,
              fontWeight: 800, xMuted: true),
          actions: [
            // ── Dark mode toggle ────────────────────────────────
            InkWell(
              onTap: () {
                ThemeCustomizer.setTheme(
                  ThemeCustomizer.instance.theme == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark,
                );
                ThemeCustomizer.notify();
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: SvgPicture.asset(
                  'assets/svg/moon.svg',
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(
                      contentTheme.secondary, BlendMode.srcIn),
                ),
              ),
            ),

            // ── Notification bell ───────────────────────────────
            CustomPopupMenu(
              backdrop: true,
              onChange: (_) {},
              offsetX: -240,
              menu: Padding(
                padding: const EdgeInsets.all(8),
                child: SvgPicture.asset(
                  'assets/svg/bell_bing_bold.svg',
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(
                      contentTheme.secondary, BlendMode.srcIn),
                ),
              ),
              menuBuilder: (_) =>
                  _buildNotificationPanel(tc.notifications),
            ),

            // ── User avatar / account menu ──────────────────────
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CustomPopupMenu(
                backdrop: true,
                hideFn: (fn) => languageHideFn = fn,
                onChange: (_) {},
                offsetX: -110,
                offsetY: 8,
                menu: MyContainer.rounded(
                  paddingAll: 0,
                  height: 32,
                  width: 32,
                  child: Image.asset(Images.userAvatars[1]),
                ),
                menuBuilder: (_) => _buildAccountMenu(),
              ),
            ),
          ],
        ),
        drawer: LeftBar(),
        body: Stack(
          children: [
            _ContentArea(child: widget.child),
          ],
        ),
      ),
    );
  }

  // ── Desktop / Tablet ──────────────────────────────────────────────
  Widget largeScreen() {
    return Scaffold(
      key: controller.scaffoldKey,
      backgroundColor: ThemeCustomizer.instance.theme == ThemeMode.dark
          ? const Color(0xff22282e)
          : const Color(0xfff9f7f7),
      body: Stack(
        children: [
          Positioned.fill(
            left: _isLeftBarExpanded ? 200 : 90,
            child: MyCard.none(
              color: ThemeCustomizer.instance.theme == ThemeMode.dark
                  ? const Color(0xff22282e)
                  : const Color(0xfff9f7f7),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 40,
                        right: 40,
                        top: 77 + flexSpacing,
                        bottom: flexSpacing,
                      ),
                      child: _ContentArea(child: widget.child),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: TopBar(screensName: widget.screenName),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: LeftBar(
              isCondensed: !_isLeftBarExpanded,
              onToggle: (isExpanded) {
                setState(() => _isLeftBarExpanded = isExpanded);
              },
            ),
          ),
        ],
      ),
    );
  }

  double get flexSpacing => MySpacing.safeAreaTop(context) + 12;

  // ── Notification panel (dùng chung) ──────────────────────────────
  Widget _buildNotificationPanel(List<Map<String, dynamic>> notifications) {
    return MyContainer.bordered(
      paddingAll: 0,
      borderRadiusAll: 8,
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.xy(12, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText.titleMedium('Notifications',
                    fontWeight: 700, muted: true),
                MyButton.text(
                  onPressed: () => notifications.clear(),
                  padding: MySpacing.zero,
                  splashColor: contentTheme.secondary.withAlpha(28),
                  msPadding: const WidgetStatePropertyAll(EdgeInsets.zero),
                  child: MyText.labelMedium('Clear All',
                      fontWeight: 600, xMuted: true),
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          SizedBox(
            height: 270,
            child: notifications.isEmpty
                ? Center(
              child: MyText.bodyMedium('No new notifications',
                  muted: true, fontWeight: 500),
            )
                : ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                return MyButton(
                  onPressed: () {},
                  elevation: 0,
                  borderRadiusAll: 0,
                  padding: MySpacing.xy(12, 14),
                  backgroundColor: theme.colorScheme.surface
                      .withValues(alpha: 0.03),
                  splashColor: theme.colorScheme.onSurface
                      .withValues(alpha: 0.08),
                  child: Padding(
                    padding: MySpacing.all(8),
                    child: Row(children: [
                      _buildNotifLeading(item),
                      MySpacing.width(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            if (item['name'] != null)
                              MyText.bodyMedium(item['name'],
                                  fontWeight: 600),
                            MyText.bodySmall(
                              item['message'] ?? '',
                              fontWeight: 500,
                              muted: true,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                );
              },
              separatorBuilder: (_, __) => const Divider(),
            ),
          ),
          const Divider(height: 0),
          Center(
            child: MyButton(
              onPressed: () {},
              padding: MySpacing.xy(12, 10),
              backgroundColor: contentTheme.primary,
              msBackgroundColor:
              WidgetStatePropertyAll(contentTheme.primary),
              borderRadiusAll: 8,
              elevation: 0,
              child: MyText.labelMedium('View All Notification',
                  fontWeight: 600,
                  xMuted: true,
                  color: contentTheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifLeading(Map<String, dynamic> item) {
    if (item.containsKey('avatar')) {
      return MyContainer.rounded(
        height: 36, width: 36, paddingAll: 0,
        clipBehavior: Clip.antiAlias,
        child: Image.asset(item['avatar'], fit: BoxFit.cover),
      );
    } else if (item.containsKey('initial')) {
      return MyContainer.rounded(
        height: 36, width: 36,
        color: (item['color'] as Color?)?.withValues(alpha: 0.2) ??
            Colors.grey.shade200,
        child: Center(
          child: Text(item['initial'],
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: item['color'] ?? Colors.black)),
        ),
      );
    } else if (item.containsKey('icon')) {
      return MyContainer.rounded(
        height: 36, width: 36, paddingAll: 0,
        color: (item['color'] as Color?)?.withValues(alpha: 0.2) ??
            Colors.grey.shade100,
        child: Icon(item['icon'],
            size: 18, color: item['color'] ?? Colors.grey),
      );
    }
    return MyContainer.rounded(
      height: 36, width: 36, color: Colors.grey.shade300,
      child: const Icon(Icons.notifications_none,
          size: 18, color: Colors.black54),
    );
  }

  // ── Account menu (dùng chung) ─────────────────────────────────────
  Widget _buildAccountMenu() {
    return MyContainer(
      borderRadiusAll: 8,
      paddingAll: 0,
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.nBottom(12),
            child: MyText.labelMedium('Welcome!',
                fontWeight: 700, muted: true),
          ),
          MySpacing.height(12),
          MyButton(
            onPressed: () {
              languageHideFn?.call();
              Get.toNamed('/profile');
            },
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            borderRadiusAll: 0,
            padding: MySpacing.all(12),
            splashColor: theme.colorScheme.onSurface.withAlpha(20),
            backgroundColor: Colors.transparent,
            child: Row(children: [
              Icon(Boxicons.bx_user_circle,
                  size: 16, color: contentTheme.onBackground),
              MySpacing.width(8),
              MyText.labelMedium('Profile', fontWeight: 700, muted: true),
            ]),
          ),
          const Divider(),
          MyButton(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPressed: () {
              languageHideFn?.call();
              _showLogoutDialog();
            },
            borderRadiusAll: 0,
            padding: MySpacing.all(12),
            splashColor: theme.colorScheme.error.withAlpha(28),
            backgroundColor: Colors.transparent,
            child: Row(children: [
              Icon(Boxicons.bx_log_out,
                  size: 16, color: contentTheme.danger),
              MySpacing.width(8),
              MyText.labelMedium('Log out',
                  fontWeight: 700,
                  muted: true,
                  color: contentTheme.danger),
            ]),
          ),
          MySpacing.height(12),
        ],
      ),
    );
  }
}

class _ContentArea extends StatelessWidget {
  final Widget? child;
  const _ContentArea({this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOut,
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